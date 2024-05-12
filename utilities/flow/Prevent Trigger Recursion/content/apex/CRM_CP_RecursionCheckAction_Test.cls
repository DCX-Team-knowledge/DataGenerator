/*****************************************************************************
* @author       -
* @date         -
* @description  Test class for CRM_CP_RecursionCheckAction
* @history
* -------
* VERSION | AUTHOR                        | DATE         | DESCRIPTION
* 1.0     | -                             | -            | Created
* 2.0     | Capgemini: Gerald Bartels     | 24-10-2023   | Base it on record Id
*****************************************************************************/
@IsTest
@SuppressWarnings('PMD.TestClassShouldUseTestDataFactory') // No need to create records
private class CRM_CP_RecursionCheckAction_Test {
    private static List<CRM_CP_RecursionCheckAction.FlowInputs> createFlowInputs(Integer size, String processName){
        List<CRM_CP_RecursionCheckAction.FlowInputs> flowInputList = new List<CRM_CP_RecursionCheckAction.FlowInputs>();
        for (Integer i=0; i<size; i++){
            CRM_CP_RecursionCheckAction.FlowInputs flowInput = new CRM_CP_RecursionCheckAction.FlowInputs();
            flowInput.processName = processName;
            String customId = 'a4DJW';
            String indexString = String.valueOf(i);
            for (Integer j=0; j<7-indexString.length(); j++) customId += '0';
            customId += indexString + 'IY12AM';
            flowInput.recordId = (Id) customId;
            flowInputList.add(flowInput);
        }
        return flowInputList;
    }

    @IsTest
    private static void testRecursionCheckAction() {
        List<CRM_CP_RecursionCheckAction.FlowInputs> flowInputList = createFlowInputs(300, 'testRecursion1');

        Test.startTest();
        List<Boolean> responseList1 = CRM_CP_RecursionCheckAction.recursionCheckAction(flowInputList);
        List<Boolean> responseList2 = CRM_CP_RecursionCheckAction.recursionCheckAction(flowInputList);
        Test.stopTest();

        for (Boolean response : responseList1) System.assertEquals(true, response);
        for (Boolean response : responseList2) System.assertEquals(false, response);
    }
}
