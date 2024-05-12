/**
* @author   	: Gerald Bartels
* @date 		: 16-01-2023
* @description 	: The Apex Defined Flow variable for CRM_CP_FlowUtil_FilterCollection
                  To verify conditions using CRM_CP_RulesUtil

* ------------------------------------------ Versions -------------------------------------------------------------------
* Version 1.0  : Gerald Bartels
*/
public inherited sharing class CRM_CP_FlowUtil_FlowConditions {
    /**
     * @description The field API names, whose fields to check conditions on
     */
    @AuraEnabled
    public String fieldApiNames;

    /**
     * @description The values the fields must equal
     */
    @AuraEnabled
    public String fieldValues;

    /**
     * @description The operators combining the fields with their values
     */
    @AuraEnabled
    public String operators;

    /**
     * @description The logic (AND/OR) between multiple conditions
     */
    @AuraEnabled
    public String conditionLogic;

    /**
     * @description the separator, if multiple conditions. Default is semi-colon (;)
     */
    @AuraEnabled
    public String separator = ';';
}