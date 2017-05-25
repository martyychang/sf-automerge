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