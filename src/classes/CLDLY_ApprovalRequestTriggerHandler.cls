public class CLDLY_ApprovalRequestTriggerHandler {
    
    public Static void afterInsert(list<Apttus_Approval__Approval_Request__c> newApprovalRequests){
        List<string> aggrementIds = new list<string>();
        map<string,string> agreementApprovalStatusMap =  new map<string,string>(); 
        map<string,string> agreementApprovalStepLabelMap =  new map<string,string>(); 
        for(Apttus_Approval__Approval_Request__c approvalReq : newApprovalRequests){
            if(approvalReq.Apttus_Approval__Approval_Status__c != 'Not Submitted'){
                aggrementIds.add(approvalReq.Apttus_Approval__Related_Agreement__c);
                agreementApprovalStatusMap.put(approvalReq.Apttus_Approval__Related_Agreement__c , approvalReq.Apttus_Approval__Approval_Status__c);
                agreementApprovalStepLabelMap.put(approvalReq.Apttus_Approval__Related_Agreement__c, approvalReq.Apttus_Approval__StepLabel__c);
            }  
        }
        List<Apttus__APTS_Agreement__c> agreementList = [select Id, Step_Label__c, 
                                                                    Approval_Status__c 
                                                                    From 
                                                                    Apttus__APTS_Agreement__c Where Id IN: aggrementIds];
        if(!agreementList.isEmpty()){
            for(Apttus__APTS_Agreement__c agreeRec : agreementList ){
                if(agreementApprovalStatusMap.get(agreeRec.id) != null){
                    agreeRec.Approval_Status__c = agreementApprovalStatusMap.get(agreeRec.id);
                }
                if(agreementApprovalStepLabelMap.get(agreeRec.id) != null){
                    agreeRec.Step_Label__c = agreementApprovalStepLabelMap.get(agreeRec.id);
                }
            }
            update agreementList; 
        }
    } 
    
    public Static void beforeUpdate(Map<Id, Apttus_Approval__Approval_Request__c> newApprovalRequestsMap, Map<Id, Apttus_Approval__Approval_Request__c> oldApprovalRequestsMap){
        //List<Apttus__APTS_Agreement__c> Agreementlist = new List<Apttus__APTS_Agreement__c>() ;
        List<string> aggrementIds = new list<string>();
        map<string,string> agreementApprovalStatusMap =  new map<string,string>(); 
        map<string,string> agreementApprovalStepLabelMap =  new map<string,string>(); 
        map<string,string> agreementDH2ApprovalMap = new map<string,string>();
        map<string,string> agreementDH3ApprovalMap = new map<string,string>();
        //map<string,string> oldmapforSteplabel =  new map<string,string>(); 
        /**for(Apttus_Approval__Approval_Request__c oldapprovelreq : oldApprovalrequestlist){
            if(oldapprovelreq.Apttus_Approval__Approval_Status__c != 'Not Submitted' && oldapprovelreq.Apttus_Approval__Approval_Status__c != 'Null'){
                oldmapStatus.put(oldapprovelreq.Apttus_Approval__Related_Agreement__c , oldapprovelreq.Apttus_Approval__Approval_Status__c);
                //oldmapforSteplabel.put(oldapprovelreq.Apttus_Approval__Related_Agreement__c , oldapprovelreq.Apttus_Approval__StepLabel__c);
            }
        }**/
         
        for(Apttus_Approval__Approval_Request__c approvelreq : newApprovalRequestsMap.values()){
            if(approvelreq.Apttus_Approval__Approval_Status__c != 'Not Submitted'){
                if(oldApprovalRequestsMap.get(approvelreq.Id).Apttus_Approval__Approval_Status__c != approvelreq.Apttus_Approval__Approval_Status__c){
                    if(approvelreq.Apttus_Approval__StepLabel__c == 'DH 2 Approval' && approvelreq.Apttus_Approval__Approval_Status__c == 'Approved'){
                        agreementDH2ApprovalMap.put(approvelreq.Apttus_Approval__Related_Agreement__c, 'Yes');
                    }
                    if(approvelreq.Apttus_Approval__StepLabel__c == 'DH 3 Approval' && approvelreq.Apttus_Approval__Approval_Status__c == 'Approved'){
                        agreementDH3ApprovalMap.put(approvelreq.Apttus_Approval__Related_Agreement__c, 'Yes');
                    }
                    aggrementIds.add(approvelreq.Apttus_Approval__Related_Agreement__c);
                    agreementApprovalStatusMap.put(approvelreq.Apttus_Approval__Related_Agreement__c, approvelreq.Apttus_Approval__Approval_Status__c);
                    agreementApprovalStepLabelMap.put(approvelreq.Apttus_Approval__Related_Agreement__c, approvelreq.Apttus_Approval__StepLabel__c);
                }
            } 
            
            List<Apttus__APTS_Agreement__c> agreementList = [Select Id, Step_Label__c, 
                                                                        Approval_Status__c,
                                                                        DH_2_Approved__c,
                                                                        DH_3_Approved__c
                                                                        From 
                                                                        Apttus__APTS_Agreement__c 
                                                                        where Id IN: aggrementIds];
            if(!agreementList.isEmpty()){
                for(Apttus__APTS_Agreement__c agreeRec : agreementList ){
                    if(agreementApprovalStatusMap.get(agreeRec.id) != null){
                        agreeRec.Approval_Status__c = agreementApprovalStatusMap.get(agreeRec.id);
                    }
                    if(agreementApprovalStepLabelMap.get(agreeRec.id) != null){
                        agreeRec.Step_Label__c = agreementApprovalStepLabelMap.get(agreeRec.id);
                    }   
                    if(agreementDH2ApprovalMap.get(agreeRec.id) != null){
                        agreeRec.DH_2_Approved__c = true;
                    }
                    if(agreementDH3ApprovalMap.get(agreeRec.id) != null){
                        agreeRec.DH_3_Approved__c = true;
                    }
                }
                update agreementList; 
            }
        } 
    }
    
}