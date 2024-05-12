/*****************************************************************************
* @author Capgemini: Gerald Bartels
* @date 11-12-2023
* @description Test class for CRM_CP_FlowUtil_CallFutureSubFlow
* @history
* -------
* VERSION | AUTHOR | DATE | DESCRIPTION
* 1.0 | Capgemini: Gerald Bartels | 11-12-2023 | Created
*****************************************************************************/
@isTest
private inherited sharing class CRM_CP_FlowUtil_CallFutureSubFlow_Test {

    @TestSetup
    static void setupData() {
        CRM_CP_TestDataFactory.createTriggerConfiguration(true, true);
        // create Accounts
        Account accList = (Account) CRM_CP_TestDataFactory.createSObject(
            'Account',
            new Map<String, Object>{
                'Salutation' => 'Ms.',
                'FirstName' => 'Test',
                'LastName' => 'ConsumerAccount - {!index}',
                'CRM_CP_Nickname__pc' => 'MC Warrior',
                'PersonEmail' => 'accounttest{!index}@coloplast.com',
                'PersonMobilePhone' => '98959697-{!index}',
                'ShippingStreet' => 'Test Street',
                'ShippingPostalCode' => '1234',
                'ShippingCity' => 'Test City',
                'ShippingState' => '',
                'ShippingCountry' => 'Denmark',
                'CRM_CP_Preferred_Written_Language__pc' => 'da-DK',
                'recordtypeId' => CRM_CP_GlobalConstants.ACCOUNT_RECORD_TYPE_ID_CONSUMER,
                'CRM_CP_Homecare_Provider__pc' => 'Homecare',
                'CRM_CP_Homecare_Provider_ID__pc' => '1234567',
                'CRM_CP_Insurance_ID__c' => '11223344',
                'CRM_CP_Date_of_Birth__pc' => Date.newInstance(1949, 6, 20),
                'HealthCloudGA__Gender__pc' => 'Female',
                'PersonOtherStreet' => '{!index}\n other street',
                'PersonOtherPostalCode' => '5986',
                'PersonOtherCity' => 'Other City',
                'PersonOtherState' =>'',
                'PersonOtherCountry' => 'Guadeloupe',
                'PersonMailingStreet' => '{!index}\n mailing street',
                'PersonMailingPostalCode'=> '5874',
                'PersonMailingCity' =>'',
                'PersonMailingCountry' => 'Guadeloupe',
                'BillingStreet' => '{!index}\n billing street' ,
                'BillingPostalCode' => '7548' , 
                'BillingCity'=> 'Billing City', 
                'BillingState'=> '', 
                'BillingCountry'=> 'Guadeloupe'
            }, true );
        CRM_CP_TestDataFactory.createTriggerConfiguration(false, true);
    }

    private static List<CRM_CP_FlowUtil_CFSVar> createFlowInputList(List<Account> accs, List<String> str){
        List<CRM_CP_FlowUtil_CFSVar> fiList = new List<CRM_CP_FlowUtil_CFSVar>();
        for (Integer i=0; i<accs.size(); i++){
        CRM_CP_FlowUtil_CFSVar fi = new CRM_CP_FlowUtil_CFSVar();
        fi.variableName = 'accRecordId';
        fi.valueString = accs[i].Id;
        fiList.add(fi);
        }
        return fiList;
    }

    @isTest
    private static void CFS_CreateContactPoints_Test(){
            List<Account> accList = [SELECT Id, CRM_CP_External_ID__c, IsBuyer FROM Account LIMIT 1];
            List<CRM_CP_FlowUtil_CFSVar> cfsList = createFlowInputList(accList, null);
            CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput fi = new CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput();
            List<CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput> fiList = new List<CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput>();
            fi.flowName = 'CRM_CP_Capture_ContactPoints_and_CSCs';
            fi.cfsVarList = cfsList;
            fiList.add(fi);
            Set <String> recursion = new Set<String>();
            CRM_CP_FlowUtil_CallFutureSubFlow cfs = new CRM_CP_FlowUtil_CallFutureSubFlow (fiList, recursion);
            Test.startTest();
            Id jobId = System.enqueueJob(cfs);
            Test.stopTest();
            System.assertNotEquals(jobId, null);
    }
    
    @isTest
    private static void CFS_CreateContactPoints_Test2(){
        List<Account> accList = [SELECT Id, CRM_CP_External_ID__c, IsBuyer FROM Account LIMIT 1];
        List<CRM_CP_FlowUtil_CFSVar> cfsList = createFlowInputList(accList, null);
        for(CRM_CP_FlowUtil_CFSVar cfs : cfsList){
            cfs.valueString = null;
        }
        CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput fi = new CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput();
        List<CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput> fiList = new List<CRM_CP_FlowUtil_CallFutureSubFlow.FlowInput>();
        fi.flowName = '';
        fi.cfsVarList = cfsList;
        fiList.add(fi);
        Set <String> recursion = new Set<String>();
        CRM_CP_FlowUtil_CallFutureSubFlow cfs = new CRM_CP_FlowUtil_CallFutureSubFlow (fiList, recursion);
        Test.startTest();
        Id jobId = System.enqueueJob(cfs);
        Test.stopTest();
        System.assertNotEquals(jobId, null);
    }
}