@isTest
public class IB_RegisterServerControllerTest {

    IBRegisterSetting__mdt setting;

    @isTest
    public static void checkGetNoEnrolments(){
        IBRegisterSetting__mdt setting = IB_RegisterServerController.getSettings();
        sObject ev = createData(false, setting);
        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);
        system.assertEquals(0,wrappers.size());
    }

    @isTest
    public static void checkGetEnrolments(){
        IBRegisterSetting__mdt setting = IB_RegisterServerController.getSettings();
        if(setting==null||setting.EnrolmentObject__c==null){
            system.assert(true);
        }else{
            sObject ev = createData(false, setting);
            String attString = IB_RegisterServerController.getAttendees(ev.Id);
            List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);
                system.assertEquals(1,wrappers.size());
        }        
    }

    @isTest
    public static void checkGetPreviousAbsent(){
        IBRegisterSetting__mdt setting = IB_RegisterServerController.getSettings();
        sObject ev = createData(false, setting);
        //sObject att = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).newSObject() ;
        sObject att = createPreAttendance(ev);
        att.put(setting.AttendanceEventLookupField__c,ev.Id);

        if(setting.EnrolmentObject__c!=null){
            String enrolQuery = 'SELECT Id FROM '+setting.EnrolmentObject__c;
            sObject enrol = database.query(enrolQuery);
            att.put(setting.AttendanceEnrolmentLookupField__c,enrol.Id);
        }

        if(setting.AttendanceStatusField__c!=null){
            att.put(setting.AttendanceStatusField__c,'');
        }
        if(setting.AttendanceBooleanField__c!=null){
            att.put(setting.AttendanceBooleanField__c,false);
        }
        upsert att;

        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);

        if(setting.AttendanceStatusField__c!=null){
            system.assertEquals(null,wrappers[0].status);
        }
        if(setting.AttendanceBooleanField__c!=null){
            system.assertEquals(false,wrappers[0].statusBoolean);
        }
    }

    @isTest
    public static void checkGetPreviousAttended(){
        IBRegisterSetting__mdt setting = IB_RegisterServerController.getSettings();
        sObject ev = createData(false, setting);
        //sObject att = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).newSObject() ;
        
        sObject att = createPreAttendance(ev);
        att.put(setting.AttendanceEventLookupField__c,ev.Id);

        if(setting.EnrolmentObject__c!=null){
            String enrolQuery = 'SELECT Id FROM '+setting.EnrolmentObject__c;
            sObject enrol = database.query(enrolQuery);
            att.put(setting.AttendanceEnrolmentLookupField__c,enrol.Id);
        }
        
        String attendedStatus;
        if(setting.AttendanceStatusField__c!=null){ 
            attendedStatus = getAttStatus();
            att.put(setting.AttendanceStatusField__c,getAttStatus());
        }
        if(setting.AttendanceBooleanField__c!=null){
            att.put(setting.AttendanceBooleanField__c,true);
        }
        upsert att;

        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);

        if(setting.AttendanceStatusField__c!=null){
            system.assertEquals(attendedStatus,wrappers[0].status);
        }
        if(setting.AttendanceBooleanField__c!=null){
            system.assertEquals(true,wrappers[0].statusBoolean);
        }        
    }
    
    @isTest
    public static void checkCanGetPicklistValue() {
        system.assertEquals(IB_RegisterServerController.getPicklistvalues().size(),3);
    }

    @isTest
    public static void checkSave(){
        IBRegisterSetting__mdt setting = IB_RegisterServerController.getSettings();
        sObject ev = createData(false, setting);
        createPreAttendance(ev);
        
        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);
        for(IB_RegisterServerController.AttendanceWrapper wrapper: wrappers){
            if(setting.AttendanceStatusField__c!=null){ 
                wrapper.status = getAttStatus();
            }
            if(setting.AttendanceBooleanField__c!=null){
                wrapper.statusBoolean = true;
            }            
        }
        IB_RegisterServerController.saveRecords(JSON.serialize(wrappers),IB_RegisterServerController.getEventWrapperString(ev.Id));

        String query = 'SELECT Id FROM '+setting.AttendanceObject__c+' WHERE ';
        if(setting.AttendanceStatusField__c!=null){
            query = query + setting.AttendanceStatusField__c + ' = \''+getAttStatus()+'\'';
        }
        if(setting.AttendanceStatusField__c!=null&&setting.AttendanceBooleanField__c!=null){
            query = query + ' AND ';
        }
        if(setting.AttendanceBooleanField__c!=null){
            query = query + setting.AttendanceBooleanField__c + ' = true';
        }
        
        List<sObject> atts = database.query(query);
        system.assertEquals(1,atts.size());
    }

    public static String getAttStatus(){
        Map<String,String> options;// = IB_RegisterServerController.getStatusOptions();
        List<String> keys = new List<String>(options.keySet());
        return options.get(keys[0]);
    }
    
    public static Attendance__c createPreAttendance(sObject ev){
         
        Cohort__c co = [SELECT Id FROM Cohort__c][0];
        
        String rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Pupil').getRecordTypeId();
        Contact c = new Contact(
            LastName = 'Test',
            RecordTypeID = rtId
        );
        insert c;
        
        Engagement__c eng = new Engagement__c (
            Cohort__c = co.Id,
            Pupil__c = c.Id
        );
        insert eng;
        
        Attendance__c att = new Attendance__c(
            Session__c = ev.Id,
            Engagement__c = eng.Id
        );
        insert att;
        return att;
    }

    public static sObject createData(Boolean addEnrol, IBRegisterSetting__mdt setting){
        sObject prog;
        if(setting.ProgrammeObject__c!=null){
            prog = Schema.getGlobalDescribe().get(setting.ProgrammeObject__c).newSObject() ;
            prog.put('Name', 'Prog');
            insert prog;
        }
        
        Account acc = new Account(
            Name = 'acc',
            FinanceContactEmail__c = 'fake@email.com',
            FinanceContactName__c = 'Finance Name',
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('School').getRecordTypeId()
        );
        insert acc;
        
        Assignment__c ass = new Assignment__c(
            School__c = acc.Id,
            Name = 'ass',
            StartDate__c = system.today(),
            EndDate__c = system.today()+1
        );
        insert ass;
        
        SubjectYearKPI__c sKPi = new SubjectYearKPI__c (
            Name = 'sKPi',
            Subject__c = 'English'
        );
        insert sKPi;
        
        Cohort__c co = new Cohort__c(
            Assignment__c = ass.Id,
            Name = 'Cohort',
            SubjectYearKPI__c = sKPi.Id
        );
        insert co;
        
        sObject ev = Schema.getGlobalDescribe().get(setting.EventObject__c).newSObject();
        ev.put('Name', 'Event');
        if(setting.ProgrammeObject__c!=null&&setting.EventProgrammeLookupField__c!=null){
            ev.put(setting.EventProgrammeLookupField__c,prog.Id);
        }
        if(setting.EventDateField__c!=null){
            ev.put(setting.EventDateField__c,system.today());
        }
        if(setting.EventDateField__c!=null){
            ev.put(setting.EventDateTimeField__c,system.now());
        }
        if(setting.EventTimeField__c!=null){
            ev.put(setting.EventTimeField__c,system.now().time());
        }
        ev.put('Cohort__c',co.id);
        insert ev;

        if(addEnrol){
            sObject enrol = Schema.getGlobalDescribe().get(setting.EnrolmentObject__c).newSObject();
            if(setting.EnrolmentObject__c=='Contact'){
                enrol.put('LastName', 'Enrol');
            }else{
                enrol.put('Name', 'Enrol');
            }
            enrol.put(setting.EnrolmentProgrammeLookupField__c,prog.Id);
            insert enrol;
        }
        return ev;
    }
}