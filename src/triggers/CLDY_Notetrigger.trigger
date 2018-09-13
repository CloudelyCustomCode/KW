trigger CLDY_Notetrigger on Note (after insert) {
    if(trigger.isInsert && trigger.isAfter){
        CLDY_NoteTriggerHandler.afterInsert(trigger.new);
    }
}