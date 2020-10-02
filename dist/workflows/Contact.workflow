<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Register_Reminder_Email_Contact</fullName>
        <description>Register Reminder Email Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TutorEmails/CompleteRegisterReminder</template>
    </alerts>
</Workflow>
