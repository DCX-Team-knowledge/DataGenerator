/*****************************************************************************
* @author       -
* @date         -
* @description  Invocable class to prevent recursion
* @history
* -------
* VERSION | AUTHOR                        | DATE         | DESCRIPTION
* 1.0     | -                             | -            | Created
* 2.0     | Capgemini: Gerald Bartels     | 24-10-2023   | Base it on record Id
*****************************************************************************/
public without sharing class CRM_CP_RecursionCheckAction {
    private static final String CLASS_NAME = 'CRM_CP_RecursionCheckAction';

    @TestVisible
    private static Map<String, Set<Id>> processMap = new Map<String, Set<Id>>();

    /**
     * @description             The FlowInputs local class referenced in a Flow
     */
    public class FlowInputs {
        @InvocableVariable(
            label='Process Name'
            description='Process Name to stop from running more than once'
            required=true
        )
        public String processName;

        @InvocableVariable(
            label='Record Id'
            description='Record Id whose process should only run once'
            required=true
        )
        public Id recordId;
    }
    
    /**
     * @description             Checks if a specific record has already run a certain process
     * @param flowInputList     The Flow Input, using the FlowInputs local class
     * @return List<Boolean>    True = The record has not run the process yet. False otherwise
     */
    @InvocableMethod(label='Recursion Check Action' category='Flow Control')
    public static List<Boolean> recursionCheckAction(List<FlowInputs> flowInputList) {
        try {
            List<Boolean> response = new List<Boolean>();
            for (FlowInputs input : flowInputList) {
                if (input.processName == null || input.recordId == null) response.add(false);
                if (!processMap.containsKey(input.processName)) processMap.put(input.processName, new Set<Id>());

                if (processMap.get(input.processName).contains(input.recordId)) response.add(false);
                else response.add(true);

                processMap.get(input.processName).add(input.recordId);
            }
            return response;
        } catch (Exception ex){
            CRM_CP_ErrorLoggerFramework.insertApplicationErrorLog(CLASS_NAME, 'recursionCheckAction', ex, null);
        }
        return null;
    }
}