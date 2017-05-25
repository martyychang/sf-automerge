@isTest
private class MergeServiceTest {

    /**
     * Given that I have three merge concerns as follows ...
     * 
     * - Fax (overwrite always)
     * - Phone (overwrite if blank)
     * - Website (overwite if blank)
     *
     * and I have two accounts that look as follows ...
     *
     * Account: Acme Corporation (TEST)
     * - Website: 
     * - Phone: (800) BUY-ACME
     * - Fax: (800) BUY-ACME
     *
     * Account: Acme, Inc. (TEST)
     * - Website: https://therealacme.test
     * - Phone: (877) BUY-ACME
     * - Fax:
     *
     * ... when I merge Acme, Inc. (victim) into Acme Corporation (survivor),
     * then Acme Corporation should have the following field values.
     *
     * Account: Acme Corporation (TEST)
     * - Id: whatever the ID is for Acme Corporation
     * - Website: https://therealacme.test
     * - Phone: (800) BUY-ACME
     * - Fax: 
     */
    @isTest
    private static void mergeOne() {

        // Define params for the test
        Account acmeCorp = new Account(
                Name = 'Acme Corporation (TEST)',
                Website = null,
                Phone = '(800) BUY-ACME',
                Fax = '(800 BUY-ACME');

        Account acmeInc = new Account(
                Name = 'Acme, Inc. (TEST)',
                Website = 'https://therealacme.test',
                Phone = '(877) BUY-ACME',
                Fax = null);

        insert new List<Account> { acmeCorp, acmeInc };

        // Run the test
        Test.startTest();

        MergeService.getInstance('Account').mergeOne(acmeCorp, acmeInc);

        // Validate results
        Test.stopTest();

        acmeCorp = [
            SELECT Name, Website, Phone, Fax
            FROM Account
            WHERE Id = :acmeCorp.Id
        ];

        System.assertEquals('Acme Corporation (TEST)', acmeCorp.Name);
        System.assertEquals('https://therealacme.test', acmeCorp.Website);
        System.assertEquals('(800) BUY-ACME', acmeCorp.Phone);
        System.assertEquals(null, acmeCorp.Fax);
    }
}