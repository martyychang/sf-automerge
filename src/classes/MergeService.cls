global with sharing class MergeService {

    /**
     * A singleton instance of the service
     */
    public static Map<String, MergeService> instancesByName =
            new Map<String, MergeService>();

    /**
     * The list of merge concerns which are considered by this instance
     */
    private List<MergeConcern__mdt> concerns { get; set; }

    /**
     * The full API name for the object managed by this merge service.
     * As of API 40.0 the only supported objects are Lead, Account and Contact.
     */
    private String sobjectName { get; set; }

    /**
     * Remember the object name for the merge service
     *
     * @param 
     */
    public MergeService(String sobjectName) {
        this.sobjectName = sobjectName;
        this.concerns = [
            SELECT Id, FieldName__c, IsForceOverwrite__c
            FROM MergeConcern__mdt
            WHERE SobjectName__c = :sobjectName
        ];
    }

    /**
     * @return the matching records, with all fields required to evaluate
     *         and manage merge concerns
     */
    private String getQuery() {

        // Compile a list of the field names for merge concerns
        List<String> fieldNames = new List<String> { 'Id' };

        for (MergeConcern__mdt eachConcern : this.concerns) {
            fieldNames.add(eachConcern.FieldName__c);
        }

        String selectClause = 'SELECT ' + String.join(fieldNames, ', ');

        // Return the fully constructed SOQL statement
        return String.join(new List<String> {
            selectClause,
            'FROM',
            this.sobjectName,
            'WHERE Id IN :recordIds'
        }, ' ');
    }

    /**
     * @param masterRecord
     * @param mergedRecord
     */
    public void mergeOne(Sobject masterRecord, Sobject mergedRecord) {
        for (MergeConcern__mdt eachConcern : this.concerns) {

            // If a field is enumerated in the custom metadata, this implies
            // that the value from the merged record is of some value.
            // The default behavior is to overwrite-if-blank, unless the
            // Force Overwrite checkbox is checked.
            if (eachConcern.IsForceOverwrite__c
                    || masterRecord.get(eachConcern.FieldName__c) == null) {

                // Keep the value from the merged record
                masterRecord.put(eachConcern.FieldName__c,
                        mergedRecord.get(eachConcern.FieldName__c));
            }
        }

        List<Sobject> mergeParameters =
                (List<Sobject>)this.getSobjectListType().newInstance();
        
        mergeParameters.addAll(new List<Sobject> {
            masterRecord,
            mergedRecord
        });

        Database.merge(mergeParameters[0], mergeParameters[1]);
    }

    /**
     * Given a list of records, assume that the first record is the master
     * and that all subsequent records are duplicates that should be merged
     * into the master record. With this list, perform the necessary merges.
     *
     * @param records
     */
    public void mergeMany(List<Id> recordIds) {

        // Get a map of matching records, so we can faithfully recreate
        // the list of Sobject records in the necessary order.
        // This means we do not assume that a query will return records
        // in the same order as what's passed to the IN operator.
        Map<Id, Sobject> recordMap = new Map<Id, Sobject>(
                Database.query(this.getQuery()));

        // Recreate the list of Sobject records in order, then merge away
        List<Sobject> records = new List<Sobject>();

        for (Id eachId : recordIds) {
            records.add(recordMap.get(eachId));
        }

        this.mergeMany(records);
    }

    /**
     * Given a list of records, assume that the first record is the master
     * and that all subsequent records are duplicates that should be merged
     * into the master record. With this list, perform the necessary merges.
     *
     * @param records
     */
    public void mergeMany(List<Sobject> records) {
        Sobject masterRecord = records.remove(0);
        for (Sobject eachRecord : records) {
            this.mergeOne(masterRecord, eachRecord);
        }
    }

    /**
     * Given a list of lists, assume that each sublist is a list of records
     * that should be processed by the overloaded `mergeMany` method.
     * Perform all the necessary merges.
     *
     * @param recordLists
     */
    public void mergeMany(List<List<Id>> recordIdLists) {
        for (List<Id> eachList : recordIdLists) {
            this.mergeMany(eachList);
        }
    }

    /**
     * Given a list of lists, assume that each sublist is a list of records
     * that should be processed by the overloaded `mergeMany` method.
     * Perform all the necessary merges.
     *
     * @param recordLists
     */
    public void mergeMany(List<List<Sobject>> recordLists) {
        for (List<Sobject> eachList : recordLists) {
            this.mergeMany(eachList);
        }
    }

    /**
     * @param sobjectName
     *
     * @return an instance of the service
     */
    public static MergeService getInstance(String sobjectName) {
        if (!instancesByName.containsKey(sobjectName)) {
            instancesByName.put(sobjectName, new MergeService(sobjectName));
        }

        return instancesByName.get(sobjectName);
    }

    private Type getSobjectListType() {
        return Type.forName('List<' + this.sobjectName + '>');
    }
}