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

        List<Account> acmeAccounts = [
            SELECT Id, Name, Website, Phone, Fax
            FROM Account
            WHERE Name LIKE 'Acme%'
        ];

        System.assertEquals(1, acmeAccounts.size());
        System.assertEquals(acmeCorp.Id, acmeAccounts[0].Id);
        System.assertEquals('Acme Corporation (TEST)', acmeAccounts[0].Name);

        if (hasCannedAccountWebsiteConcern()) {
            System.assertEquals('https://therealacme.test', acmeAccounts[0].Website);
        }

        if (hasCannedAccountPhoneConcern()) {
            System.assertEquals('(800) BUY-ACME', acmeAccounts[0].Phone);
        }

        if (hasCannedAccountFaxConcern()) {
            System.assertEquals(null, acmeAccounts[0].Fax);
        }
    }

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
     * ... and another three accounts that look as follows ...
     *
     * Account: Zenith Corporation (TEST)
     * - Website: 
     * - Phone: 
     * - Fax: 
     *
     * Account: Zenith, Inc. (TEST)
     * - Website: https://zenith.inc
     * - Phone: 
     * - Fax: (800) 4-ZENITH
     *
     * Account: Zenith, LLC (TEST)
     * - Website: 
     * - Phone: (877) GOOD-ZEN
     * - Fax: 
     *
     * ... when I merge Acme, Inc. (victim) into Acme Corporation (survivor),
     * and in the same `mergeMany` method call I also merge Zenith, Inc.
     * into Zenith Corporation followed by merging Zenith, LLC into
     * Zenith Corporation, I should end up with the following two accounts.
     *
     * Account: Acme Corporation (TEST)
     * - Id: whatever the ID is for Acme Corporation
     * - Website: https://therealacme.test
     * - Phone: (800) BUY-ACME
     * - Fax: 
     *
     * Account: Zenith Corporation (TEST)
     * - Id: whatever the ID is for Zenith, Corporation
     * - Website: https://zenith.inc
     * - Phone: (877) GOOD-ZEN
     * - Fax: 
     */
    @isTest
    private static void mergeMany() {

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
        
        Account zenCorp = new Account(
                Name = 'Zenith Corporation (TEST)',
                Website = null,
                Phone = null,
                Fax = null);

        Account zenInc = new Account(
                Name = 'Zenith, Inc. (TEST)',
                Website = 'https://zenith.inc',
                Phone = null,
                Fax = '(800) 4-ZENITH');
        
        Account zenLlc = new Account(
                Name = 'Zenith, LLC (TEST)',
                Website = null,
                Phone = '(800) GOOD-ZEN',
                Fax = null);

        insert new List<Account> {
            acmeCorp, acmeInc, zenCorp, zenInc, zenLlc
        };

        // Run the test
        Test.startTest();

        MergeService.getInstance('Account').mergeMany(new List<List<Account>> {
            new List<Account> { acmeCorp, acmeInc },
            new List<Account> { zenCorp, zenInc, zenLlc }
        });

        // Validate results
        Test.stopTest();

        List<Account> acmeAccounts = [
            SELECT Id, Name, Website, Phone, Fax
            FROM Account
            WHERE Name LIKE 'Acme%'
        ];

        System.assertEquals(1, acmeAccounts.size());
        System.assertEquals(acmeCorp.Id, acmeAccounts[0].Id);
        System.assertEquals('Acme Corporation (TEST)', acmeAccounts[0].Name);

        if (hasCannedAccountWebsiteConcern()) {
            System.assertEquals('https://therealacme.test', acmeAccounts[0].Website);
        }

        if (hasCannedAccountPhoneConcern()) {
            System.assertEquals('(800) BUY-ACME', acmeAccounts[0].Phone);
        }

        if (hasCannedAccountFaxConcern()) {
            System.assertEquals(null, acmeAccounts[0].Fax);
        }

        List<Account> zenAccounts = [
            SELECT Id, Name, Website, Phone, Fax
            FROM Account
            WHERE Name LIKE 'Zenith%'
        ];

        System.assertEquals(1, zenAccounts.size());
        System.assertEquals(zenCorp.Id, zenAccounts[0].Id);
        System.assertEquals('Zenith Corporation (TEST)', zenAccounts[0].Name);

        if (hasCannedAccountWebsiteConcern()) {
            System.assertEquals('https://zenith.inc', zenAccounts[0].Website);
        }

        if (hasCannedAccountPhoneConcern()) {
            System.assertEquals('(800) GOOD-ZEN', zenAccounts[0].Phone);
        }

        if (hasCannedAccountFaxConcern()) {
            System.assertEquals(null, zenAccounts[0].Fax);
        }
    }

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
     * ... and another three accounts that look as follows ...
     *
     * Account: Zenith Corporation (TEST)
     * - Website: 
     * - Phone: 
     * - Fax: 
     *
     * Account: Zenith, Inc. (TEST)
     * - Website: https://zenith.inc
     * - Phone: 
     * - Fax: (800) 4-ZENITH
     *
     * Account: Zenith, LLC (TEST)
     * - Website: 
     * - Phone: (877) GOOD-ZEN
     * - Fax: 
     *
     * ... when I merge--specifically by passing record IDs--
     * Acme, Inc. (victim) into Acme Corporation (survivor),
     * and in the same `mergeMany` method call I also merge Zenith, Inc.
     * into Zenith Corporation followed by merging Zenith, LLC into
     * Zenith Corporation, I should end up with the following two accounts.
     *
     * Account: Acme Corporation (TEST)
     * - Id: whatever the ID is for Acme Corporation
     * - Website: https://therealacme.test
     * - Phone: (800) BUY-ACME
     * - Fax: 
     *
     * Account: Zenith Corporation (TEST)
     * - Id: whatever the ID is for Zenith, Corporation
     * - Website: https://zenith.inc
     * - Phone: (877) GOOD-ZEN
     * - Fax: 
     */
    @isTest
    private static void mergeManyById() {

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
        
        Account zenCorp = new Account(
                Name = 'Zenith Corporation (TEST)',
                Website = null,
                Phone = null,
                Fax = null);

        Account zenInc = new Account(
                Name = 'Zenith, Inc. (TEST)',
                Website = 'https://zenith.inc',
                Phone = null,
                Fax = '(800) 4-ZENITH');
        
        Account zenLlc = new Account(
                Name = 'Zenith, LLC (TEST)',
                Website = null,
                Phone = '(800) GOOD-ZEN',
                Fax = null);

        insert new List<Account> {
            acmeCorp, acmeInc, zenCorp, zenInc, zenLlc
        };

        // Run the test
        Test.startTest();

        MergeService.getInstance('Account').mergeMany(new List<List<Id>> {
            new List<Id> { acmeCorp.Id, acmeInc.Id },
            new List<Id> { zenCorp.Id, zenInc.Id, zenLlc.Id }
        });

        // Validate results
        Test.stopTest();

        List<Account> acmeAccounts = [
            SELECT Id, Name, Website, Phone, Fax
            FROM Account
            WHERE Name LIKE 'Acme%'
        ];

        System.assertEquals(1, acmeAccounts.size());
        System.assertEquals(acmeCorp.Id, acmeAccounts[0].Id);
        System.assertEquals('Acme Corporation (TEST)', acmeAccounts[0].Name);

        if (hasCannedAccountWebsiteConcern()) {
            System.assertEquals('https://therealacme.test', acmeAccounts[0].Website);
        }

        if (hasCannedAccountPhoneConcern()) {
            System.assertEquals('(800) BUY-ACME', acmeAccounts[0].Phone);
        }

        if (hasCannedAccountFaxConcern()) {
            System.assertEquals(null, acmeAccounts[0].Fax);
        }

        List<Account> zenAccounts = [
            SELECT Id, Name, Website, Phone, Fax
            FROM Account
            WHERE Name LIKE 'Zenith%'
        ];

        System.assertEquals(1, zenAccounts.size());
        System.assertEquals(zenCorp.Id, zenAccounts[0].Id);
        System.assertEquals('Zenith Corporation (TEST)', zenAccounts[0].Name);

        if (hasCannedAccountWebsiteConcern()) {
            System.assertEquals('https://zenith.inc', zenAccounts[0].Website);
        }

        if (hasCannedAccountPhoneConcern()) {
            System.assertEquals('(800) GOOD-ZEN', zenAccounts[0].Phone);
        }

        if (hasCannedAccountFaxConcern()) {
            System.assertEquals(null, zenAccounts[0].Fax);
        }
    }

    /**
     * @return whether the canned Account: Website concern as defined in the
     *         official repo is still in the user's org. This is used to
     *         perform true validation for peace of mind to get 100% code
     *         coverage as well in the official repo.
     */
    private static Boolean hasCannedAccountFaxConcern() {
        return ![
            SELECT Id
            FROM MergeConcern__mdt
            WHERE SobjectName__c = 'Account'
            AND FieldName__c = 'Fax'
            AND IsForceOverwrite__c = TRUE
        ].isEmpty();
    }

    /**
     * @return whether the canned Account: Website concern as defined in the
     *         official repo is still in the user's org. This is used to
     *         perform true validation for peace of mind to get 100% code
     *         coverage as well in the official repo.
     */
    private static Boolean hasCannedAccountPhoneConcern() {
        return ![
            SELECT Id
            FROM MergeConcern__mdt
            WHERE SobjectName__c = 'Account'
            AND FieldName__c = 'Phone'
            AND IsForceOverwrite__c = FALSE
        ].isEmpty();
    }

    /**
     * @return whether the canned Account: Website concern as defined in the
     *         official repo is still in the user's org. This is used to
     *         perform true validation for peace of mind to get 100% code
     *         coverage as well in the official repo.
     */
    private static Boolean hasCannedAccountWebsiteConcern() {
        return ![
            SELECT Id
            FROM MergeConcern__mdt
            WHERE SobjectName__c = 'Account'
            AND FieldName__c = 'Website'
            AND IsForceOverwrite__c = FALSE
        ].isEmpty();
    }
}