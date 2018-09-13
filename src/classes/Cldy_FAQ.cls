public with sharing class Cldy_FAQ {
    public List<FAQ__c> faqList{get;set;}
    public String dynquery{get;set;}
    public String Searchquestion{get;set;}
    public Cldy_FAQ(){
        /*faqList= new List<FAQ__c>();
        dynquery='select id,Answer__c,Question__c,Question_Order__c from FAQ__c order by Question_Order__c asc';
        //faqList=[select id,Answer__c,Question__c,Question_Order__c from FAQ__c order by Question_Order__c asc];
        faqList= Database.query(dynquery); */
        Search();
    } 
    public void Search(){
        faqList= new List<FAQ__c>();
        dynquery='select id, Answer__c, Question__c, Question_Order__c from FAQ__c';
        if(Searchquestion != null && Searchquestion !=''){
            Searchquestion = Searchquestion.trim();
            String Searchtext = '%' + Searchquestion + '%';
            dynquery=dynquery+' Where Question__c like : Searchtext';
        }
        dynquery=dynquery+' order by Question_Order__c asc';
        faqList= Database.query(dynquery);
    }
}