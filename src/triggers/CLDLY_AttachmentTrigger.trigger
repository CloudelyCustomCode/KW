trigger CLDLY_AttachmentTrigger on Attachment (after insert) {
    if(trigger.isInsert && trigger.isAfter){
        CLDLY_AttachmentTriggerHandler.afterInsert(trigger.new);
    }
}