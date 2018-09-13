global class QuestionnotificationBatch implements Database.Batchable<sObject> {  	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String agrquery='SELECT ID, Name, Ispendingquestions__c FROM Apttus__APTS_Agreement__c';
        return Database.getQueryLocator(agrquery);
    }
      global void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> agrList) {
     	List<Question_Answers__c> QnList= new List<Question_Answers__c>();
     	List<Id> agrId= new List<Id>();
     	List<id> agrrecIds= new List<Id>();
     	Map<String,String> agrMap= new Map<String,String>();
     	for(Apttus__APTS_Agreement__c agr: agrList){
     		agrId.add(agr.id);
     	}
     	QnList=[Select id,Name,Answer__c,Legal_Question__c,Question__c from Question_Answers__c where Legal_Question__c in: agrId];
     	for(Question_Answers__c qns: QnList){
     		system.debug('&&&&&&&&&&&'+QnList);
     		if((qns.Answer__c == null || qns.Answer__c == '') && agrMap.get(qns.Legal_Question__c) == null){
     			agrMap.put(qns.Legal_Question__c,qns.Question__c);
     			system.debug('&&&&&&&&&&&'+agrMap);
     		}
     	} 
        for(Apttus__APTS_Agreement__c agrrec : agrList){
        	if(agrMap.get(agrrec.id) != null){
        		//agrrecIds.add(agrrec.id);
        		//updateagreements(agrrec.id);
        		agrrec.Ispendingquestions__c = true;
        	}        	
        }
        if(agrList.size()>0){
        	update agrList;
        }
        //updateagreements(agrrecIds);
      }  
	global void finish(Database.BatchableContext bc) { 
   	}
      
 }