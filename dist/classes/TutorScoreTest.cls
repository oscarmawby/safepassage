@isTest
public class TutorScoreTest {
     
    @isTest
    public static void criteriaHardDifferentAreaReturnNull(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);
		
        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Liverpool','Secondary','English ; Maths');
        update data.tutor;
        Engagement__c tEng = data.createtutorEng(true,data.tutor);
        test.stopTest();
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,AdvancedTutorPathwaySpecific__c ,TutorYPRatio__c,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id, School_Type__c, ActiveTutor__c,AreaPicklist__c, Area__c,Tutor_Secondary_Skill_Set__c,Advanced_Tutor_Status__c,SecondarySchoolSubjects__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        List<MatchingCriteria__mdt> metaData = TutorScore.getMetaData();
        
        Map<String,Decimal> score = TutorScore.calculateScoreFromMeta(position, tutor, metaData);
        system.assertEquals(null, score);
    }
    
    @isTest
    public static void criteriaSoftActiveTutorScoreOne(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Maths');
        update data.tutor;
        test.stopTest();
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,AdvancedTutorPathwaySpecific__c ,TutorYPRatio__c,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id, ActiveTutor__c, School_Type__c, AreaPicklist__c,Area__c,Tutor_Secondary_Skill_Set__c,Advanced_Tutor_Status__c,SecondarySchoolSubjects__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
		List<MatchingCriteria__mdt> metaData = TutorScore.getMetaData();
        
        system.debug(position.Area__c + ' Area');
        system.debug(tutor + ' Tutor');
        system.debug(metaData + ' Metadata');
        Map<String,Decimal> score = TutorScore.calculateScoreFromMeta(position, tutor, metaData);
        system.debug(score + ' Score');
        system.assertNotEquals(null, score.get('Score'));
    }
    
    @isTest
    public static void criteriaSoftContainsSecondaryScoreThree(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Maths');
        update data.tutor;
        test.stopTest();
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,TutorYPRatio__c,AdvancedTutorPathwaySpecific__c ,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id, School_Type__c,ActiveTutor__c,Advanced_Tutor_Status__c, AreaPicklist__c,Area__c,Tutor_Secondary_Skill_Set__c,SecondarySchoolSubjects__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        List<MatchingCriteria__mdt> metaData = TutorScore.getMetaData();
        
        Map<String,Decimal> score = TutorScore.calculateScoreFromMeta(position, tutor, metaData);
        system.assertNotEquals(null, score.get('Score'));
    }
    
    @isTest
    public static void criteriaSoftContainsSubjectGivenValueScoreFour(){
        GeolocationTest.setMock('GetPostcodeResponse');
        DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Science');
        update data.tutor;
        test.stopTest();
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,TutorYPRatio__c,AdvancedTutorPathwaySpecific__c ,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id,School_Type__c,ActiveTutor__c,WeeklyPositionSubscription__c,Advanced_Tutor_Status__c,AreaPicklist__c, Area__c,Tutor_Secondary_Skill_Set__c,SecondarySchoolSubjects__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        List<MatchingCriteria__mdt> metaData = TutorScore.getMetaData();
        
        Map<String,Decimal> score = TutorScore.calculateScoreFromMeta(position, tutor, metaData);
        system.assertNotEquals(null, score.get('Score'));
    }
    
    @isTest
    public static void checkFieldsAreQueried(){
        GeolocationTest.setMock('GetPostcodeResponse');
       	DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Science');
        update data.tutor;
        test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Tutor'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='john@acme.com', ContactId = data.tutor.Id);
        
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,AdvancedTutorPathwaySpecific__c ,TutorYPRatio__c,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id,School_Type__c, WeeklyPositionSubscription__c,ActiveTutor__c, AreaPicklist__c,SecondarySchoolSubjects__c,Area__c,Tutor_Secondary_Skill_Set__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        System.debug(tutor.School_Type__c);
        System.debug(position.SchoolTypeMatching__c);
        
        List<TutorScore.wrapperClass> wrapperObjs;
        System.runAs(u) {
			wrapperObjs = TutorScore.getAllObjects();
        }
        
        System.assertNotEquals(wrapperObjs.size(),null);
        System.assertNotEquals(wrapperObjs[0].score,null);
    }
    
    @isTest
    public static void checkFieldsAreQueriedPositions(){
        GeolocationTest.setMock('GetPostcodeResponse');
       	DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Science');
        update data.tutor;
        test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Tutor'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='john@acme.com', ContactId = data.tutor.Id);
        
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,AdvancedTutorPathwaySpecific__c ,TutorYPRatio__c,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id, WeeklyPositionSubscription__c,ActiveTutor__c,School_Type__c, AreaPicklist__c,Area__c,SecondarySchoolSubjects__c,Tutor_Secondary_Skill_Set__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        System.debug(tutor.School_Type__c);
        System.debug(position.SchoolTypeMatching__c);
        
        List<TutorScore.wrapperClass> wrapperObjs;
        System.runAs(u) {
			wrapperObjs = TutorScore.getAllPositions(data.pos.Id);
        }
        
        System.assertNotEquals(wrapperObjs.size(),null);
        System.assertNotEquals(wrapperObjs[0].score,null);
    }
    
    @isTest
    public static void checkFieldsAreQueriedListPositions(){
        GeolocationTest.setMock('GetPostcodeResponse');
       	DataFactory data = new DataFactory();
        test.startTest();
        data.areaSchool = 'Leeds';
        data.constSchoolType = 'Secondary';
        data.createSession(true);
        data.createPos(true);

        data.tutor = data.createContact(true,'yp 2',data.tutorRecordTypeId,'Leeds','Secondary','English ; Science');
        update data.tutor;
        test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Tutor'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='john@acme.com', ContactId = data.tutor.Id);
        
        Position__c position = [SELECT ID,Cohort__c,SchoolTypeMatching__c,AdvancedTutorPathwaySpecific__c ,TutorYPRatio__c,DayofWeek__c,Area__c,Subject__c,HighPriorityPosition__c,Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s,Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s FROM Position__c WHERE Id =: data.pos.Id];
        Contact tutor = [SELECT Id, WeeklyPositionSubscription__c,ActiveTutor__c,School_Type__c, AreaPicklist__c,Area__c,SecondarySchoolSubjects__c,Tutor_Secondary_Skill_Set__c,Geolocation__Longitude__s,Geolocation__Latitude__s FROM Contact WHERE ID =: data.tutor.Id];
        System.debug(tutor.School_Type__c);
        System.debug(position.SchoolTypeMatching__c);
        
        List<Position__c> listOfPositions = new List<Position__c>();
        listOfPositions.add(data.pos);
        
        List<Contact> wrapperObjs;
        System.runAs(u) {
			wrapperObjs = TutorScore.getAllRelevantContacts(listOfPositions);
        }
        
        System.assertNotEquals(wrapperObjs.size(),null);
    }
    
}