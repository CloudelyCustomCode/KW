trigger CLDY_UserTrigger on User (after update) {
    if(trigger.isupdate){
        CLDY_UserTriggerHandler.afterUpdate(trigger.newmap, trigger.oldmap);
    }
}