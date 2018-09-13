public class Cldy_AgreementTriggerHandler {
    public static string AGMT_STATUS_FULLY_SIGNED = 'Fully Signed';
    public static string AGMT_STATUS_ACTIVATED = 'Activated';
    //public static string AGMT_SIGNED_DOC_KEY = 'signed';
    //public static string STANDARD_AGMT = 'Standard Agreement';
    public static string NON_STANDARD_AGMT = 'Non-Standard Agreement';
    public static void beforeUpdate(Map<Id, Apttus__APTS_Agreement__c> newMap, Map<Id, Apttus__APTS_Agreement__c> oldMap){
        List<Apttus__APTS_Agreement__c> agmtToCheckMetaData = new List<Apttus__APTS_Agreement__c>();
        Set<Id> agmtToActivate = new Set<Id>();
        Set<Id> agreementIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c agreementRec : newMap.values()){
            agreementIds.add(agreementRec.Id);
            if(agreementRec.Apttus__Status__c == AGMT_STATUS_FULLY_SIGNED && oldMap.get(agreementRec.Id).Apttus__Status__c != agreementRec.Apttus__Status__c){
                agreementRec.Apttus__Contract_Start_Date__c = system.today();
                /**if(agreementRec.CLDY_Agreement_Flow_Type__c == STANDARD_AGMT){
                    agmtToActivate.add(agreementRec.Id);
                }
                else**/
                if(agreementRec.CLDY_Agreement_Flow_Type__c == NON_STANDARD_AGMT){
                    agmtToCheckMetaData.add(agreementRec);
                }
            }
            if(agreementRec.Apttus__Status__c == AGMT_STATUS_ACTIVATED && oldMap.get(agreementRec.Id).Apttus__Status__c != agreementRec.Apttus__Status__c){
                if(agreementRec.Apttus__Term_Months__c != null && agreementRec.Apttus__Contract_Start_Date__c != null){
                    if(agreementRec.CLDY_Agreement_Flow_Type__c != NON_STANDARD_AGMT){
                        //agreementRec.Apttus__Contract_End_Date__c = agreementRec.Apttus__Contract_Start_Date__c.addmonths(Integer.valueOf(agreementRec.Apttus__Term_Months__c));
                    }
                }
            }
        }
        /**if(!agmtToActivate.isEmpty()){
            activateAgreements(agmtToActivate);
        }**/
        if(!agmtToCheckMetaData.isEmpty()){
            createMetaDataTaskForAgreements(agmtToCheckMetaData);
        }
        
        if(!agreementIds.isEmpty()){
            if(!System.isFuture() && !System.isBatch()){
                CLDLY_CustomSharingController.shareRecords(agreementIds, 'Apttus__APTS_Agreement__c', '');
            } 
            else{
                CLDLY_CustomSharingController.shareRecordsWithNoFuture(agreementIds, 'Apttus__APTS_Agreement__c', '');
            }
        }
    }
    public static void createMetaDataTaskForAgreements(List<Apttus__APTS_Agreement__c> agmtToCheckMetaData){
        List<Review_Fields_Settings__c> reviewFieldsList = [select id, Name, Field_API_Name__c from Review_Fields_Settings__c];
        List<Task> agreementTaskLst = new List<Task>();
        for(Apttus__APTS_Agreement__c agrRec: agmtToCheckMetaData){
            String dataMissingFields = '';
            for(Review_Fields_Settings__c reviewFieldRec : reviewFieldsList){
                if(getFieldType(reviewFieldRec.Field_API_Name__c) == 'STRING' || 
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'PICKLIST' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'TEXTAREA' || 
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'EMAIL' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'URL'){
                    
                    if(agrRec.get(reviewFieldRec.Field_API_Name__c) == null || agrRec.get(reviewFieldRec.Field_API_Name__c) == ''){
                    
                        if(dataMissingFields == ''){
                            dataMissingFields = reviewFieldRec.Name;
                        }
                        else{
                            dataMissingFields = dataMissingFields + ',\n' + reviewFieldRec.Name;
                        }
                    }
                }
                else if(getFieldType(reviewFieldRec.Field_API_Name__c) == 'DATETIME' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'DATE' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'BOOLEAN' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'DOUBLE' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'PERCENT' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'CURRENCY' ||
                    getFieldType(reviewFieldRec.Field_API_Name__c) == 'REFERENCE'){
                        
                    if(agrRec.get(reviewFieldRec.Field_API_Name__c) == null){
                        if(dataMissingFields == ''){
                            dataMissingFields = reviewFieldRec.Name;
                        }
                        else{
                            dataMissingFields = dataMissingFields + ',\n' + reviewFieldRec.Name;
                        }
                    }
                }
            }
            if(dataMissingFields != ''){
                Task agreementTaskRec = new Task();
                agreementTaskRec.subject = 'Please Review the Agreement Record. It has Some Missing Meta Data Fields';
                agreementTaskRec.Description = 'Please Fill Below Fields in Agreement Record  \n\n' + dataMissingFields;
                agreementTaskRec.status = 'Open';
                agreementTaskRec.Priority = 'Normal';
                agreementTaskRec.ActivityDate = system.today();
                agreementTaskRec.OwnerId = UserInfo.getUserId();
                agreementTaskRec.whatid = agrRec.Id;
                agreementTaskLst.add(agreementTaskRec);
            }
        }
        if(!agreementTaskLst.isEmpty()){
            insert agreementTaskLst;
        }
    }
    public static String getFieldType(String fieldName){
		Schema.SObjectType sojt = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c'); 
		Schema.DescribeSObjectResult sojtresult= sojt.getDescribe();
		Schema.DescribeFieldResult fdresult = sojtresult.fields.getMap().get(fieldName).getDescribe();		
		return String.valueof(fdresult.getType());
	}
    /**@future
    public static void activateAgreements(Set<Id> agmtToActivate){
        List<Apttus__APTS_Agreement__c> agmtListToActivate = [select Id from Apttus__APTS_Agreement__c Where Id IN: agmtToActivate];
        List<Attachment> agmtAttachmentLst = [Select Id, Name, ParentId from Attachment Where ParentId IN: agmtListToActivate];
        Map<Id, Id> agmtFullySignedAttachmentMap = new Map<Id, Id>();
        List<Attachment> copyAttachmentsToAgreementLst = new List<Attachment>();
        for(Attachment attachmentRec : agmtAttachmentLst){
            String attName = null;
            attName = attachmentRec.Name.toLowerCase();
            if((attName).contains(AGMT_SIGNED_DOC_KEY)){
                agmtFullySignedAttachmentMap.put(attachmentRec.ParentId, attachmentRec.Id);
            }
        }
        Map<Id, Attachment> finalAttachmentmap = new Map<Id, Attachment>([Select Id, ParentId, Body, Name, ContentType from Attachment Where Id IN: agmtFullySignedAttachmentMap.values()]);
        for(Apttus__APTS_Agreement__c agreementRec : agmtListToActivate){
            if(agmtFullySignedAttachmentMap.get(agreementRec.Id) != null){
                if(finalAttachmentmap.get(agmtFullySignedAttachmentMap.get(agreementRec.Id)) != null){
                    Attachment finalAttachmentRec = finalAttachmentmap.get(agmtFullySignedAttachmentMap.get(agreementRec.Id));
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
                else{
                    //agreementRec.addError('Unable to Find the Fully Signed Document. Please contact Admin.');
                }
            }
            else{
                //agreementRec.addError('Unable to Find the Fully Signed Document. Please contact Admin.');
            }
        }
        if(!copyAttachmentsToAgreementLst.isEmpty()){
            insert copyAttachmentsToAgreementLst;
        }
    }**/
    
    public static void beforeInsert(List<Apttus__APTS_Agreement__c> newAgreements){
        String MSASOWSubType = 'Master Services Agmt SOW (already have MSA in place)';
        String ICASOWSubType = 'Independent Contractor Agmt SOW (already have ICA in place)';
        String RELLEKSOWSubType = 'Rellek ICA SOW (already have ICA in place) (USE BY RELLEK ONLY)';
        Set<Id> agreementAccounts = new Set<Id>();
        for(Apttus__APTS_Agreement__c agreementRec : newAgreements){
            agreementAccounts.add(agreementRec.Apttus__Account__c);
        }
        List<Apttus__APTS_Agreement__c> accountSOWAgreements = [Select 
                                                                    Id,
                                                                    Apttus__Account__c, Agreement_Sub_Type__c,
                                                                    CLDY_Please_select_the_appropriate_agree__c
                                                                    from 
                                                                    Apttus__APTS_Agreement__c 
                                                                    Where 
                                                                    Apttus__Account__c IN: agreementAccounts
                                                                    AND
                                                                    (CLDY_Please_select_the_appropriate_agree__c =: MSASOWSubType
                                                                    OR
                                                                    CLDY_Please_select_the_appropriate_agree__c =: ICASOWSubType
                                                                    OR
                                                                    CLDY_Please_select_the_appropriate_agree__c =: RELLEKSOWSubType)];
        Map<Id, Integer> accountMSASOWAgreementCount = new Map<Id, Integer>();
        Map<Id, Integer> accountICASOWAgreementCount = new Map<Id, Integer>();
        Map<Id, Integer> accountRELLEKSOWAgreementCount = new Map<Id, Integer>();
        for(Apttus__APTS_Agreement__c agreementRec : accountSOWAgreements){
            if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == MSASOWSubType){
                if(accountMSASOWAgreementCount.get(agreementRec.Apttus__Account__c) == null){
                    accountMSASOWAgreementCount.put(agreementRec.Apttus__Account__c, 2);
                }
                else{
                    accountMSASOWAgreementCount.put(agreementRec.Apttus__Account__c, accountMSASOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1);
                }
            }
            else if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == ICASOWSubType){
                if(accountICASOWAgreementCount.get(agreementRec.Apttus__Account__c) == null){
                    accountICASOWAgreementCount.put(agreementRec.Apttus__Account__c, 2);
                }
                else{
                    accountICASOWAgreementCount.put(agreementRec.Apttus__Account__c, accountICASOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1);
                }
            }
            else if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == RELLEKSOWSubType){
                if(accountRELLEKSOWAgreementCount.get(agreementRec.Apttus__Account__c) == null){
                    accountRELLEKSOWAgreementCount.put(agreementRec.Apttus__Account__c, 2);
                }
                else{
                    accountRELLEKSOWAgreementCount.put(agreementRec.Apttus__Account__c, accountRELLEKSOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1);
                }
            }
        }
        
        for(Apttus__APTS_Agreement__c agreementRec : newAgreements){
            if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == MSASOWSubType){
                if(accountMSASOWAgreementCount.get(agreementRec.Apttus__Account__c) != null){
                    agreementRec.CLDY_MSA_SOW_Number__c = accountMSASOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1;
                }
                else{
                    agreementRec.CLDY_MSA_SOW_Number__c = 2;
                }
            }
            else if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == ICASOWSubType){
                if(accountICASOWAgreementCount.get(agreementRec.Apttus__Account__c) != null){
                    agreementRec.ICA_SOW_Number__c = accountICASOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1;
                }
                else{
                    agreementRec.ICA_SOW_Number__c = 2;
                }
            }
            else if(agreementRec.CLDY_Please_select_the_appropriate_agree__c == RELLEKSOWSubType){
                if(accountRELLEKSOWAgreementCount.get(agreementRec.Apttus__Account__c) != null){
                    agreementRec.RELLEK_SOW_Number__c = accountRELLEKSOWAgreementCount.get(agreementRec.Apttus__Account__c) + 1;
                }
                else{
                    agreementRec.RELLEK_SOW_Number__c = 2;
                }
            }
        }
    }
}