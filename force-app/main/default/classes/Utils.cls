public with sharing class Utils {

    public final String  MESSAGE_ACCOUNT_NUMBER_ERROR = 'Número do cliente é inválido';
    public Map<Id, Schema.RecordTypeInfo> recordTypes;

    public Utils() {
        this.recordTypes = SObjectType.Account.getRecordTypeInfosById();
    }

    public Boolean validaCNPJ(List<Account> accounts){
        return true;
    }

    public Boolean validaCPF(List<Account> accounts){
        return true;
    }

    public void checkAccountNumber(List<Account> accounts){

        for(Account account : accounts){
            if(String.isNotEmpty(account.AccountNumber) &&  account.AccountNumber.isNumeric())
                continue;

            account.addError(MESSAGE_ACCOUNT_NUMBER_ERROR);
        }
    }

    public Boolean checkAccountByRecordType(Account account, String developerName){
        return getRecordTypeDeveloperName(account.RecordTypeId) == developerName;
    }

    public void createOpportunity(Account account){

        Opportunity opp = new Opportunity();
        opp.Name = account.Name + ' – opp Parceiro';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
    }

    public void createTask(Account account){

        Task ts = new Task();
        ts.Subject = 'Cosumidor Final test';
        ts.WhatId = account.Id;
        ts.Status = 'Not Started';
        ts.Priority = 'Normal';
        insert ts;

    }

    private String getRecordTypeDeveloperName (ID accountId) {
        RecordTypeInfo recordTypeInfo = recordTypes.get(accountId);
        return recordTypeInfo.getDeveloperName();
    }
}
