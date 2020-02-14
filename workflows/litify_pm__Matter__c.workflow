<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Matter_Owner_Email_Alert</fullName>
        <description>Matter Owner Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/Matter_Assigned_to_User</template>
    </alerts>
    <alerts>
        <fullName>New_Matter_Email_Alert</fullName>
        <description>New Matter Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>services-template@litify.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/New_Matter_Notification</template>
    </alerts>
    <rules>
        <fullName>Matter Owner is Changed</fullName>
        <actions>
            <name>Matter_Owner_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Runs when the Owner of a Matter record is changed.</description>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
