@isTest
private class MergeServiceLeadTest {

    /**
     * Given that I have no Lead merge concerns and
     * two leads as follows ...
     *
     * Lead: Peter Parker (TEST)
     * - Website: 
     * - Phone: (800) MARVEL-1
     * - Fax: (800) MARVEL-2
     *
     * Lead: Amazing Spider-Man (TEST)
     * - Website: https://spiderman.test
     * - Phone: 
     * - Fax:
     *
     * ... when I merge Spider-Man (victim) into Parker (survivor),
     * no exceptions should be thrown. This test is used to validate the
     * resolution of the issue where the `Name` field was wrongly assumed
     * to be always editable.
     *
     * @see https://github.com/martyychang/sf-automerge/issues/2
     */
    @isTest
    private static void mergeOneSuccess() {

        // Define params for the test
        Lead parker = new Lead(
                FirstName = 'Peter',
                LastName = 'Parker (TEST)',
                Company = 'Marvel Universe (TEST)',
                Website = null,
                Phone = '(800) MARVEL-1',
                Fax = '(800) MARVEL-2');
        
        Lead spidey = new Lead(
                FirstName = 'Amazing',
                LastName = 'Spider-Man (TEST)',
                Company = 'Marvel Universe (TEST)',
                Website = 'https://spiderman.test',
                Phone = null,
                Fax = null);

        insert new List<Lead> { parker, spidey };

        // Run the test
        Test.startTest();

        MergeService.getInstance(
                Schema.SObjectType.Lead.getName()).mergeOne(parker, spidey);

        // Validate results
        Test.stopTest();

        List<Lead> parkerLeads = [
            SELECT Id, Website, Phone, IsDeleted
            FROM Lead
            WHERE LastName = 'Parker (TEST)'
            ALL ROWS
        ];

        System.assertEquals(1, parkerLeads.size(),
                'number of Parker leads');
        System.assertEquals(false, parkerLeads[0].IsDeleted,
                'Parker is deleted');

        List<Lead> spideyLeads = [
            SELECT Id, IsDeleted
            FROM Lead
            WHERE LastName = 'Spider-Man (TEST)'
            ALL ROWS
        ];

        System.assertEquals(1, spideyLeads.size(),
                'number of Spider-Man leads');
        System.assertEquals(true, spideyLeads[0].IsDeleted,
                'Spider-Man is deleted');
    }

    /**
     * Given that I have no Lead merge concerns and
     * two leads as follows ...
     *
     * Lead: Peter Parker (TEST)
     * - Website: 
     * - Phone: (800) MARVEL-1
     * - Fax: (800) MARVEL-2
     *
     * Lead: Amazing Spider-Man (TEST)
     * - Website: https://spiderman.test
     * - Phone: 
     * - Fax:
     *
     * ... when I merge Spider-Man (victim) into Parker (survivor),
     * no exceptions should be thrown. This test is used to validate the
     * resolution of the issue where the Account object was hard-coded
     * into the query which retrieved records with merge concern fields.
     *
     * @see https://github.com/martyychang/sf-automerge/issues/1
     */
    @isTest
    private static void mergeManySuccess() {

        // Define params for the test
        Lead parker = new Lead(
                FirstName = 'Peter',
                LastName = 'Parker (TEST)',
                Company = 'Marvel Universe (TEST)',
                Website = null,
                Phone = '(800) MARVEL-1',
                Fax = '(800) MARVEL-2');
        
        Lead spidey = new Lead(
                FirstName = 'Amazing',
                LastName = 'Spider-Man (TEST)',
                Company = 'Marvel Universe (TEST)',
                Website = 'https://spiderman.test',
                Phone = null,
                Fax = null);

        insert new List<Lead> { parker, spidey };

        // Run the test
        Test.startTest();

        MergeService.getInstance(
                Schema.SObjectType.Lead.getName()).mergeMany(
                        new List<Id> { parker.Id, spidey.Id });

        // Validate results
        Test.stopTest();

        List<Lead> parkerLeads = [
            SELECT Id, Website, Phone, IsDeleted
            FROM Lead
            WHERE LastName = 'Parker (TEST)'
            ALL ROWS
        ];

        System.assertEquals(1, parkerLeads.size(),
                'number of Parker leads');
        System.assertEquals(false, parkerLeads[0].IsDeleted,
                'Parker is deleted');

        List<Lead> spideyLeads = [
            SELECT Id, IsDeleted
            FROM Lead
            WHERE LastName = 'Spider-Man (TEST)'
            ALL ROWS
        ];

        System.assertEquals(1, spideyLeads.size(),
                'number of Spider-Man leads');
        System.assertEquals(true, spideyLeads[0].IsDeleted,
                'Spider-Man is deleted');
    }
}