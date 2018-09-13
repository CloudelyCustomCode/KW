public class CLDY_NoteTriggerHandler {
    public Static void afterInsert(List<Note> newNotes){
        //String nonStandard = 'Non-Standard Agreement';
        string KWWRecordTypeName = 'KWW';
        map<String, String> templateMap = new map<String, String>();
        List<string> AgrIds= new List<string>();
        List<Apttus__APTS_Agreement__c> agrList= new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Template__c> templateList = [Select Id, Name, CLDY_Agreement_Type__c from Apttus__APTS_Template__c where Apttus__IsActive__c = true and Apttus__Type__c = 'Agreement'];
        
        for(Apttus__APTS_Template__c templateRec : templateList){
            templateMap.put(templateRec.CLDY_Agreement_Type__c, templateRec.Id);
        }
        
        for(Note noteRec : newNotes){
            if(noteRec.body != null && noteRec.title != null){
                if(noteRec.body.contains(System.Label.Note_Body.trim())){ //&& noteRec.title.contains(System.Label.Note_Title.trim())){
                    AgrIds.add(noteRec.ParentId);
                }
            }
        }
        if(AgrIds.size() > 0){
            agrList = [select id, Name, RecordType.Name, Agreement_Sub_Type__c, CLDY_Please_select_the_appropriate_agree__c from Apttus__APTS_Agreement__c where id in: AgrIds]; //AND CLDY_Agreement_Flow_Type__c !=: nonStandard];
            for(Apttus__APTS_Agreement__c agr : agrList){
                if(agr.CLDY_Please_select_the_appropriate_agree__c != null){
                    if(templateMap.get(agr.CLDY_Please_select_the_appropriate_agree__c) != null){
                        agr.Apttus__Status_Category__c = 'In Authoring';
                        agr.Apttus__Status__c = 'Author Contract';
                        Agreementattachment.generateDocument(agr.Id, UserInfo.getSessionId(), templateMap.get(agr.CLDY_Please_select_the_appropriate_agree__c));
                    }
                }
                /**if(templateList.size() > 0){
                    Agreementattachment.generateDocument(agr.Id, UserInfo.getSessionId(), templateList[0].Id);
                }*/
                if(agr.RecordType.Name == KWWRecordTypeName){
                    Apttus_Approval.ApprovalsWebService.submitForApprovals('Apttus__APTS_Agreement__c', agr.Id);
                }
            }
        }
    }
}