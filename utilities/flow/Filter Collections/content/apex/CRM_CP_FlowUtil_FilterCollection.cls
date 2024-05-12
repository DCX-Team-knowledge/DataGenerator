/**
* @author   	: Gerald Bartels
* @date 		: 16-01-2023
* @description 	: A Flow Utility class to filter collections in Flows

* ------------------------------------------ Versions -------------------------------------------------------------------
* Version 1.0  : Gerald Bartels
*/
public with sharing class CRM_CP_FlowUtil_FilterCollection {
    private static final String CLASS_NAME = 'CRM_CP_FlowUtil_FilterCollection';

    /**
     * @description The Invocable method of the FlowUtil_FilterCollection class
     * @param flowInputList Flow Inputs
     * @return List<FlowOutput> Flow Outputs
     */
    @InvocableMethod(Label='Filter Collection')
    public static List<FlowOutput> getFieldCollection(List<FlowInput> flowInputList){
        try {
            List<FlowOutput> outputlist = new List<FlowOutput>();
            for (FlowInput input : flowInputList){
                outputlist.add(getFieldList(input));
            }
            return outputlist;
        } catch (Exception ex){
            CRM_CP_ErrorLoggerFramework.insertApplicationErrorLog(CLASS_NAME, 'getFieldCollection', ex, null);
        }
        return null;
    }

    /**
     * @description The core logic of the FilterCollection FlowUtility class
     * Checks conditions and adds the field-value/SObject to a Flow Output list
     * @param input The Flow Input
     * @return FlowOutput
     */
    private static FlowOutput getFieldList(FlowInput input){
        FlowOutput output = new FlowOutput();
        if (input.soblist.isEmpty()) return output;
        Set<Object> outputUniqueSet = new Set<Object>();

        Conditions cond = new Conditions(input);
        for (SObject sob : input.soblist){
            if (sob.get(input.searchField) == null) continue;
            if (input.returnOutputUnique && outputUniqueSet.contains(sob.get(input.searchField))) continue;
            if (!cond.isConditionSatisfied(sob)) continue;

            switch on input.returnDataType.toLowerCase() {
                when 'text', 'string' { output.text_list.add((String) sob.get(input.searchField)); }
                when 'number', 'integer' { output.integer_list.add((Integer) sob.get(input.searchField)); }
                when 'boolean' { output.boolean_list.add((Boolean) sob.get(input.searchField)); }
                when 'sobject' { output.sobject_list.add(sob); }
            }
            outputUniqueSet.add(sob.get(input.searchField));
        }
        return output;
    }

    private class Conditions {
        private FlowInput input;
        private Boolean noConditions = false;
        private Set<String> containsSet = new Set<String>();
        private List<Schema.SObjectField> schemaFieldList = new List<Schema.SObjectField>();
        private String[] fieldNameList;

        /**
         * @description Constructor to set up the Condition class
         * @param input The Flow Input parameter
         */
        public Conditions(FlowInput input){
            this.input = input;
            if (input.containslist == null && input.flow_conditions == null) this.noConditions = true;
            else {
                if (input.containslist != null) this.containsSet.addAll(input.containslist);
                if (input.flow_conditions != null){
                    this.fieldNameList = input.flow_conditions.fieldApiNames.split(input.flow_conditions.separator);
                    for (String fieldPart : this.fieldNameList){
                        schemaFieldList.add(input.soblist.get(0).getSObjectType().getDescribe().fields.getMap().get(fieldPart));
                    }
                }
            }
        }
        /**
         * @description A method to return whether the conditions are satisfied. Returns true if no conditions set
         * @param sob The SObject to check conditions for
         * @return Boolean whether the conditions are met (true) or not (false)
         */
        public Boolean isConditionSatisfied(SObject sob){
            if (this.noConditions) return this.noConditions;
            Boolean containsSetSatisfied = this.containsSet.isEmpty() || this.containsSet.contains(String.valueOf(sob.get(input.searchField)));
            return containsSetSatisfied && isAdvConditionSatisfied(sob);
        }

        /**
         * @description A method to check advanced conditions using CRM_CP_FlowUtil_FlowConditions and CRM_CP_RulesUtil
         * @param sob The SObject to check conditions for
         * @return Boolean whether the conditions are met (true) or not (false)
         */
        private Boolean isAdvConditionSatisfied(SObject sob){
            if (this.input.flow_conditions == null) return true;
            String conditionLogic = this.input.flow_conditions.conditionLogic;
            String[] fieldValueList = this.input.flow_conditions.fieldValues.split(this.input.flow_conditions.separator);
            String[] operatorList = this.input.flow_conditions.operators.split(this.input.flow_conditions.separator);

            if (!isSameLength(fieldNameList, fieldValueList, operatorList)){
                throw new FlowUtilException('FlowUtil Error: The input parameters of CRM_CP_FlowUtil_FlowConditions must be of same size! Current Size Field: ' + fieldNameList.size() + ' - Values: ' + fieldValueList.size() + ' - Operators: ' + operatorList.size());
            }

            for (Integer i=0; i < fieldValueList.size(); i++){
                String result = String.valueOf(CRM_CP_RulesUtil.compareField(this.schemaFieldList.get(i).getDescribe().getSoapType(), this.fieldNameList[i], operatorList[i], sob.get(this.fieldNameList[i]), fieldValueList[i]));
                conditionLogic = conditionLogic.replace(String.valueOf(i+1), result);
            }
            return new CRM_CP_RulesUtil.BooleanExpression().evaluate(conditionLogic);
        }

        private Boolean isSameLength(String[] a1, String[] a2, String[] a3){
            return a1.size() == a2.size() && a2.size() == a3.size();
        }
    }

    private class FlowUtilException extends Exception {}

    /**
     * @description The Flow Input variables
     *      Required variables:
     *      - soblist: the main list of SObjects to filter from
     *      - returnDataType: The data type to return (either: text, number, boolean, sobject)
     * 
     *      Optional variables:
     *      - searchField: an optional field API name, whose field value will be returned,
     *                      if returnDataType doesn't equal SObject. Default value: Id
     *      - returnOutputUnique: an optional value. Set this to true to only get unique values (based on searchField). Default is: false
     *      - containslist: an optional list of values for which searchField must be contained in.
     *                      i.e. only return SObjects whose searchField is contained in {'Active', 'Pending'}
     *      - flow_conditions: optionally, set more advanced conditions
     */
    public class FlowInput {
        @InvocableVariable(Label='SObject List' Required=true Description='The main list of SObjects to filter from')
        public List<SObject> soblist = new List<SObject>();

        @InvocableVariable(Label='Return data type' Required=true Description='The data type to return (either: text, number, boolean, sobject)')
        public String returnDataType;

        @InvocableVariable(Label='Get Field API name' Description='Field API name whose field value will also be returned, if returnDataType does not equal SObject. Default value: Id')
        public String searchField = 'Id';

        @InvocableVariable(Label='Should output be unique?' Description='Set this to true to only get unique values (based on searchField). Default is: false')
        public Boolean returnOutputUnique = false;

        @InvocableVariable(Label='Contains List' Description='An optional list of values for which searchField must be contained in. I.e. only return SObjects whose searchField is contained in {Active, Pending}')
        public List<String> containslist;

        @InvocableVariable(Label='Flow Conditions' Description='Set more advanced conditions')
        public CRM_CP_FlowUtil_FlowConditions flow_conditions;
    }

    /**
     * @description The Flow Output variables
     * The output will be returned in one of the lists below,
     * depending on the value of FlowInput.returnDataType
     */
    public class FlowOutput {
        @InvocableVariable(Label='Return type Text')
        public List<String> text_list = new List<String>();

        @InvocableVariable(Label='Return type Number')
        public List<Integer> integer_list = new List<Integer>();

        @InvocableVariable(Label='Return type Boolean')
        public List<Boolean> boolean_list = new List<Boolean>();

        @InvocableVariable(Label='Return type SObject')
        public List<SObject> sobject_list = new List<SObject>();
    }
}