<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Update Phone</fullName>
        <actions>
            <name>Set_Primary_Phone_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Account.litify_pm__Phone_Mobile__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.litify_pm__Phone_Home__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populate &quot;Phone&quot; field on Party record when &quot;Phone Mobile&quot; or &quot;Phone Home&quot; have value(s). Party &quot;Phone&quot; field populates corresponding value on Intake records where that party is the Client.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
