/*****************************************************************************
* @author Capgemini: Gerald Bartels
* @date 03-11-2023
* @description Flow Invocable class to insert/update a record and receive a user friendly response
* @history
* -------
* VERSION | AUTHOR | DATE | DESCRIPTION
* 1.0 | Capgemini: Gerald Bartels | 03-11-2023 | Created
*****************************************************************************/
public class FlowUtil_SafeDML {
    
    public class FlowInput {
        @InvocableVariable(label='SObject to insert/update')
        public SObject sob;
        @InvocableVariable(label='SObject List to insert/update')
        public List<SObject> sobList;
        @InvocableVariable(label='DML method (Insert, Update)' required=true)
        public String dmlMethod;
    }
    
    public class FlowOutput {
        @InvocableVariable(label='Is Success status')
        public Boolean status;
        @InvocableVariable(label='Error from SObject')
        public String sobError;
        @InvocableVariable(label='Errors from SObject List')
        public List<String> sobErrorList;
        @InvocableVariable(label='Is Success status List')
        public List<Boolean> statusList;
    }

    @InvocableMethod(label='TD : Safe DML Operations' category='Test Data' description='Test Data: Safe DML Operations')
    public static List<FlowOutput> safeDml(List<FlowInput> fiList){
        if (!hasProperInput(fiList)) return new List<FlowOutput>();
        Boolean singleSob = fiList.get(0).sob != null;
        String dmlMethod = fiList.get(0).dmlMethod;
        List<SObject> sobUpsertList = new List<SObject>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        
        for (FlowInput fi : fiList){
            if (singleSob) sobUpsertList.add(fi.sob);
            else sobUpsertList.addAll(fi.sobList);
        }
        if (dmlMethod.toLowerCase() == 'insert') srList.addAll(Database.insert(sobUpsertList, false));
        if (dmlMethod.toLowerCase() == 'update') srList.addAll(Database.update(sobUpsertList, false));

        return createFlowOutput(fiList, srList, singleSob);
    }
    
    private static boolean hasProperInput(List<FlowInput> fiList){
        if (fiList == null || fiList.isEmpty()) return false;
        for (FlowInput fi : fiList){
            if ((fi.sob == null && fi.sobList == null)
               || (fi.sob != null && fi.sobList != null)) return false;
        }
        return true;
    }
    
    private static List<FlowOutput> createFlowOutput(List<FlowInput> fiList, List<Database.SaveResult> srList, Boolean singleSob){
        Integer counter = 0;
        System.debug(srList);
        List<FlowOutput> foList = new List<FlowOutput>();
        for (Integer i=0; i<fiList.size(); i++){
            FlowOutput fo = new FlowOutput();
            if (singleSob){
                fo.Status = srList.get(counter).isSuccess();
                if (!fo.Status) fo.sobError = srList.get(counter).getErrors().get(0).getMessage();
                counter++;
            }
            else {
                Boolean combinedStatus = true;
                fo.sobErrorList = new List<String>();
                fo.statusList = new List<Boolean>();
                for (Integer j=0; j<fiList.get(i).sobList.size(); j++){
                    fo.statusList.add(srList.get(counter).isSuccess());
                    if (!srList.get(counter).isSuccess()){
                        fo.sobErrorList.add(srList.get(counter).getErrors().get(0).getMessage());
                        combinedStatus = false;
                    }
                    else {
                        fo.sobErrorList.add('Success');
                    }
                    counter++;
                }
                fo.Status = combinedStatus;
            }
            foList.add(fo);
        }
        return foList;
    }
}