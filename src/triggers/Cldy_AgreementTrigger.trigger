trigger Cldy_AgreementTrigger on Apttus__APTS_Agreement__c (after update, before insert, before update) {
    if(Trigger.isUpdate && Trigger.isAfter) {  
        //Move everything inside to Handler class
        /**
        Cldy_AgreementTriggerHandler.afterUpdate(Trigger.newmap, trigger.oldmap, trigger.new);
        **/
    }
    if(Trigger.isInsert && Trigger.isBefore) {  
        //Move everything inside to Handler class
        Cldy_AgreementTriggerHandler.beforeInsert(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        Cldy_AgreementTriggerHandler.beforeUpdate(trigger.newmap, trigger.oldmap);
    }
}