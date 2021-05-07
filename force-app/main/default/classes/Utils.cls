public with sharing class Utils {

    public final String  MESSAGE_ACCOUNT_NUMBER_ERROR = 'Número do cliente é inválido';
    public Map<Id, Schema.RecordTypeInfo> recordTypes;

    public Utils() {
        this.recordTypes = SObjectType.Account.getRecordTypeInfosById();
    }

    public List<Account> filterByActive(List<Account> accounts){

        List<Account> filtered = new List<Account>();
        for(Account account : accounts){
            if(account.Inactiva__c) continue;

            filtered.add(account);
        }

        return filtered;
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

    public Opportunity createOpportunity(Account account){

        Opportunity opp = new Opportunity();
        opp.Name = account.Name + ' – opp Parceiro';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today().addDays(30);
        opp.AccountId = account.Id;
        return opp;
    }

    public Task createTask(Account account){

        Task ts = new Task();
        ts.Subject = 'Cosumidor Final test';
        ts.WhatId = account.Id;
        ts.Status = 'Not Started';
        ts.Priority = 'Normal';
        return ts;

    }

    private String getRecordTypeDeveloperName (ID accountId) {
        RecordTypeInfo recordTypeInfo = recordTypes.get(accountId);
        return recordTypeInfo.getDeveloperName();
    }

    public static Set<Id> convertObjectListIntoSetIds ( List<SObject> baseList  ) {

        Set<Id> filtered = new Set<Id>();
        if (baseList == null  || baseList.isEmpty() ) return filtered;

        for ( SObject data : baseList  ) {
            if ( data.get('Id') == null ) continue;
            filtered.add( (Id) data.get('Id') );
        }

        return filtered;
    }

    public static Map<String, List<SObject>> groupListByField ( String fieldNameForFilter, List<SObject> baseList  ) {

        if (baseList == null  || baseList.isEmpty() ) return null;

        Map<String, List<SObject>> values = new  Map<String, List<SObject>>();

        for ( SObject data : baseList  ) {
            String value = '' + data.get(fieldNameForFilter);
            if ( value  == null ) continue;
            if (values.get ( value ) == null) values.put (value , new List<SObject> ());

            values.get( value ).add (data);
        }
        return values;
    }
}
