public class CLDLY_AttachmentTriggerHandler {
    
    public static string AGMT_STATUS_FULLY_SIGNED = 'Fully Signed';
    public static string AGMT_SIGNED_DOC_KEY = 'signed';
    public static string STANDARD_AGMT = 'Standard Agreement';
    
    public Static void afterInsert(List<Attachment> newAttachments){
        
        List<Attachment> copyAttachmentsToAgreementLst = new List<Attachment>();
        Map<Id, Attachment> agmtFullySignedAttachmentMap = new Map<Id, Attachment>();
        for(Attachment attachmentRec : newAttachments){
            String attName = null;
            attName = attachmentRec.Name.toLowerCase();
            if((attName).contains(AGMT_SIGNED_DOC_KEY)){
                agmtFullySignedAttachmentMap.put(attachmentRec.ParentId, attachmentRec);
            }
        }
        
        If(!agmtFullySignedAttachmentMap.keySet().isEmpty()){
            List<Apttus__APTS_Agreement__c> agreementsToActivate = [Select 
                                                                        Id,
                                                                        Apttus__Status__c
                                                                        from 
                                                                        Apttus__APTS_Agreement__c
                                                                        Where 
                                                                        Id IN: agmtFullySignedAttachmentMap.keySet()
                                                                        AND
                                                                        Apttus__Status__c =: AGMT_STATUS_FULLY_SIGNED];
            for(Apttus__APTS_Agreement__c agreementRec : agreementsToActivate){
                if(agreementRec.Apttus__Status__c == AGMT_STATUS_FULLY_SIGNED){
                    Attachment finalAttachmentRec = agmtFullySignedAttachmentMap.get(agreementRec.Id);
                    List<Id> selectedDocIds = new List<Id>();
                    List<Id> removableDocIds = new List<Id>();
                    selectedDocIds.add(finalAttachmentRec.Id);
                    if(!Test.isRunningTest()){
                        Boolean res = Apttus.AgreementWebService.activateAgreement(agreementRec.Id, selectedDocIds, removableDocIds);
                        if(res){
                            Boolean publishRes = Apttus.AgreementWebService.publishToDocumentRepository(agreementRec.Id, finalAttachmentRec.Id);
                            if(!publishRes){
                                //agreementRec.addError('Unable to Find the Fully Signed Document. Please contact Admin.');
                            }
                            else{
                                if(finalAttachmentRec != null){
                                    Attachment agmtAttachment = new Attachment();
                                    agmtAttachment.Name = finalAttachmentRec.Name;
                                    agmtAttachment.Body = finalAttachmentRec.Body;
                                    agmtAttachment.ContentType = finalAttachmentRec.ContentType;
                                    agmtAttachment.ParentId = finalAttachmentRec.ParentId;
                                    copyAttachmentsToAgreementLst.add(agmtAttachment);
                                }
                            }
                        }
                    }
                }
            }
            if(!copyAttachmentsToAgreementLst.isEmpty()){
                insert copyAttachmentsToAgreementLst;
            }
        }
    }
}