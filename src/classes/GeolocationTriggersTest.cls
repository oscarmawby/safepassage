@isTest public class GeolocationTriggersTest {
    
    @isTest public static void accountTrig(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        Account acc = data.createSchool(false);
        acc.BillingPostalCode = 'BS6 7EX';
        test.startTest();
        insert acc;
        test.stopTest();
        List<Account> accs = [SELECT Id FROM Account WHERE Geolocation__Latitude__s !=null AND Id =: acc.Id];
        system.assertEquals(1, accs.size());
    }

    @isTest public static void contactTrig(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        Contact con = data.createContact(false, 'Test',data.pupilRecordTypeId, 'Liverpool', 'Primary', 'Maths');
        con.MailingPostalCode = 'BS6 7EX';
        test.startTest();
        insert con;
        test.stopTest();
        List<Contact> cons = [SELECT Id FROM Contact WHERE Geolocation__Latitude__s !=null AND Id =: con.Id];
        system.assertEquals(1, cons.size());        
    }
}