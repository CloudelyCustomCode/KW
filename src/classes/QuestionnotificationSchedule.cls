global with sharing class QuestionnotificationSchedule Implements Schedulable{
    global void execute(SchedulableContext sc){
        Integer batchsize= Integer.valueof(Label.BatchSize);
        system.debug('********'+batchsize);
        QuestionnotificationBatch qbtach= new QuestionnotificationBatch();
        Database.executebatch(qbtach,batchsize);
    }
    
}