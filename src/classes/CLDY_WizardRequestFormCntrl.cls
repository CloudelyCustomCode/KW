public class CLDY_WizardRequestFormCntrl {
    public PageReference redirectToWizard(){
        PageReference goToWizard = new PageReference('https://kw--kwsandbox--apttus.cs94.visual.force.com/apex/apttus__wizard?wizardid=a0q0R000000NDU5QAO');
        return goToWizard;
    }
}