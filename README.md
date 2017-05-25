The Auto-Merge Service enables developers to merge many records in one operation, while also delegating control of how fields are overwritten to admins.

## Installation

Zip up the **src** directory and deploy with [Workbench][1] or your favorite IDE.

[1]: https://workbench.developerforce.com

## Quick Start

Every instance of `MergeService` supports the following methods. Open the `MergeServiceTest` to see how to get an instance of the service and use it to perform single or bulk merge operations.

* `void mergeOne(Sobject, Sobject)`
* `void mergeMany(List<Id>)`
* `void mergeMany(List<Sobject>)`
* `void mergeMany(ListList<<Id>>)`
* `void mergeMany(List<List<Sobject>>)`

The **Merge Concerns** custom metadata type is used to control which field values are retained from merged or victim records. The default behavior for any field that doesn't have an explicitly defined concern is to discard the value from the merged record.

| Merge Concern Field | Description | Sample Value |
| ------------------- | ----------- | ------------ |
| Label | No requirements. Recommended format is "{!ObjectLabel}: {!FieldLabel}". | Account: Website |
| Merge Concern Name | No requirements other than the name must be unique. Recommended format is "{!ObjectName}{!FieldName}" with all special `__` prefixes and suffixes removed. | AccountWebsite |
| Object Name | The full API name of the object | Transaction__c |
| Field Name | The full API name of the field | SyncStatus__c |
| Force Overwrite | Whether to _always_ overwrite or retain the value from the victim record. When unchecked, the behavior is to retain the value from the victim record _only_ if the field on the survivor record is blank. | TRUE |

## Known Issues

Only leads, contacts, and accounts can be merged, as the current implementation uses the native `Database.merge` function. See "[Merging Records][2]" in the _Apex Developer Guide_.

[2]: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_examples_merge.htm?search_text=merge