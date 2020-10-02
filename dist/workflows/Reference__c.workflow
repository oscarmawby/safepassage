<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Reference_Request</fullName>
        <ccEmails>oscar@impactbox.co.uk</ccEmails>
        <description>Reference Request</description>
        <protected>false</protected>
        <recipients>
            <field>RefereeEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TutorEmails/Referencing_Request</template>
    </alerts>
</Workflow>
