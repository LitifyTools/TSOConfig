<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_new_Trialforce_What_to_Expect_email_instructions</fullName>
        <description>Send new Trialforce &quot;What to Expect&quot; email/instructions</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/New_Trialforce_Welcome_What_to_Expect</template>
    </alerts>
    <rules>
        <fullName>User%3A new System Administrator created</fullName>
        <actions>
            <name>Send_new_Trialforce_What_to_Expect_email_instructions</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Triggers where new System Administrator is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
