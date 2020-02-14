<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Questionnaire_and_Responses_to_Intake_Client</fullName>
        <description>Send Questionnaire and Responses to Intake Client</description>
        <protected>false</protected>
        <recipients>
            <field>litify_pm__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/Send_Questionnaire_and_Responses_to_Client</template>
    </alerts>
    <alerts>
        <fullName>Send_Turned_Down_Email_to_Potential_Client</fullName>
        <description>Send Turn Down Email to Potential Client</description>
        <protected>false</protected>
        <recipients>
            <field>litify_pm__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/Turn_Down_Email</template>
    </alerts>
    <alerts>
        <fullName>Send_Welcome_Email_to_Client</fullName>
        <description>Send Welcome Email to Client</description>
        <protected>false</protected>
        <recipients>
            <field>litify_pm__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>litify_pm__Litify_Support/Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>litify_tso_Questionnaire_Output_Email_Alert</fullName>
        <description>Questionnaire Output Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>litify_tso_Questionnaire_Recipient__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/litify_tso_Questionnaire_Output_Email</template>
    </alerts>
    <rules>
        <fullName>Send Turn Down Email</fullName>
        <actions>
            <name>Send_Turned_Down_Email_to_Potential_Client</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>litify_pm__Intake__c.litify_pm__Status__c</field>
            <operation>equals</operation>
            <value>Turned Down</value>
        </criteriaItems>
        <description>Once the status is set to &quot;Turned Down&quot; send the turn down email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Welcome Email</fullName>
        <actions>
            <name>Send_Welcome_Email_to_Client</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>litify_pm__Intake__c.litify_pm__Status__c</field>
            <operation>equals</operation>
            <value>Retainer Agreement Signed</value>
        </criteriaItems>
        <description>Once the status is set to &quot;Referral Agreement Signed&quot; send the welcome email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Intake Status to %22Working%22</fullName>
        <actions>
            <name>Set_Intake_Status_to_Working</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>litify_pm__Intake__c.litify_pm__Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>litify_pm__Intake__c.litify_pm__Questionnaire_Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the Questionnaire is started on an Open intake, update the Status to &quot;Working&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
