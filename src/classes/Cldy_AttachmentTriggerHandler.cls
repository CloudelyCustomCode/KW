public without sharing class Cldy_AttachmentTriggerHandler {
    
    public Static void afterUpdate(List<Attachment> attachmentLst){
        String AGMT_SIGNED_DOC_KEY = 'signed';  
        String AGMT_STATUS_FULLY_SIGNED = 'Fully Signed';
        Map<Id, Attachment> agmtSignedDocs = new Map<Id, Attachment>();
        Set<Id> signedAgreements = new Set<Id>();
        for(Attachment att : attachmentLst){
            String attName = null;
            attName = att.Name.toLowerCase();
            if((attName).contains(AGMT_SIGNED_DOC_KEY)){
                signedAgreements.add(att.ParentId);
                agmtSignedDocs.put(att.ParentId, att);
            }
        }
        if(signedAgreements.size() > 0){
            List<Apttus__APTS_Agreement__c> fullysignedAgreements = [Select Id, 
                                                                            Apttus__Status__c 
                                                                            from 
                                                                            Apttus__APTS_Agreement__c 
                                                                            where Id IN: signedAgreements]; 
            if(fullysignedAgreements.size() > 0){
                for(Apttus__APTS_Agreement__c agmt : fullysignedAgreements){
                    if(agmt.Apttus__Status__c == AGMT_STATUS_FULLY_SIGNED){
                        Id attmtId = agmtSignedDocs.get(agmt.Id).Id;
                        List<Id> selectedDocIds = new List<Id> ();
                        List<Id> removableDocIds = new List<Id> ();
                        selectedDocIds.add(attmtId);
                        if(!Test.isRunningTest()){
                            Boolean res = Apttus.AgreementWebService.activateAgreement(agmt.Id, selectedDocIds, removableDocIds);
                            if(res){
                                Boolean publishRes = Apttus.AgreementWebService.publishToDocumentRepository(agmt.Id, attmtId);
                                if(!publishRes){
                                    agmt.addError('Publishing documents to chatter failed');
                                }
                            }
                            else{
                                agmt.addError('Agreement Activation failed');
                            }
                        }
                    }
                }
            }
        }
    }
}