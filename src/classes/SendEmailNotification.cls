public class SendEmailNotification {
    public static void sendTemplatedEmail(String[] toRecipients, String templateApiName, ID agrId) {
        System.debug('Email address ********'+ toRecipients);
        Contact con = [select id, Email from Contact where email != null limit 1];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Id templateId;
        try {
            templateId = [select id, name from EmailTemplate where DeveloperName = : templateApiName].id;
        }
        catch (Exception e) {
            System.debug('Error message ********'+ e.getMessage());
        }
        msg.setWhatId(agrId);
        msg.setTargetObjectId(con.id);        
        msg.settoAddresses(toRecipients);
        msg.setTemplateId(templateId);
        lstMsgs.add(msg);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.settoAddresses(email.gettoAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            lstMsgsToSend.add(emailToSend);
        }
        try{
            Messaging.sendEmail(lstMsgsToSend);
            return;
        }
        catch (EmailException e) {
            System.debug('Error message ********'+ e.getMessage());
        }
    }
}