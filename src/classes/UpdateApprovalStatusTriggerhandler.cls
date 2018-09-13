public class UpdateApprovalStatusTriggerhandler {
   
    public Static void statusafterinsert(list<Apttus_Approval__Approval_Request__c> Approvalrequestlist){
        List<Apttus__APTS_Agreement__c> Agreementlist = new list<Apttus__APTS_Agreement__c>() ;
        List<string> aggrementid = new list<string>();
        map<string,string> mapStatus =  new map<string,string>(); 
        map<string,string> mapforSteplabel =  new map<string,string>(); 
        for(Apttus_Approval__Approval_Request__c approvelreq :Approvalrequestlist){
            if(approvelreq.Apttus_Approval__Approval_Status__c !='Not Submitted'){
                aggrementid.add(approvelreq.Apttus_Approval__Related_Agreement__c);
                mapStatus.put(approvelreq.Apttus_Approval__Related_Agreement__c , approvelreq.Apttus_Approval__Approval_Status__c);
                mapforSteplabel.put(approvelreq.Apttus_Approval__Related_Agreement__c , approvelreq.Apttus_Approval__StepLabel__c);
            }  
            Agreementlist=[select id,Step_Label__c,Approval_Status__c from Apttus__APTS_Agreement__c where Id IN:aggrementid];
            for(Apttus__APTS_Agreement__c agreeRec :Agreementlist ){
                agreeRec.Approval_Status__c = mapStatus.get(agreeRec.id);
                agreeRec.Step_Label__c = mapforSteplabel.get(agreeRec.id);
            }
            update Agreementlist; 
        } 
    } 
    
    public Static void statusafterupdate(list<Apttus_Approval__Approval_Request__c> Approvalrequestlist, list<Apttus_Approval__Approval_Request__c> oldApprovalrequestlist ){
        List<Apttus__APTS_Agreement__c> Agreementlist = new List<Apttus__APTS_Agreement__c>() ;
        List<string> aggrementid = new List<string>();
        map<string,string> mapStatus =  new map<string,string>(); 
        map<string,string> mapforSteplabel =  new map<string,string>(); 
        map<string,string> oldmapStatus =  new map<string,string>(); 
        //map<string,string> oldmapforSteplabel =  new map<string,string>(); 
        for(Apttus_Approval__Approval_Request__c oldapprovelreq : oldApprovalrequestlist){
            if(oldapprovelreq.Apttus_Approval__Approval_Status__c != 'Not Submitted' && oldapprovelreq.Apttus_Approval__Approval_Status__c != 'Null'){
                oldmapStatus.put(oldapprovelreq.Apttus_Approval__Related_Agreement__c , oldapprovelreq.Apttus_Approval__Approval_Status__c);
                //oldmapforSteplabel.put(oldapprovelreq.Apttus_Approval__Related_Agreement__c , oldapprovelreq.Apttus_Approval__StepLabel__c);
            }
        }
         
        for(Apttus_Approval__Approval_Request__c approvelreq :Approvalrequestlist){
            if(approvelreq.Apttus_Approval__Approval_Status__c !='Not Submitted' && oldmapStatus.get(approvelreq.Apttus_Approval__Related_Agreement__c) !=  approvelreq.Apttus_Approval__Approval_Status__c ){
                aggrementid.add(approvelreq.Apttus_Approval__Related_Agreement__c);
                mapStatus.put(approvelreq.Apttus_Approval__Related_Agreement__c , approvelreq.Apttus_Approval__Approval_Status__c);
                mapforSteplabel.put(approvelreq.Apttus_Approval__Related_Agreement__c , approvelreq.Apttus_Approval__StepLabel__c);
            } 
            
            Agreementlist=[select id,Step_Label__c,Approval_Status__c from Apttus__APTS_Agreement__c where Id IN:aggrementid];
            for(Apttus__APTS_Agreement__c agreeRec :Agreementlist ){
                agreeRec.Approval_Status__c = mapStatus.get(agreeRec.id);
                agreeRec.Step_Label__c = mapforSteplabel.get(agreeRec.id);
            }
            update Agreementlist; 
        } 
    }
}