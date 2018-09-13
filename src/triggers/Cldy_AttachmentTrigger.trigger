trigger Cldy_AttachmentTrigger on Attachment (after insert) {
    if(Trigger.isinsert && trigger.isafter){
        Cldy_AttachmentTriggerHandler.afterUpdate(trigger.new); 
    }
}