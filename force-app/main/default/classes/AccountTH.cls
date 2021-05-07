public with sharing class AccountTH extends TriggerHandler {

    private List<Account> newAccounts;
    private Map<Id, Account> oldAccounts;
    private List<Task> newTasks;
    private List<Opportunity> newOppotunitys;
    private Utils utils;
    
    public AccountTH(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
        this.newAccounts = newAccounts;
        this.oldAccounts = oldAccounts;
        this.newTasks = new List<Task>();
        this.newOppotunitys = new List<Opportunity>();

        this.utils = new Utils();
    }

    public AccountTH() {
        this((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }

    override
    public void beforeUpdate() {
        this.newAccounts = utils.filterByActive(this.newAccounts);
        utils.validaCPF(this.newAccounts);
        utils.validaCNPJ(this.newAccounts);
        utils.checkAccountNumber(this.newAccounts);
    }

    override
    public void afterUpdate() {
        this.newAccounts = utils.filterByActive(this.newAccounts);
        this.createRelatedMember();
    }

    public void createRelatedMember(){
        
        for(Account account : this.newAccounts){
            if(utils.checkAccountByRecordType(account, 'partner')){
                this.createRelated('opportunity', account);

            }

            if(utils.checkAccountByRecordType(account, 'finalCustumer')){
                this.createRelated('task', account);
            }
        }

        try {
            if(newTasks.isNotEmpty()) insert newTasks;
            if(newOppotunitys.isNotEmpty()) insert newOppotunitys;

        }  catch(DmlException dmlEx){
            throw new AuraHandledException(dmlEx.getMessage());
        
        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public void createRelated(String objectRelated, Account account){

        try {
            if(objectRelated == 'opportunity'){
                this.newOppotunitys.add(utils.createOpportunity(account));
            } 

            if(objectRelated == 'task'){
                this.newTasks.add(utils.createTask(account));
            } 

        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
