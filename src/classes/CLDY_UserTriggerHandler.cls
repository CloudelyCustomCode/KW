public with sharing class CLDY_UserTriggerHandler {
	public static List<String> statusList = new List<String>{'Request','Request Approval','Submitted Request','Approved Request','Cancelled Request','In Amendment','Author Contract','Language Approval','Language Approved','Internal Signatures','Other Party Signatures','Activated','Being Amended','Being Renewed','In Renewal','Superseded','Being Terminated','Terminated','Expired','In Reconciliation','Reconciled','Internal Review','Other Party Review','Signature Declined','Ready for Signatures','Fully Signed','Provider Signed','KW Signed'};
    public Static List<String> statusCategoryList = new List<String>{'Request', 'In Authoring', 'In Signatures', 'In Filing'};
    public static void afterUpdate(map<Id, User> newUsers, map<Id, User> oldUsers){
        Set<Id> userIds = new Set<Id>(); 
        List<Apttus__APTS_Agreement__c> agrList= new List<Apttus__APTS_Agreement__c>();
        
        for(User userRec : newUsers.values()){
            if(userRec.IsActive == false){
                if(oldUsers.get(userRec.Id).IsActive == true){
                    userIds.add(userRec.Id);
                }
            }
        }
        agrList = [Select id, Name, Owner.Name, Ownerid, Apttus__Status__c from Apttus__APTS_Agreement__c where Ownerid in:userIds and (Apttus__Status__c in: statusList OR Apttus__Status_Category__c in: statusCategoryList)];
        Set<Id> agrIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c agr : agrList){
            agrIds.add(agr.Id);
        }
        if(!agrIds.isEmpty()){
            insetNM(agrIds);
        }
    }
    
    @future
    public Static void insetNM(Set<Id> agrIds){
        List<Notification_Messages__c> nmList= new List<Notification_Messages__c>();
        List<Apttus__APTS_Agreement__c> agrList = [Select id, Name, Owner.Name, Ownerid, Apttus__Status__c from Apttus__APTS_Agreement__c where Id in:agrIds];
        
        map<id, List<Apttus__APTS_Agreement__c>> userAgreementMap = new Map<id, List<Apttus__APTS_Agreement__c>>();
        
        for(Apttus__APTS_Agreement__c agr : agrList){
            if(userAgreementMap.get(agr.Ownerid) == null){
                Notification_Messages__c nm = new Notification_Messages__c();
                nm.Message__c = 'User is Inactivated and assigned to some Agreements. Please reassign them to some other Users.';
                nm.Related_User__c = agr.ownerId;
                nm.Status__c = 'Open';
                nm.Message_Type__c = 'Related To Agreement';
                nmList.add(nm);
                List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
                agreementList.add(agr);
                userAgreementMap.put(agr.Ownerid, agreementList);
            }
            else{
                List<Apttus__APTS_Agreement__c> agreementList = userAgreementMap.get(agr.Ownerid);
                agreementList.add(agr);
                userAgreementMap.put(agr.Ownerid, agreementList);
            }
        }
        if(!nmList.isEmpty()){
            insert nmList;
            List<User_Assigned_Agreements__c> userAssignedAgreements = new List<User_Assigned_Agreements__c>();
            for(Notification_Messages__c nmRec : nmList){
                if(userAgreementMap.get(nmRec.Related_User__c) != null){
                    for(Apttus__APTS_Agreement__c agrRec : userAgreementMap.get(nmRec.Related_User__c)){
                        User_Assigned_Agreements__c assignedAgr = new User_Assigned_Agreements__c();
                        assignedAgr.Notification_Messages__c = nmRec.Id;
                        assignedAgr.Agreement_Id__c = agrRec.Id;
                        assignedAgr.Name = agrRec.Name;
                        userAssignedAgreements.add(assignedAgr);
                    }
                }
            }
            if(!userAssignedAgreements.isEmpty()){
                insert userAssignedAgreements;
            }
        }
    }
}