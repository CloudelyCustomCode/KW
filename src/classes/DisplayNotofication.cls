global with sharing class DisplayNotofication {
    public List<Notification_Messages__c> lstNott {get; set;}
    public string NotyId {get; set;}
    public static string status = 'Completed';
    public DisplayNotofication(){
       lstNott = [select Id, Message__c, Related_User__c, 
                            Related_User__r.Id, Related_User__r.Name, 
                            Message_Type__c, Status__c from 
                            Notification_Messages__c 
                            Where 
                            Status__c !=: status 
                            order by Status__c, CreatedDate desc];
    }
     
    public void ChangeMessageStatus(){
        Notification_Messages__c objNot = [select Id, Message__c, Related_User__c, Related_User__r.Name,
                                                    Related_User__r.Id,
                                                    Status__c, Message_Type__c 
                                                    from Notification_Messages__c 
                                                    where id =: NotyId 
                                                    AND
                                                    Status__c !=: status
                                                    order by Status__c, CreatedDate desc];
        If(objNot.Status__c == 'Open'){
            objNot.Status__c = 'Read';
        }
        update objNot;
        lstNott = [select Id, Message__c, Related_User__c, Related_User__r.Id, Related_User__r.Name, 
                        Status__c, Message_Type__c from 
                        Notification_Messages__c 
                        Where 
                        Status__c !=: status 
                        order by Status__c, CreatedDate desc];
    }
}