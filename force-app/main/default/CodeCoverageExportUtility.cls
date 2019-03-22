public class CodeCoverageExportUtility {
    
    private static final String ENDPOINT_URL;
    private static final String CODE_COVERAGE_QUERY;

    static {
        String hostURL = System.URL.getSalesforceBaseUrl().getHost();
        String toolingAPIQueryURI = '/services/data/v45.0/tooling/query/?q=';
        
        ENDPOINT_URL = 'https://' + hostURL + toolingAPIQueryURI;

        CODE_COVERAGE_QUERY = 'SELECT ApexClassOrTrigger.Name, NumLinesUncovered, NumLinesCovered '
                            + 'FROM ApexCodeCoverageAggregate';
    }

    public static CoverageReportWrapper getCodeCoverageReport () {

        HttpRequest req = new HttpRequest();

        String encodedQuery = EncodingUtil.urlEncode(CODE_COVERAGE_QUERY, 'UTF-8');

        req.setEndpoint(ENDPOINT_URL + encodedQuery);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        CoverageReportWrapper response = 
                        (CoverageReportWrapper) JSON.deserialize(res.getBody(), 
                                                                 CoverageReportWrapper.class);

        return response;

    }

    public static List<Class_Code_Coverage__c> updateLocalCodeCoverageRecords () {

        CoverageReportWrapper coverageReport = getCodeCoverageReport();
        List<Class_Code_Coverage__c> newReport = new List<Class_Code_Coverage__c>();

        for (CoverageReport cr : coverageReport.records) {
            Class_Code_Coverage__c entry = New Class_Code_Coverage__c();
            entry.Name = cr.ApexClassOrTrigger.Name;
            entry.NumLinesCovered__c = cr.NumLinesCovered;
            entry.NumLinesUncovered__c = cr.NumLinesUncovered;
            newReport.add(entry);
        }

        insert newReport;

        // Delete any previous versions. TODO: Keep history of records
        delete [SELECT Id FROM Class_Code_Coverage__c WHERE Id NOT IN :newReport];

        return newReport;

    }

    public class CoverageReportWrapper {
        List<CoverageReport> records;
    }

    public class CoverageReport {
        Integer NumLinesCovered;
        Integer NumLinesUncovered;
        EntityInfo ApexClassOrTrigger;
    }

    public class EntityInfo {
        String Name;
    }
}
