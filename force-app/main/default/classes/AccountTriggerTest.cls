@IsTest
public with sharing class AccountTriggerTest {

    @TestSetup
    static void makeData(){

        List<Account> accounts = new List<Account>();
        for(Integer x = 0; x < 10; x++){
            Account accountPartner = new Account();
            accountPartner.RecordTypeId = getRecordTypeByDeveloperName('partner');
            accountPartner.Name = 'test partner ' + String.valueOf(x);
            accountPartner.Type = 'CNPJ';
            accountPartner.AccountNumber = '00123';
            accounts.add(accountPartner);
        }

        insert accounts;

        Account accountFinalCustomer = new Account();
        accountFinalCustomer.RecordTypeId = getRecordTypeByDeveloperName('finalCustumer');
        accountFinalCustomer.Name = 'test final customer';
        accountFinalCustomer.Type = 'CNPJ';
        accountFinalCustomer.AccountNumber = '00456';
        insert accountFinalCustomer;

    }

    public static String getRecordTypeByDeveloperName(String developerName){
        return [SELECT Id FROM RecordType WHERE DeveloperName = : developerName].Id;
    }

    public static List<Account> getAccountByRecordType(String developerName){
        return [SELECT Id, Name, CPF__c, CNPJ__c, AccountNumber, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = :developerName];
    } 

    public static List<Opportunity> getOpportunityByName(){
        return [SELECT Id, Name, StageName, CloseDate FROM Opportunity];
    }

    public static Task getTaskByAccountId(String accountId){
        return [SELECT Id, Subject, WhatId, Status, Priority FROM Task WHERE WhatId = :accountId];
    }

    
    @IsTest
    static void givenPartnerAccountWhenUpdateThenSaveInstances(){
        
        List<Account> accounts = getAccountByRecordType('partner');
        List<Account> newAccounts = new List<Account>();

        for(Account account : accounts){
            account.Name = account.Name + ' changed';
            newAccounts.add(account);
        }

        Test.startTest();
        update newAccounts;
        Test.stopTest(); 

        newAccounts = new List<Account>();

        List<Opportunity> opps = new List<Opportunity>();
        opps = getOpportunityByName();
        newAccounts = getAccountByRecordType('partner');

        System.assertEquals(10, opps.size());
        System.assertEquals('test partner 0 changed', newAccounts.get(0).Name);
        System.assertEquals('Qualification', opps.get(0).StageName);
        System.assertEquals(Date.today().addDays(30), opps.get(0).CloseDate);
    }
    
    @IsTest
    static void givenFinalCustomerAccountWhenUpdateThenSaveInstances(){
        
        List<Account> accounts = new List<Account>();
        accounts = getAccountByRecordType('finalCustumer');
        accounts[0].Name = 'test final customer changed';
        
        Test.startTest();
        update accounts;
        Test.stopTest(); 

        Task ts = getTaskByAccountId(accounts.get(0).Id);
        accounts = getAccountByRecordType('finalCustumer');

        System.assertEquals('Cosumidor Final test', ts.Subject);
        System.assertEquals(accounts[0].Id, ts.WhatId);
        System.assertEquals('Not Started', ts.Status);
        System.assertEquals('Normal', ts.Priority);
    }
}
