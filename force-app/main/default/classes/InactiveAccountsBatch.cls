global with sharing class InactiveAccountsBatch implements Database.Batchable<sObject>, Schedulable{
    
    private final String QUERY = 'SELECT Id, Name, Inactiva__c FROM Account WHERE Inactiva__c = false';
    private Map<String, List<Opportunity>> oppsByAccountId;
    private Map<String, List<Task>> tasksByAccountId;
    private List<Account> accounts = new List<Account>();

    private void init(){
        oppsByAccountId = new Map<String, List<Opportunity>>();
        tasksByAccountId = new Map<String, List<Task>>();
        accounts = new List<Account>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.init();
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Account> accountsUpdated = new List<Account>();
        accounts = (List<Account>) scope;

        this.setRelated();

        for(Account account : accounts){
            
            if( oppsByAccountId != null ){
                if(oppsByAccountId.get(account.Id) != null) continue;
            }

            if(tasksByAccountId != null){
                if(tasksByAccountId.get(account.Id) != null) continue;
            }

            account.Inactiva__c = true;
            accountsUpdated.add(account);
        }

        update accountsUpdated;
    }

    global void finish(Database.BatchableContext BC) {

        InactiveAccountsBatch inactiveAccountsBatch = new InactiveAccountsBatch();

        Integer hour = DateTime.now().hour() + 6; 
        String cron ='00 00 '+ hour +' * 2-6 ?';
        String jobID = System.schedule('Remind account inactive', cron, inactiveAccountsBatch);
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new InactiveAccountsBatch(), 200);
    }

    private void setRelated(){

        Set<ID> accountIds = new Set<ID>();
        accountIds = Utils.convertObjectListIntoSetIds(accounts);

        this.oppsByAccountId = findWonOpportunityAndNegotiationByAccountIds(accountIds);
        this.tasksByAccountId = findTaskByAccountId(accountIds);
    }

    private Map<String, List<Opportunity>> findWonOpportunityAndNegotiationByAccountIds(Set<ID> accountIds){

        Date closeDateToFind = Date.today().addDays(-120);
        List<Opportunity> oppsFinded = new List<Opportunity>();

        oppsFinded = [SELECT Id , AccountId
                     FROM Opportunity 
                     WHERE (StageName = 'Negotiation/Review' OR StageName = 'Closed Won')
                     AND CloseDate > :closeDateToFind
                     AND AccountId IN : accountIds];

        if(oppsFinded.isEmpty()) return null;

        return ( Map<String, List<Opportunity>> ) Utils.groupListByField ( 'AccountId', oppsFinded ) ;
    }

    private Map<String, List<Task>> findTaskByAccountId(Set<ID> accountIds){
        List<Task> tasksFinded = new List<Task>();
        
        tasksFinded = [SELECT Id, WhatId
                        FROM Task WHERE WhatId IN :accountIds];
        
        if(tasksFinded.isEmpty()) return null;
        return ( Map<String, List<Task>> ) Utils.groupListByField ( 'WhatId', tasksFinded ) ;
    }
}
