trigger UpdateApprovalStatus on Apttus_Approval__Approval_Request__c (After Insert,After Update) {
    
   if(trigger.isInsert && trigger.isAfter){
    UpdateApprovalStatusTriggerhandler.statusafterinsert(Trigger.New);
    }
     if(trigger.isUpdate && trigger.isAfter){
     UpdateApprovalStatusTriggerhandler.statusafterupdate(Trigger.New, Trigger.old);
    }
}