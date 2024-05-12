/*****************************************************************************
* @author Capgemini: Gerald Bartels
* @date 03-11-2023
* @description Test class for FlowUtil_SafeDML
* @history
* -------
* VERSION | AUTHOR | DATE | DESCRIPTION
* 1.0 | Capgemini: Gerald Bartels | 03-11-2023 | Created
*****************************************************************************/
@isTest
private class FlowUtil_SafeDML_Test {
    
    @testSetup
    private static void createData(){
        TD_Test_Case__c a = new TD_Test_Case__c(Name = 'Test Case 1');
        TD_Test_Case__c b = new TD_Test_Case__c(Name = 'Test Case 2');
        Database.insert(new List<TD_Test_Case__c>{a, b});
    }
    
    @isTest
    private static void testSafeInsert(){
        List<TD_Test_Case__c> tcList = [SELECT Id FROM TD_Test_Case__c LIMIT 1];
        List<TD_Test_Record__c> trlist = new List<TD_Test_Record__c>();
        List<String> methodList = new List<String>();
        for (Integer i=0; i<2; i++){
            TD_Test_Record__c tr = new TD_Test_Record__c();
            if (i == 1) tr.Test_Case__c = tcList.get(0).Id;
            trlist.add(tr);
            methodList.add('insert');
        }
        List<FlowUtil_SafeDML.FlowInput> fiList = createFlowInputList(methodList, trlist, false);
        
        Test.startTest();
        List<FlowUtil_SafeDML.FlowOutput> responseList = FlowUtil_SafeDML.safeDml(fiList);
        Test.stopTest();
        
        System.assertEquals(2, responseList.size());
        System.assertNotEquals(true, responseList.get(0).status);
        System.assertNotEquals(true, responseList.get(1).status);
    }
    
	@isTest
    private static void testSafeUpdate(){
        List<TD_Test_Case__c> tcList = [SELECT Id FROM TD_Test_Case__c LIMIT 2];
        List<String> methodList = new List<String>();
        for (Integer i=0; i<tcList.size(); i++){
            methodList.add('update');
        }
        List<FlowUtil_SafeDML.FlowInput> fiList = createFlowInputList(methodList, tcList, false);
        
        Test.startTest();
        List<FlowUtil_SafeDML.FlowOutput> responseList = FlowUtil_SafeDML.safeDml(fiList);
        Test.stopTest();
        
        System.assertEquals(2, responseList.size());
        System.assertEquals(true, responseList.get(0).status);
        System.assertEquals(true, responseList.get(1).status);
    }
    
    @isTest
    private static void testSafeMultiSuccess(){
        List<TD_Test_Case__c> tcList = [SELECT Id FROM TD_Test_Case__c LIMIT 2];
        List<String> methodList = new List<String>{'update'};
        List<FlowUtil_SafeDML.FlowInput> fiList = createFlowInputList(methodList, tcList, true);
        
        Test.startTest();
        List<FlowUtil_SafeDML.FlowOutput> responseList = FlowUtil_SafeDML.safeDml(fiList);
        Test.stopTest();
        
        System.assertEquals(1, responseList.size());
        System.assertEquals(true, responseList.get(0).status);
    }

    @isTest
    private static void testSafeMultiFailure(){
        List<TD_Test_Record__c> trlist = new List<TD_Test_Record__c>();
        trlist.add(new TD_Test_Record__c());
        trlist.add(new TD_Test_Record__c());
        List<String> methodList = new List<String>{'update'};
        List<FlowUtil_SafeDML.FlowInput> fiList = createFlowInputList(methodList, trlist, true);
        
        Test.startTest();
        List<FlowUtil_SafeDML.FlowOutput> responseList = FlowUtil_SafeDML.safeDml(fiList);
        Test.stopTest();
        
        System.assertEquals(1, responseList.size());
        System.assertEquals(false, responseList.get(0).status);
    }
    
    private static List<FlowUtil_SafeDML.FlowInput> createFlowInputList(List<String> methodList, List<SObject> sobList, Boolean multi){
        List<FlowUtil_SafeDML.FlowInput> fiList = new List<FlowUtil_SafeDML.FlowInput>();
        for (Integer i=0; i<methodList.size(); i++){
            FlowUtil_SafeDML.FlowInput fi = new FlowUtil_SafeDML.FlowInput();
            fi.dmlMethod = methodList.get(i);
            if (multi){
                fi.sobList = new List<SObject>();
                for (SObject sob : sobList) fi.sobList.add(sob);
            }
            else fi.sob = sobList.get(i);
            fiList.add(fi);
            if (multi) break;
        }
        return fiList;
    }
}