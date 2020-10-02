@isTest
public class DataFactory {
    public Account school;
    public String areaSchool;
    public String constSchoolType;
    public Assignment__c ass;
    public SubjectYearKPI__c sYear;
    public Cohort__c cohort;
    public Position__c pos;
    public Session__c session;
    public Session__c session2;
    public Opportunity opp;
    public Contact tutor;
    public Contact yp1;
    public Contact yp2;
    public Engagement__c tEng;
    public String schoolRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId();
    public String tutorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Tutor').getRecordTypeId();
    public String pupilRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Pupil').getRecordTypeId();
    public String tutorEngRecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Tutor').getRecordTypeId();
    public String pupilEngRecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('KS2 Pupil').getRecordTypeId();
    public String tutorAttRecordTypeId = Schema.SObjectType.Attendance__c.getRecordTypeInfosByName().get('Tutor').getRecordTypeId();
    public String pupilAttRecordTypeId = Schema.SObjectType.Attendance__c.getRecordTypeInfosByName().get('Pupil').getRecordTypeId();

    public Account createSchool(Boolean isInsert){
        school = new Account(
            RecordTypeId = schoolRecordTypeId,
            Name = 'School', 
            School_Type__c = constSchoolType,
            SchoolTypePhase2__c = constSchoolType,
            //School_Type__c = constSchoolType,
            Area__c = this.areaSchool,
            AreaP2__c = this.areaSchool,
            BillingPostalCode = 'E2 0LN',
            Geolocation__Longitude__s = -0.05004,
            Geolocation__Latitude__s = 51.52636
        );
        if(isInsert){
            insert school;
        }
        return school;
    }
    
    public Contact createContact(Boolean isInsert, String name, String recordTypeId, String area, String schoolType, String skillSet){
		Contact con = new Contact(
            LastName = name,
            RecordTypeId = recordTypeId,
            AccountId = (school == null) ? createSchool(true).Id : school.Id,
            AreaPicklist__c = area,
            School_Type__c = schoolType,
            Tutor_Secondary_Skill_Set__c = skillSet,
            SecondarySchoolSubjects__c = skillSet,
            MaxSessionDate__c = Date.newInstance(2020, 12, 17),
            MailingPostalCode = 'E2 0LN',
            Geolocation__Longitude__s = -0.05004,
            Geolocation__Latitude__s = 51.52636,
            WeeklyPositionSubscription__c = true
        );
        if(isInsert){
            insert con;
        }
        return con;
    } 
    
    public Assignment__c createAssignment(Boolean isInsert){
        ass = new Assignment__c(
            Name = 'Assignment',
            AssignmentOwner__c = UserInfo.getUserId(),
            StartDate__c  = system.today()+10,
            School__c = (school == null) ? createSchool(true).Id : school.Id
        );
        if(isInsert){
            insert ass;
        }
        return ass;
    } 
    
    public Opportunity createOpp(Boolean isInsert){
        opp = new Opportunity(
            Name = 'Assignment',
            StageName = 'ClosedWon',
            StartDate__c  = system.today()+10,
            CloseDate  = system.today()+10,
            Amount  = 10,
            AccountId = (school == null) ? createSchool(true).Id : school.Id,
            School__c = (school == null) ? createSchool(true).Id : school.Id
        );
        if(isInsert){
            insert opp;
        }
        return opp;
    } 
    
    public SubjectYearKPI__c createSubject(Boolean isInsert){
        sYear = new SubjectYearKPI__c(
            Name = 'English 20',
            Subject__c = 'English',
            AcademicYear__c = '2020-21'
        );
        if(isInsert){
            insert sYear;
        }
        return sYear;
    }
    
    public Cohort__c createCohort(Boolean isInsert){
        cohort = new Cohort__c(
            Name = 'Cohort',
            Opportunity__c = opp==null? createOpp(true).Id: opp.Id,
            Assignment__c  = (ass == null) ? createAssignment(true).Id : ass.Id,
            SubjectYearKPI__c = (sYear == null) ? createSubject(true).Id : sYear.Id,
            Subject__c = 'English',
            SchoolYear__c = '10',
            StartDate__c  = system.today()-10,
            EndDate__c  = system.today()+10
        );
        if(isInsert){
            insert cohort;
        }
        return cohort;
    }
    
    public Engagement__c createPupilEng(Boolean isInsert, Contact yp){
        Engagement__c eng = new Engagement__c (
            RecordTypeId = tutorEngRecordTypeId,
            PupilsTutor__c = (tEng == null) ? createtutorEng(true, tutor).Id : tEng	.Id,
            Pupil__c = yp.Id,
            Cohort__c = (cohort == null) ? createCohort(true).Id : cohort.Id
        ); 
        if(isInsert){
            insert eng;
        }
        return eng;
    }
    
    public Engagement__c createtutorEng(Boolean isInsert, Contact tutor){
        tEng = new Engagement__c (
            RecordTypeId = tutorEngRecordTypeId,
            Tutor__c = tutor.Id,
            Cohort__c = (cohort == null) ? createCohort(true).Id : cohort.Id,
            Position__c = (pos == null) ? createPos(true).Id : pos.Id
        ); 
        if(isInsert){
            insert tEng;
        }
        return tEng;
    }
    
    public Position__c createPos(Boolean isInsert){
        pos = new Position__c(
            Cohort__c  = (cohort == null) ? createCohort(true).Id : cohort.Id,
            TutorYPRatio__c = '1:1',
            DayofWeek__c = 'Monday',
            StartDate__c = system.today()+10,
            EndDate__c  = system.today()+10,                         
            StartTime__c = Time.newInstance(18, 30, 2, 20),
            EndTime__c  = Time.newInstance(19, 30, 2, 20)
        );
        if(isInsert){
            insert pos;
        }
        return pos;
    } 
    
    public Session__c createSession(Boolean isInsert){
        Session__c session = new Session__c(
            Name = 'Session',
            Cohort__c  = (cohort == null) ? createCohort(true).Id : cohort.Id,
            SessionDate__c  = system.today()+10             
        );
        if(isInsert){
            insert session;
        }
        return session;
    }
    
    public Attendance__c createAttendance(Boolean isInsert, Engagement__c yp, Engagement__c tutor, Session__c session, String recordTypeId){
        system.debug(recordTypeId);
        system.debug(session);
        system.debug(tutor);
        Attendance__c att = new Attendance__c(
            RecordTypeId = recordTypeId,
            Session__c = session.Id,
            Engagement__c = yp.Id,
            Tutor__c = tutor.Id
        );
        if(isInsert){
            insert att;
        }
        return att;
    }

}