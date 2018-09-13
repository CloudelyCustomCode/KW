trigger CLDLY_ApprovalRequestTrigger on Apttus_Approval__Approval_Request__c (After Insert, before Update) {
    
    if(trigger.isInsert && trigger.isAfter){
        CLDLY_ApprovalRequestTriggerHandler.afterInsert(Trigger.New);
    }
    
    if(trigger.isUpdate && trigger.isbefore){
        CLDLY_ApprovalRequestTriggerHandler.beforeUpdate(Trigger.newmap, trigger.oldMap);
    }
}