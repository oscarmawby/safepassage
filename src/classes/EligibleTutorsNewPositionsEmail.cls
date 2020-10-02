global class EligibleTutorsNewPositionsEmail {
    
    @InvocableMethod
    public static void sendEmails(List<Position__c> positions) {
        List<Contact> listContacts = TutorScore.getAllRelevantContacts(positions);
        
        List<Id> listIds= new List<Id>();
        
        for(Contact c : listContacts) {
            listIds.add(c.id);
        }
        
        EmailTemplate et = [SELECT Id From EmailTemplate WHERE Name = 'EmailTemplatename' limit 1];
        
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setTargetObjectIds(listIds);
        mail.setSenderDisplayName('System Admin');
        mail.setTemplateId(et.Id);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }

}