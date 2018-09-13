global class agreementRemaindersSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      //mergeNumbers M = new mergeNumbers(); 
      AgreementRemaindersBatch remainderBatch = new AgreementRemaindersBatch();
      Database.executeBatch(remainderBatch, 1);
   }
}