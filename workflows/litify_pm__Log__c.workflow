<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>System_log_created_email_alert</fullName>
        <description>System log created email alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>litify_pm__Litify_Support/litify_pm__System_Log_Created_Email_Template</template>
    </alerts>
    <rules>
        <fullName>System Log Alert Email Notification</fullName>
        <actions>
            <name>System_log_created_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>litify_pm__Log__c.litify_pm__Severity__c</field>
            <operation>equals</operation>
            <value>ERROR,FATAL,WARNING</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
