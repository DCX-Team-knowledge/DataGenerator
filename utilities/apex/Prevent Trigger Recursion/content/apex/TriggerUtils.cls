/**
 * =================================================================================
 * @description     : Utility class to prevent reruns of the same Trigger Operation
 * @author          : Gerald T. A. Bartels - Capgemini
 * @last modified on: 17-02-2022
 * @last modified by: Gerald T. A. Bartels
 * =================================================================================
 */
public with sharing class TriggerUtils {

    @TestVisible
    private static Map<Id, Set<System.TriggerOperation>> handledRecords = new Map<Id, Set<System.TriggerOperation>>();

    /**
     * @description Filters out handled records
     */
    public static List<SObject> filterOutHandledRecords(List<SObject> triggerNewList, System.TriggerOperation operation, Boolean isUpdate) {
        List<SObject> newRecords = new List<SObject>();
        for (SObject sob : triggerNewList) {
            if (isNotHandled(sob.Id, operation, isUpdate))
                newRecords.add(sob);
        }
        return newRecords;
    }

    /**
     * @description Checks if the record Id has not been handled in the context (operation)
     * The method will ensure that if an Insert operation has happened, an Update is not
     * happening in the same transaction. (Updates that need to happen during an Insert,
     * should be added to the Insert Trigger)
     * @return true if:
     *              - The record Id is not in the Map, and therefore not handled
     *              - The record Id is in the Map, but not with the corresponding operation,
     *                unless it's an Update Operation and an Insert has already happened
     * @return false otherwise
     * Note: Before Insert doesn't have the Salesforce Id
     */
    private static Boolean isNotHandled(Id id, System.TriggerOperation operation, Boolean isUpdate){
        if (!handledRecords.containsKey(id)){
            handledRecords.put(id, new Set<System.TriggerOperation>{operation});
            return true;
        }
        if (!handledRecords.get(id).contains(operation)){
            handledRecords.get(id).add(operation);
            if (!isUpdate || !handledRecords.get(id).contains(System.TriggerOperation.AFTER_INSERT)) return true;
        }
        return false;
    }
}