global with sharing class AccountInactiveSchedule implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new InactiveAccountsBatch(), 200);
    }
}
