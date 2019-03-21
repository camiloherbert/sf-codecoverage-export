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

    public static String getCodeCoverageReport () {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(ENDPOINT_URL + CODE_COVERAGE_QUERY);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(80000);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        return res.getBody();

    }
}
