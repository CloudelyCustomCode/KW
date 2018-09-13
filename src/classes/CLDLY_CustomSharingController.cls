public class CLDLY_CustomSharingController {
    
    @future
    public static void shareRecords(Set<Id> recordIds, String objectName, String recordEvent) {
        //String testingRecordId = 'a1v0R0000003evw';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<Custom_Share__c> customShareRecords = [Select Id, 
                                                            Is_Active__c,
                                                            Object_Entry_Criteria__c,
                                                            Object_Name__c,
                                                            Records_Entry_Criteria__c,
                                                            Remove_Old_Share_Records__c,
                                                            Share_JSON__c,
                                                            Share_RowCause__c,
                                                            Remove_Share_JSON__c,
                                                            Access_Level__c
                                                            from 
                                                            Custom_Share__c
                                                            Where
                                                            Object_Name__c =: objectName.trim()
                                                            And 
                                                            Is_Active__c = true];
                                                            //AND 
                                                            //Id =: testingRecordId];
        if(!customShareRecords.isEmpty()) {
            String objectFields = getObjectFieldNames(objectName.trim());
            for(Custom_Share__c customShareRec : customShareRecords) {
                if(customShareRec.Records_Entry_Criteria__c != null) {
                    String objectQuery = 'Select ' + objectFields + ' From ' + objectName + ' Where (' + customShareRec.Records_Entry_Criteria__c + ') AND (ID IN: recordIds)';
                    system.debug('the query is' + objectQuery);
                    List<Sobject> recordsToShare = Database.query(objectQuery);
                    if(!recordsToShare.isEmpty()) {
                        if(customShareRec.Share_JSON__c != null || customShareRec.Remove_Share_JSON__c != null) {
                            List<Sobject> shareRecordsToInsert = new List<Sobject>();
                            Set<Id> existingShareIdsToDelete = new Set<Id>();
                            List<Sobject> existingShareRecordsToDelete = new List<Sobject>();
                            Map<String, Sobject> existingShareRecordsMap = new Map<String, Sobject>();
                            String ShareObjectName = objectName.replace('__c', '__Share');
                            Schema.SObjectType ShareObjectType = schemaMap.get(ShareObjectName);
                            String rowCause = 'Manual';
                            String existingSharesQuery = 'SELECT AccessLevel, Id, ParentId, RowCause, UserOrGroupId FROM ' + ShareObjectName + ' Where RowCause =: rowCause and ParentId IN: recordIds';
                            List<Sobject> existingShareRecords = Database.query(existingSharesQuery);
                            for(Sobject existingShareRec : existingShareRecords){
                                String userOrGroupId = String.valueOf(existingShareRec.get('UserOrGroupId'));
                                String finalUserOrGroupId = '';
                                if(userOrGroupId.length() > 15){
                                    finalUserOrGroupId = userOrGroupId.substring(0, 15);
                                }
                                else{
                                    finalUserOrGroupId = userOrGroupId;
                                }
                                existingShareRecordsMap.put(existingShareRec.get('ParentId') + '' + finalUserOrGroupId, existingShareRec);
                            }
                            
                            system.debug('the existing share record map is' + existingShareRecordsMap);
                            
                            List<String> userLookUpFields = new List<String>();
                            List<String> userIds = new List<String>();
                            List<String> groupIds = new List<String>();
                            List<String> removeUserLookUpFields = new List<String>();
                            List<String> removeUserIds = new List<String>();
                            List<String> removeGroupIds = new List<String>();
                            
                            if(customShareRec.Share_JSON__c != null){
                                system.debug('the share record id is' + customShareRec.Id);
                                system.debug('the share JSON is' + customShareRec.Share_JSON__c);
                                CLDLY_ShareJSONParserController shareDetails = CLDLY_ShareJSONParserController.parse(customShareRec.Share_JSON__c);
                                system.debug('the share details are' + shareDetails);
                                if(shareDetails.Object_UserLookUps != null) {
                                    userLookUpFields = shareDetails.Object_UserLookUps.split(',');
                                }
                                if(shareDetails.UserIds != null) {
                                    userIds = shareDetails.userIds.split(',');
                                }
                                if(shareDetails.GroupIds != null) {
                                    groupIds = shareDetails.groupIds.split(',');
                                }
                            }
                            
                            if(customShareRec.Remove_Share_JSON__c != null){
                                CLDLY_ShareJSONParserController removeShareDetails = CLDLY_ShareJSONParserController.parse(customShareRec.Remove_Share_JSON__c);
                                if(removeShareDetails.Object_UserLookUps != null) {
                                    removeUserLookUpFields = removeShareDetails.Object_UserLookUps.split(',');
                                }
                                if(removeShareDetails.UserIds != null) {
                                    removeUserIds = removeShareDetails.userIds.split(',');
                                }
                                if(removeShareDetails.GroupIds != null) {
                                    removeGroupIds = removeShareDetails.groupIds.split(',');
                                }
                            }
                            
                            for(sobject record : recordsToShare) {
                                if(!userLookUpFields.isEmpty()) {
                                    for(String userLookUpField : userLookUpFields) {
                                        if(userLookUpField != null && userLookUpField != ''){
                                            system.debug('the user look up field is' + userLookUpField);
                                            if(record.get(userLookUpField) != null) {
                                                Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                                ShareObjectInstance.put('ParentId', record.get('Id'));
                                                ShareObjectInstance.put('UserOrGroupId', record.get(userLookUpField));
                                                ShareObjectInstance.put('RowCause', 'Manual');
                                                if(customShareRec.Access_Level__c != null) {
                                                    ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                                }
                                                else {
                                                    ShareObjectInstance.put('AccessLevel', 'Read');
                                                }
                                                shareRecordsToInsert.add(ShareObjectInstance);
                                            }
                                        }
                                    }
                                }
                                if(!userIds.isEmpty()) {
                                    for(String userId : userIds) {
                                        if(userId != null && userId != ''){
                                            Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                            ShareObjectInstance.put('ParentId', record.get('Id'));
                                            ShareObjectInstance.put('UserOrGroupId', userId);
                                            ShareObjectInstance.put('RowCause', 'Manual');
                                            if(customShareRec.Access_Level__c != null) {
                                                ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                            }
                                            else{
                                                ShareObjectInstance.put('AccessLevel', 'Read');
                                            }
                                            shareRecordsToInsert.add(ShareObjectInstance);
                                        }
                                    }
                                }
                                if(!groupIds.isEmpty()) {
                                    for(String groupId : groupIds) {
                                        if(groupId != null && groupId != ''){
                                            Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                            ShareObjectInstance.put('ParentId', record.get('Id'));
                                            ShareObjectInstance.put('UserOrGroupId', groupId);
                                            ShareObjectInstance.put('RowCause', 'Manual');
                                            if(customShareRec.Access_Level__c != null) {
                                                ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                            }
                                            else {
                                                ShareObjectInstance.put('AccessLevel', 'Read');
                                            }
                                            shareRecordsToInsert.add(ShareObjectInstance);
                                        }
                                    }
                                }
                                
                                if(!removeUserLookUpFields.isEmpty()) {
                                    for(String removeUserLookUpField : removeUserLookUpFields) {
                                        //system.debug('the removeUserLookUpField is' + removeUserLookUpField);
                                        if(removeUserLookUpField != null && removeUserLookUpField != ''){
                                            if(record.get(removeUserLookUpField) != null) {
                                                String userId = String.valueOf(record.get(removeUserLookUpField));
                                                String finalUserId = '';
                                                if(userId.length() > 15){
                                                    finalUserId = userId.substring(0, 15);
                                                }
                                                else{
                                                    finalUserId = userId;
                                                }
                                                //system.debug('the lookup field id is' + record.get(removeUserLookUpField));
                                                if(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId) != null){
                                                    //system.debug('debug logs here');
                                                    existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId));
                                                }
                                            }
                                        }
                                    }
                                }
                                if(!removeUserIds.isEmpty()) {
                                    for(String removeUserId : removeUserIds) {
                                        if(removeUserId != null && removeUserId != ''){
                                            //String userId = String.valueOf(record.get(removeUserLookUpField));
                                            String finalUserId = '';
                                            if(removeUserId.length() > 15){
                                                finalUserId = removeUserId.substring(0, 15);
                                            }
                                            else{
                                                finalUserId = removeUserId;
                                            }
                                            
                                            if(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId) != null){
                                                existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId));
                                            }
                                        }
                                    }
                                }
                                if(!removeGroupIds.isEmpty()) {
                                    for(String removeGroupId : removeGroupIds) {
                                        if(removeGroupId != null && removeGroupId != ''){
                                            String finalGroupId = '';
                                            if(removeGroupId.length() > 15){
                                                finalGroupId = removeGroupId.substring(0, 15);
                                            }
                                            else{
                                                finalGroupId = removeGroupId;
                                            }
                                            if(existingShareRecordsMap.get(record.get('Id') + '' + finalGroupId) != null){
                                                existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalGroupId));
                                            }
                                        }
                                    }
                                }
                            }
                            if(!shareRecordsToInsert.isEmpty()) {
                                Database.SaveResult[] srList = Database.insert(shareRecordsToInsert, false);
                                for(Database.SaveResult sr : srList) {
                                    if(sr.isSuccess()) {
                                        System.debug('Successfully inserted share. Share ID: ' + sr.getId());
                                    }
                                    else {
                                        for(Database.Error err : sr.getErrors()) {
                                            System.debug('The following error has occurred.');                   
                                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                            System.debug('Share fields that affected this error: ' + err.getFields());
                                        }
                                    }
                                }
                            }
                            if(!existingShareRecordsToDelete.isEmpty()){
                                try{
                                    Database.DeleteResult[] srDeleteList = Database.Delete(existingShareRecordsToDelete, false);
                                    for(Database.DeleteResult sr : srDeleteList) {
                                        if(sr.isSuccess()) {
                                            System.debug('Successfully delete share. Share ID: ' + sr.getId());
                                        }
                                        else {
                                            for(Database.Error err : sr.getErrors()) {
                                                System.debug('The following error has occurred.');                   
                                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                System.debug('Share fields that affected this error: ' + err.getFields());
                                            }
                                        }
                                    }
                                }
                                catch(Exception exp){
                                    System.debug('Delete Exception is: ' + exp.getMessage());
                                }
                            }
                        }
                    }
                }
            } 
        }
    }
    
    
    public static void shareRecordsWithNoFuture(Set<Id> recordIds, String objectName, String recordEvent) {
        //String testingRecordId = 'a1v0R0000003evw';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<Custom_Share__c> customShareRecords = [Select Id, 
                                                            Is_Active__c,
                                                            Object_Entry_Criteria__c,
                                                            Object_Name__c,
                                                            Records_Entry_Criteria__c,
                                                            Remove_Old_Share_Records__c,
                                                            Share_JSON__c,
                                                            Share_RowCause__c,
                                                            Remove_Share_JSON__c,
                                                            Access_Level__c
                                                            from 
                                                            Custom_Share__c
                                                            Where
                                                            Object_Name__c =: objectName.trim()
                                                            And 
                                                            Is_Active__c = true];
                                                            //AND 
                                                            //Id =: testingRecordId];
        if(!customShareRecords.isEmpty()) {
            String objectFields = getObjectFieldNames(objectName.trim());
            for(Custom_Share__c customShareRec : customShareRecords) {
                if(customShareRec.Records_Entry_Criteria__c != null) {
                    String objectQuery = 'Select ' + objectFields + ' From ' + objectName + ' Where (' + customShareRec.Records_Entry_Criteria__c + ') AND (ID IN: recordIds)';
                    system.debug('the query is' + objectQuery);
                    List<Sobject> recordsToShare = Database.query(objectQuery);
                    if(!recordsToShare.isEmpty()) {
                        if(customShareRec.Share_JSON__c != null || customShareRec.Remove_Share_JSON__c != null) {
                            List<Sobject> shareRecordsToInsert = new List<Sobject>();
                            Set<Id> existingShareIdsToDelete = new Set<Id>();
                            List<Sobject> existingShareRecordsToDelete = new List<Sobject>();
                            Map<String, Sobject> existingShareRecordsMap = new Map<String, Sobject>();
                            String ShareObjectName = objectName.replace('__c', '__Share');
                            Schema.SObjectType ShareObjectType = schemaMap.get(ShareObjectName);
                            String rowCause = 'Manual';
                            String existingSharesQuery = 'SELECT AccessLevel, Id, ParentId, RowCause, UserOrGroupId FROM ' + ShareObjectName + ' Where RowCause =: rowCause and ParentId IN: recordIds';
                            List<Sobject> existingShareRecords = Database.query(existingSharesQuery);
                            for(Sobject existingShareRec : existingShareRecords){
                                existingShareRecordsMap.put(existingShareRec.get('ParentId') + '' + existingShareRec.get('UserOrGroupId'), existingShareRec);
                            }
                            
                            system.debug('the existing share record map is' + existingShareRecordsMap);
                            
                            List<String> userLookUpFields = new List<String>();
                            List<String> userIds = new List<String>();
                            List<String> groupIds = new List<String>();
                            List<String> removeUserLookUpFields = new List<String>();
                            List<String> removeUserIds = new List<String>();
                            List<String> removeGroupIds = new List<String>();
                            
                            if(customShareRec.Share_JSON__c != null){
                                system.debug('the share record id is' + customShareRec.Id);
                                system.debug('the share JSON is' + customShareRec.Share_JSON__c);
                                CLDLY_ShareJSONParserController shareDetails = CLDLY_ShareJSONParserController.parse(customShareRec.Share_JSON__c);
                                system.debug('the share details are' + shareDetails);
                                if(shareDetails.Object_UserLookUps != null) {
                                    userLookUpFields = shareDetails.Object_UserLookUps.split(',');
                                }
                                if(shareDetails.UserIds != null) {
                                    userIds = shareDetails.userIds.split(',');
                                }
                                if(shareDetails.GroupIds != null) {
                                    groupIds = shareDetails.groupIds.split(',');
                                }
                            }
                            
                            if(customShareRec.Remove_Share_JSON__c != null){
                                CLDLY_ShareJSONParserController removeShareDetails = CLDLY_ShareJSONParserController.parse(customShareRec.Remove_Share_JSON__c);
                                if(removeShareDetails.Object_UserLookUps != null) {
                                    removeUserLookUpFields = removeShareDetails.Object_UserLookUps.split(',');
                                }
                                if(removeShareDetails.UserIds != null) {
                                    removeUserIds = removeShareDetails.userIds.split(',');
                                }
                                if(removeShareDetails.GroupIds != null) {
                                    removeGroupIds = removeShareDetails.groupIds.split(',');
                                }
                            }
                            
                            for(sobject record : recordsToShare) {
                                if(!userLookUpFields.isEmpty()) {
                                    for(String userLookUpField : userLookUpFields) {
                                        if(userLookUpField != null && userLookUpField != ''){
                                            system.debug('the user look up field is' + userLookUpField);
                                            if(record.get(userLookUpField) != null) {
                                                Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                                ShareObjectInstance.put('ParentId', record.get('Id'));
                                                ShareObjectInstance.put('UserOrGroupId', record.get(userLookUpField));
                                                ShareObjectInstance.put('RowCause', 'Manual');
                                                if(customShareRec.Access_Level__c != null) {
                                                    ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                                }
                                                else {
                                                    ShareObjectInstance.put('AccessLevel', 'Read');
                                                }
                                                shareRecordsToInsert.add(ShareObjectInstance);
                                            }
                                        }
                                    }
                                }
                                if(!userIds.isEmpty()) {
                                    for(String userId : userIds) {
                                        if(userId != null && userId != ''){
                                            Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                            ShareObjectInstance.put('ParentId', record.get('Id'));
                                            ShareObjectInstance.put('UserOrGroupId', userId);
                                            ShareObjectInstance.put('RowCause', 'Manual');
                                            if(customShareRec.Access_Level__c != null) {
                                                ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                            }
                                            else{
                                                ShareObjectInstance.put('AccessLevel', 'Read');
                                            }
                                            shareRecordsToInsert.add(ShareObjectInstance);
                                        }
                                    }
                                }
                                if(!groupIds.isEmpty()) {
                                    for(String groupId : groupIds) {
                                        if(groupId != null && groupId != ''){
                                            Sobject ShareObjectInstance = ShareObjectType.newSobject();
                                            ShareObjectInstance.put('ParentId', record.get('Id'));
                                            ShareObjectInstance.put('UserOrGroupId', groupId);
                                            ShareObjectInstance.put('RowCause', 'Manual');
                                            if(customShareRec.Access_Level__c != null) {
                                                ShareObjectInstance.put('AccessLevel', customShareRec.Access_Level__c);
                                            }
                                            else {
                                                ShareObjectInstance.put('AccessLevel', 'Read');
                                            }
                                            shareRecordsToInsert.add(ShareObjectInstance);
                                        }
                                    }
                                }
                                
                                if(!removeUserLookUpFields.isEmpty()) {
                                    for(String removeUserLookUpField : removeUserLookUpFields) {
                                        system.debug('the removeUserLookUpField is' + removeUserLookUpField);
                                        if(removeUserLookUpField != null && removeUserLookUpField != ''){
                                            if(record.get(removeUserLookUpField) != null) {
                                                String userId = String.valueOf(record.get(removeUserLookUpField));
                                                String finalUserId = '';
                                                if(userId.length() > 15){
                                                    finalUserId = userId.substring(0, 15);
                                                }
                                                else{
                                                    finalUserId = userId;
                                                }
                                                //system.debug('the lookup field id is' + record.get(removeUserLookUpField));
                                                if(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId) != null){
                                                    //system.debug('debug logs here');
                                                    existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId));
                                                }
                                            }
                                        }
                                    }
                                }
                                if(!removeUserIds.isEmpty()) {
                                    
                                    for(String removeUserId : removeUserIds) {
                                        /**system.debug('the remove userids are' + removeUserId);
                                        if(removeUserId != null && removeUserId != ''){
                                            if(existingShareRecordsMap.get(record.get('Id') + '' + removeUserId) != null){
                                                existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + removeUserId));
                                            }
                                        }**/
                                        
                                        String finalUserId = '';
                                        if(removeUserId.length() > 15){
                                            finalUserId = removeUserId.substring(0, 15);
                                        }
                                        else{
                                            finalUserId = removeUserId;
                                        }
                                        if(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId) != null){
                                            existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalUserId));
                                        }
                                    }
                                }
                                if(!removeGroupIds.isEmpty()) {
                                    for(String removeGroupId : removeGroupIds) {
                                        /**if(removeGroupId != null && removeGroupId != ''){
                                            if(existingShareRecordsMap.get(record.get('Id') + '' + removeGroupId) != null){
                                                existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + removeGroupId));
                                            }
                                        }**/
                                        if(removeGroupId != null && removeGroupId != ''){
                                            String finalGroupId = '';
                                            if(removeGroupId.length() > 15){
                                                finalGroupId = removeGroupId.substring(0, 15);
                                            }
                                            else{
                                                finalGroupId = removeGroupId;
                                            }
                                            if(existingShareRecordsMap.get(record.get('Id') + '' + finalGroupId) != null){
                                                existingShareRecordsToDelete.add(existingShareRecordsMap.get(record.get('Id') + '' + finalGroupId));
                                            }
                                        }
                                    }
                                }
                            }
                            if(!shareRecordsToInsert.isEmpty()) {
                                Database.SaveResult[] srList = Database.insert(shareRecordsToInsert, false);
                                for(Database.SaveResult sr : srList) {
                                    if(sr.isSuccess()) {
                                        System.debug('Successfully inserted share. Share ID: ' + sr.getId());
                                    }
                                    else {
                                        for(Database.Error err : sr.getErrors()) {
                                            System.debug('The following error has occurred.');                   
                                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                            System.debug('Share fields that affected this error: ' + err.getFields());
                                        }
                                    }
                                }
                            }
                            if(!existingShareRecordsToDelete.isEmpty()){
                                try{
                                    Database.DeleteResult[] srDeleteList = Database.Delete(existingShareRecordsToDelete, false);
                                    for(Database.DeleteResult sr : srDeleteList) {
                                        if(sr.isSuccess()) {
                                            System.debug('Successfully delete share. Share ID: ' + sr.getId());
                                        }
                                        else {
                                            for(Database.Error err : sr.getErrors()) {
                                                System.debug('The following error has occurred.');                   
                                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                System.debug('Share fields that affected this error: ' + err.getFields());
                                            }
                                        }
                                    }
                                }
                                catch(Exception exp){
                                    System.debug('Delete Exception is: ' + exp.getMessage());
                                }
                            }
                        }
                    }
                }
            } 
        }
    }
    
    public static string getObjectFieldNames(String objectName) {
        String objectfields = '';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> objectFieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField objectFieldRec : objectFieldMap.Values()) {
            schema.describefieldresult objectfield = objectFieldRec.getDescribe();
            if(objectfields == '') {
                objectfields = objectfield.getName();
            }
            else {
                objectfields = objectfields + ',' + objectfield.getName();
            }
        }
        return objectfields;
    }
}