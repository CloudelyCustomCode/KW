public class RequestSubmittedCntrl {
    
    public static set<String> profilesToEnableGotoAgreement = new Set<String>{'System Administrator', 'CLDY Legal','CLDY Submitter/Employee'};
    public string agreementRecordId {get;set;}
    public boolean displaygotoAgreement {get;set;}
    public List<User> adminUsers{get;set;}
    
    public RequestSubmittedCntrl(){
        agreementRecordId = system.currentPageReference().getParameters().get('AgrId');
        if(agreementRecordId == null || agreementRecordId == ''){
            agreementRecordId = system.currentPageReference().getParameters().get('id');
        }
        adminUsers = [Select Id,Name from User Where Profile.Name IN: profilesToEnableGotoAgreement And Id =: Userinfo.getUserId()];
        if(adminUsers.size() > 0){
            displaygotoAgreement = true;
        }
        else{
            displaygotoAgreement = false;
        }
    }
    
    public pagereference gotoAgreementRequest(){
        PageReference goToWizard = new PageReference('/apex/apttus__wizard?wizardid=' + system.label.Wizard_Id);
        goToWizard.setRedirect(true);
        return goToWizard;
    }
    
    public pagereference logout(){
        //perform Business logic here
        PageReference pageRef = new PageReference('/secur/logout.jsp');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference gotoAgreement(){
        PageReference pageRef = new PageReference('/' + agreementRecordId);
        pageRef.setRedirect(true);
        return pageRef;
    }

}