
/*****************************************************************************
* @author Capgemini: Gerald Bartels
* @date 08-12-2023
* @description A flow utility class to call an autolaunched flow asynch
* @history
* -------
* VERSION | AUTHOR | DATE | DESCRIPTION
* 1.0 | Capgemini: Gerald Bartels | 08-12-2023 | Created
*****************************************************************************/
public inherited sharing class CRM_CP_FlowUtil_CallFutureSubFlow implements Queueable {
    private static final String CLASS_NAME = 'CRM_CP_FlowUtil_CallFutureSubFlow';
    private List<FlowInput> fiList;
    private static Set<String> recursionSet = new Set<String>();

    public class FlowInput {
        @InvocableVariable(required=true label='Flow Name')
        public String flowName;

        @InvocableVariable(label='Flow Name Space (optional)')
        public String flowNameSpace;

        @InvocableVariable(label='List of Flow variables (optional)')
        public List<CRM_CP_FlowUtil_CFSVar> cfsVarList;
    }

    /**
    * @author Gerald Bartels
    * @date 08-12-2023
    * @description Invocable method to call from flow
    * @param fiList Flow Input list
    */
    @InvocableMethod
    public static void callFutureFlow(List<FlowInput> fiList){
        try {
            if (fiList.isEmpty() || recursionSet.contains(fiList.get(0).flowName)) return;
            
            System.enqueueJob(new CRM_CP_FlowUtil_CallFutureSubFlow(fiList, recursionSet));
        } catch (Exception ex){
            CRM_CP_ErrorLoggerFramework.insertApplicationErrorLog(CLASS_NAME, 'processCalloutResponse', ex, null);
        }
    }

    public CRM_CP_FlowUtil_CallFutureSubFlow(){}

    public CRM_CP_FlowUtil_CallFutureSubFlow(List<FlowInput> fiList, Set<String> recursionInputSet){
        this.fiList = fiList;
        recursionSet = recursionInputSet;
    }

    /**
    * @author Gerald Bartels
    * @date 08-12-2023
    * @description Execute method of the queueable
    * @param context QueueableContext
    */
    public void execute(QueueableContext context){
        try {
            if (this.fiList.isEmpty()) return;
            FlowInput fi = this.fiList.remove(0);
            recursionSet.add(fi.flowName);

            Map<String, Object> flowInputMap = getFlowInputMap(fi);
            Flow.Interview flowState;

            if (fi.flowNameSpace == null) flowState = Flow.Interview.createInterview(fi.flowName, flowInputMap);
            else flowState = Flow.Interview.createInterview(fi.flowNameSpace, fi.flowName, flowInputMap);
            flowState.start();

            if (!this.fiList.isEmpty() && !Test.isRunningTest()) System.enqueueJob(new CRM_CP_FlowUtil_CallFutureSubFlow(this.fiList, recursionSet));
        } catch (Exception ex){
            CRM_CP_ErrorLoggerFramework.insertApplicationErrorLog(CLASS_NAME, 'processCalloutResponse', ex, null);
        }
    }

    private static Map<String, Object> getFlowInputMap(FlowInput fi){
        Map<String, Object> flowInputMap = new Map<String, Object>();
        for (CRM_CP_FlowUtil_CFSVar cfsVar : fi.cfsVarList){
            Object value = getCfsValue(cfsVar);
            if (value == null) continue;
            flowInputMap.put(cfsVar.variableName, value);
        }
        return flowInputMap;
    }
    
    private static Object getCfsValue(CRM_CP_FlowUtil_CFSVar cfsVar){
        if (cfsVar.valueString != null) return cfsVar.valueString;
        else if (cfsVar.valueInteger != null) return cfsVar.valueInteger;
        else if (cfsVar.valueDate != null) return cfsVar.valueDate;
        else if (cfsVar.valueDateTime != null) return cfsVar.valueDateTime;
        else if (cfsVar.valueBoolean != null) return cfsVar.valueBoolean;
        else return null;
    }
}