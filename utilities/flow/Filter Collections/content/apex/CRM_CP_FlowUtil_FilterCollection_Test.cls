/**
* @author   	: Gerald Bartels
* @date 		: 16-01-2023
* @description 	: Test class for CRM_CP_FlowUtil_FilterCollection

* ------------------------------------------ Versions -------------------------------------------------------------------
* Version 1.0  : Gerald Bartels
*/
@isTest
private inherited sharing class CRM_CP_FlowUtil_FilterCollection_Test {
    private static String separator = ';';
    
    private static CRM_CP_FlowUtil_FilterCollection.FlowInput createFlowInput(List<SObject> soblist, String searchField, Boolean returnOutputUnique, String returnDataType,
                                                                        List<String> containslist, Map<String, String> conditionMap){
        CRM_CP_FlowUtil_FilterCollection.FlowInput input = new CRM_CP_FlowUtil_FilterCollection.FlowInput();
        input.soblist = soblist;
        if (searchField != null) input.searchField = searchField;
        input.returnOutputUnique = returnOutputUnique;
        input.returnDataType = returnDataType;
        input.containslist = containslist;
        if (conditionMap == null) return input;
        else {
            CRM_CP_FlowUtil_FlowConditions flowCondition = new CRM_CP_FlowUtil_FlowConditions();
            flowCondition.fieldApiNames = conditionMap?.get('fieldApiNames');
            flowCondition.fieldValues = conditionMap?.get('fieldValues');
            flowCondition.operators = conditionMap?.get('operators');
            flowCondition.conditionLogic = conditionMap?.get('conditionLogic');
            flowCondition.separator = separator;
            input.flow_conditions = flowCondition;
            return input;
        }
    }

    @TestSetup
    private static void makeData(){
        List<Account> acclist = (List<Account>) CRM_CP_TestDataFactory.createSObjectList(
            'Account',
            new Map<String, Object>{
                'LastName' => 'Test Account',
                'recordTypeId' => [SELECT Id FROM RecordType WHERE DeveloperName = 'CRM_CP_Consumer' AND SobjectType = 'Account'].Id,
                'CRM_CP_Contact_Status__pc' => 'Active',
                'CRM_CP_Prescription_Request_Home_Address__c' => 'Shipping Address',
                'ShippingCity' => 'Test'
            },
            10,
            false
        );
        for (Integer i=0; i<acclist.size(); i++){
            acclist.get(i).ShippingStreet = 'Testroad ' + i;
            acclist.get(i).CRM_CP_No_of_Beds__c = i;
        }
        Database.insert(acclist);
    }

    @isTest
    private static void testFlowUtil_testNoConditions(){
        List<Account> acclist = [SELECT Id, ShippingStreet, ShippingCity FROM Account];
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi1 = createFlowInput(acclist, 'ShippingStreet', true, 'text', null, null);
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi2 = createFlowInput(acclist, 'ShippingStreet', false, 'text', null, null);
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi3 = createFlowInput(acclist, 'ShippingCity', true, 'sobject', null, null);
        
        Test.startTest();
        List<CRM_CP_FlowUtil_FilterCollection.FlowOutput> folist = CRM_CP_FlowUtil_FilterCollection.getFieldCollection(new List<CRM_CP_FlowUtil_FilterCollection.FlowInput>{fi1, fi2, fi3});
        Test.stopTest();

        System.assertEquals(10, folist.get(0).text_list.size());
        System.assertEquals(10, folist.get(1).text_list.size());
        System.assertEquals('Testroad 0', folist.get(0).text_list.get(0));
        System.assertEquals('Testroad 1', folist.get(1).text_list.get(1));
        System.assertEquals(1, folist.get(2).sobject_list.size());
        System.assertEquals('Test', folist.get(2).sobject_list.get(0).get('ShippingCity'));
    }

    @isTest
    private static void testFlowUtil_testAndConditions(){
        List<Account> acclist = [SELECT Id, ShippingStreet, CRM_CP_No_of_Beds__c FROM Account];
        String accountPrefix = Schema.getGlobalDescribe().get('Account').getDescribe().getKeyPrefix();
        Map<String, String> conditionMap = new Map<String, String>{'fieldApiNames' => 'ShippingStreet'+ separator +'CRM_CP_No_of_Beds__c', 'fieldValues' => 'Testroad 3'+ separator +'3', 'operators' => 'EQUAL_TO'+ separator +'GREATER_THAN_OR_EQUAL_TO', 'conditionLogic' => '1 AND 2'};
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi1 = createFlowInput(acclist, 'ShippingStreet', true, 'text', new List<String>{'Testroad 3', 'Testroad 4'}, null);
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi2 = createFlowInput(acclist, null, true, 'text', null, conditionMap);
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi3 = createFlowInput(acclist, 'ShippingStreet', true, 'text', new List<String>{'Testroad 3', 'Testroad 4'}, conditionMap);
        
        Test.startTest();
        List<CRM_CP_FlowUtil_FilterCollection.FlowOutput> folist = CRM_CP_FlowUtil_FilterCollection.getFieldCollection(new List<CRM_CP_FlowUtil_FilterCollection.FlowInput>{fi1, fi2, fi3});
        Test.stopTest();

        System.assertEquals(2, folist.get(0).text_list.size());
        System.assertEquals(1, folist.get(1).text_list.size());
        System.assertEquals(true, folist.get(1).text_list.get(0).startsWith(accountPrefix));
        System.assertEquals(1, folist.get(2).text_list.size());
        System.assertEquals('Testroad 3', folist.get(2).text_list.get(0));
    }

    @isTest
    private static void testFlowUtil_testOrConditions(){
        List<Account> acclist = [SELECT Id, ShippingStreet, CRM_CP_No_of_Beds__c FROM Account];
        Map<String, String> conditionMap = new Map<String, String>{'fieldApiNames' => 'ShippingStreet'+ separator +'CRM_CP_No_of_Beds__c', 'fieldValues' => 'Testroad 3'+ separator +'3', 'operators' => 'EQUAL_TO'+ separator +'GREATER_THAN_OR_EQUAL_TO', 'conditionLogic' => '1 OR 2'};
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi1 = createFlowInput(acclist, null, true, 'text', null, conditionMap);
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi2 = createFlowInput(acclist, 'ShippingStreet', true, 'text', new List<String>{'Testroad 3', 'Testroad 4'}, conditionMap);
        
        Test.startTest();
        List<CRM_CP_FlowUtil_FilterCollection.FlowOutput> folist = CRM_CP_FlowUtil_FilterCollection.getFieldCollection(new List<CRM_CP_FlowUtil_FilterCollection.FlowInput>{fi1, fi2});
        Test.stopTest();

        System.assertEquals(7, folist.get(0).text_list.size());
        System.assertEquals(2, folist.get(1).text_list.size());
        System.assertEquals('Testroad 3', folist.get(1).text_list.get(0));
        System.assertEquals('Testroad 4', folist.get(1).text_list.get(1));
    }

    @isTest
    private static void testFlowUtil_testFailure(){
        List<Account> acclist = [SELECT Id, ShippingStreet, CRM_CP_No_of_Beds__c FROM Account];
        Map<String, String> conditionMap = new Map<String, String>{'fieldApiNames' => 'ShippingStreet'+ separator +'CRM_CP_No_of_Beds__c', 'fieldValues' => 'Testroad 3'+ separator +'3'+ separator +'4', 'operators' => 'EQUAL_TO'+ separator +'GREATER_THAN_OR_EQUAL_TO', 'conditionLogic' => '1 OR 2'};
        CRM_CP_FlowUtil_FilterCollection.FlowInput fi1 = createFlowInput(acclist, null, true, 'text', null, conditionMap);
        
        Test.startTest();
        List<CRM_CP_FlowUtil_FilterCollection.FlowOutput> folist = CRM_CP_FlowUtil_FilterCollection.getFieldCollection(new List<CRM_CP_FlowUtil_FilterCollection.FlowInput>{fi1});
        Test.stopTest();
        
        System.assertEquals(null, folist);
    }
}