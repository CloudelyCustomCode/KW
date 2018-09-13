global with sharing class Agreementattachment {
    @future (callout=true)
    webservice static void generateDocument(Id agmntId, String SessionId, Id templateId){
        if(agmntId != null && SessionId != null && templateId != null){        
            list<Apttus__APTS_Template__c> templateIds = [select id from Apttus__APTS_Template__c where Id =: templateId AND Apttus__IsActive__c = true limit 1];
            String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/35.0/' + UserInfo.getOrganizationId();            
            try{
                String generatedDocId = Apttus.MergeWebService.generatedoc2(templateIds.get(0).Id, agmntId, 'Full access', 'PDF', false, SessionId, apiServerURL);
            }
            catch(Exception e){
            }
        }
    }
}