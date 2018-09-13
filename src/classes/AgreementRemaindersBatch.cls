global class AgreementRemaindersBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String agreementId = 'a010R000002KF8r';
        DescribeSObjectResult objectfields = Apttus__APTS_Agreement__c.getSObjectType().getDescribe();     
        List<String> fieldNames = new List<String>( objectfields.fields.getMap().keySet() );
        String query = 'SELECT ' + String.join( fieldNames, ',' ) + ' FROM Apttus__APTS_Agreement__c Where Turnoff_Notifications__c = false';
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext BC, List<Apttus__APTS_Agreement__c> agrList){
        boolean updateAgreement = true;
        List<Notifications__c> ntfList = new List<Notifications__c>();
        ntfList = [Select Id, Name, Email_Address__c, Email_Template_Name__c, 
                        Remainder_Before_Days__c, Trigger_Date_Field__c, IsRecurrence__c, Valid_Status__c,
                        Recurrence_Days__c, Next_Recurrence_Date_Field__c from Notifications__c Where Is_Active__c = true];
                                
        for(Apttus__APTS_Agreement__c agr : agrList){
            for(Notifications__c ntf : ntfList){
                if(!ntf.IsRecurrence__c){
                    if(ntf.Valid_Status__c != null && ntf.Valid_Status__c != ''){
                        Set<String> statusSet = new Set<String>();
                        List<String> statusLst = ntf.Valid_Status__c.split(';');
                        if(statusLst.size() > 0){
                            for(String statusValue : statusLst){
                                statusSet.add(statusValue.trim());
                            }
                        }
                        else{
                           statusSet.add(ntf.Valid_Status__c.trim()); 
                        }
                        if(statusSet.contains(agr.Apttus__Status__c)){
                            if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                                if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                    if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                        Date agreementEndDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                        
                                        system.debug('agreement end date is' + agreementEndDate);
                                        system.debug('agreement final date is' + system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c)));
                                        
                                        if(agreementEndDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                            SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                            if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                    Date agreementEndDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                    if(agreementEndDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                        SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                    if(ntf.Valid_Status__c != null && ntf.Valid_Status__c != ''){
                        Set<String> statusSet = new Set<String>();
                        List<String> statusLst = ntf.Valid_Status__c.split(';');
                        if(statusLst.size() > 0){
                            for(String statusValue : statusLst){
                                statusSet.add(statusValue.trim());
                            }
                        }
                        else{
                           statusSet.add(ntf.Valid_Status__c.trim()); 
                        }
                        if(statusSet.contains(agr.Apttus__Status__c)){
                            if(ntf.Next_Recurrence_Date_Field__c != null && ntf.Next_Recurrence_Date_Field__c != ''){
                                if((Date)agr.get(ntf.Next_Recurrence_Date_Field__c) != null){
                                    Date recurrenceEmailDate = (Date)agr.get(ntf.Next_Recurrence_Date_Field__c);
                                    if(system.today() == recurrenceEmailDate){
                                        SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                        if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                            agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                            updateAgreement = true;
                                        }
                                    }
                                }
                                else{
                                    if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                                        if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                            if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                                Date agreementDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                                if(agreementDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                                    SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                                    if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                                        agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                                        updateAgreement = true;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                                    if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                        if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                            Date agreementDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                            if(agreementDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                                SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                                if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                                    agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                                    updateAgreement = true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            if(ntf.Next_Recurrence_Date_Field__c != null && ntf.Next_Recurrence_Date_Field__c != ''){
                                if((Date)agr.get(ntf.Next_Recurrence_Date_Field__c) != null){
                                    Date recurrenceEmailDate = (Date)agr.get(ntf.Next_Recurrence_Date_Field__c);
                                    if(system.today() == recurrenceEmailDate){
                                        SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                        if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                            agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                            updateAgreement = true;
                                        }
                                    }
                                }
                                else{
                                    if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                                        if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                            if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                                Date agreementDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                                if(agreementDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                                    SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                                    if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                                        agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                                        updateAgreement = true;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                if(ntf.Trigger_Date_Field__c != null && ntf.Trigger_Date_Field__c != ''){
                                    if((Date)agr.get(ntf.Trigger_Date_Field__c) != null){
                                        if(ntf.Remainder_Before_Days__c != null && ntf.Remainder_Before_Days__c != ''){
                                            Date agreementDate = (Date)agr.get(ntf.Trigger_Date_Field__c);
                                            if(agreementDate == system.today().adddays(Integer.valueOf(ntf.Remainder_Before_Days__c))){
                                                SendEmailNotification.sendTemplatedEmail(extractEmails(ntf.Email_Address__c, agr), ntf.Email_Template_Name__c, agr.id);
                                                if(ntf.Recurrence_Days__c != null && ntf.Recurrence_Days__c != ''){
                                                    agr.put(ntf.Next_Recurrence_Date_Field__c, system.today().adddays(Integer.valueOf(ntf.Recurrence_Days__c)));
                                                    updateAgreement = true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(updateAgreement){
            if(agrList.size()>0){
                update agrList; 
            }
        }
    }  
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    global static List<String> extractEmails(String emailJsonString, Apttus__APTS_Agreement__c agreementRec){
        
        EmailJSON emailJsonParser = EmailJSON.parse(emailJsonString);
        List<String> Emailids = new List<String>();
        if(emailJsonParser.Email != null && emailJsonParser.Email != ''){
            List<String> emails = emailJsonParser.Email.split(',');
            if(emails.size() > 0){
                for(String email : emails){
                    Emailids.add(email);
                }
            }
            else{
                Emailids.add(emailJsonParser.Email);
            }
        } 
        if(emailJsonParser.Agreement_User_Lookup_Fields != null && emailJsonParser.Agreement_User_Lookup_Fields != ''){
            Set<Id> userIds = new Set<Id>();
            List<String> userLookUps = emailJsonParser.Agreement_User_Lookup_Fields.split(',');
            if(userLookUps.size() > 0){
                for(String userLookUpRec : userLookUps){
                    if(agreementRec.get(userLookUpRec.trim()) != null){
                        userIds.add((String)agreementRec.get(userLookUpRec.trim()));
                    }
                }
            }
            else{
                if(agreementRec.get(emailJsonParser.Agreement_User_Lookup_Fields.trim()) != null){
                    userIds.add((String)agreementRec.get(emailJsonParser.Agreement_User_Lookup_Fields.trim()));
                }
            }
            List<User> userRecords = [Select Id, Email from User Where Id IN: userIds];
            for(User userRec : userRecords){
                Emailids.add(userRec.Email);
            }
        }
        return Emailids;
    }
}