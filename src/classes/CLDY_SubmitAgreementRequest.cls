public class CLDY_SubmitAgreementRequest {
    public boolean requestSubmittedToQueue {get;set;}
    public string agreementRecordId {get;set;}
    public void onload(){
        agreementRecordId = system.currentPageReference().getParameters().get('AgrId');
        if(agreementRecordId != null && agreementRecordId != ''){
            boolean response = Apttus.AgreementWebService.submitRequestToQueue(agreementRecordId);
            if(response){
                requestSubmittedToQueue = true;
            }
            else{
                requestSubmittedToQueue = false;
            }
        }
    }
    
    public pagereference redirectToAgreement(){
        pagereference pgRef = new pagereference('/apex/RequestSubmitted?AgrId' + agreementRecordId);
        pgRef.setRedirect(true);
        return pgRef;
    }
}