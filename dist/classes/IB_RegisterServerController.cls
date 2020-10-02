public class IB_RegisterServerController {
    
    @AuraEnabled
    public static String getAttendees(Id eventId){
        IBRegisterSetting__mdt setting = getSettings();
        EventWrapper event = getEvent(eventId, setting);
        List<AttendanceWrapper> attWraps = getAllWrappers(event,setting);
        return JSON.serialize(attWraps);
    }
    
    @AuraEnabled
    public static List<String> getPicklistvalues() {
        List<String> optionlist = new List<String>();
        List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe().get('Session__c').getDescribe().fields.getMap().get('SessionType__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry pe : picklistValues) {
            optionlist.add(pe.getValue());
        }
        return optionlist;
    }
    
    @AuraEnabled
    public static Map<String,String> getStatusOptions(){
        IBRegisterSetting__mdt setting = getSettings();
        if(setting.AttendanceStatusField__c!=null){
            Map<String,String> allOptions = new Map<String,String>();
            list<Schema.PicklistEntry> fmap = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).getDescribe().fields.getMap().get(setting.AttendanceStatusField__c).getDescribe().getPicklistValues();        
            for( Schema.PicklistEntry f : fmap){
                allOptions.put( f.getLabel(),f.getValue());
            }
            return allOptions;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveRecords(String wrappersString, String eventString){
        IBRegisterSetting__mdt setting = getSettings();
        List<AttendanceWrapper> wrappers =(List<AttendanceWrapper>)System.JSON.deserialize(wrappersString, List<AttendanceWrapper>.class);
        EventWrapper eventWrapper = (EventWrapper)System.JSON.deserialize(eventString, EventWrapper.class);
        sObject event = eventWrapper.event;
        List<sObject> attRecsToCreate = new List<sObject>();
        List<sObject> attRecsToUpdate = new List<sObject>();
        
        for(AttendanceWrapper attWrap: wrappers){
            if(setting.AttendanceStatusField__c!=null){
                attWrap.attRec.put(setting.AttendanceStatusField__c,attWrap.status);
            }
            attWrap.attRec = assginHardcodedValues(setting.AttendanceObject__c, setting, attWrap.attRec);
            
            if(setting.AttendanceBooleanField__c!=null){
                if(setting.ExplicitlyMarkBooleanAbsence__c){
                    /*if(attWrap.statusBoolean){
                        attWrap.attRec.put(setting.AttendanceBooleanField__c,true);
                        if(attWrap.attRec.Id==null){
                            attRecsToCreate.add(attWrap.attRec);
                        }else{
                            attRecsToUpdate.add(attWrap.attRec);
                        }
                    }else if(attWrap.absentBoolean){
                        attWrap.attRec.put(setting.AttendanceBooleanField__c,false);
                        if(attWrap.attRec.Id==null){
                            attRecsToCreate.add(attWrap.attRec);
                        }else{
                            attRecsToUpdate.add(attWrap.attRec);
                        }
                    }*/
                }else{
                    attWrap.attRec.put(setting.AttendanceBooleanField__c,attWrap.statusBoolean);
                    if(attWrap.attRec.Id==null){
                        attRecsToCreate.add(attWrap.attRec);
                    }else{
                        attRecsToUpdate.add(attWrap.attRec);
                    }
                }
            }
        }
        if(setting.EventConfirmationDateField__c!=null){
            event.put(setting.EventConfirmationDateField__c,system.today());
        }
        update event;
        
        update attRecsToUpdate;        
        insert attRecsToCreate;
        if(wrappers.size()>0){
             return getAttendees((String)wrappers[0].attRec.get(setting.AttendanceEventLookupField__c));
        }else{
            return null;
        }       
    }
    
    @AuraEnabled
    public static IBRegisterSetting__mdt getSettings(){
        List<IBRegisterSetting__mdt> settings = [SELECT Id , EnrolmentObject__c, ProgrammeObject__c, EnrolmentProgrammeLookupField__c, 
                EventObject__c, EventProgrammeLookupField__c, EventDateField__c, EventDateTimeField__c, EventTimeField__c,
                AttendanceEnrolmentLookupField__c, AttendanceEventLookupField__c, AttendanceObject__c, AttendanceStatusField__c, 
                EnrolmentDisplayName__c, AttendanceBooleanField__c, EventTitleField__c, EnrolmentSortField__c,  
                EnrolmentSortOrder__c, EventConfirmationDateField__c, ExplicitlyMarkBooleanAbsence__c, AttendanceDisplayFieldName__c,
                EnrolmentSOQLWhereClause__c, AttendanceSOQLWHEREClause__c,
                (SELECT ID, Editable__c, FieldName__c, HardcodedValue__c FROM RegisterFields__r)
                FROM IBRegisterSetting__mdt];
        if(settings!=null){
            return settings[0];
        }else{
            return null;
        }        
    }
    
    @AuraEnabled
    public static String getEventWrapperString(String eventId){
        return JSON.serialize(getEvent(eventId, getSettings()));        
    }

    public static sObject assginHardcodedValues(String objName, IBRegisterSetting__mdt setting, sObject rec){
        if(setting.RegisterFields__r!=null&&setting.RegisterFields__r.size()>0){
            for(IB_RegisterField__mdt field: setting.RegisterFields__r){
                if(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field.FieldName__c).getDescribe().getSOAPType()==SoapType.DATE){
                    if(field.HardcodedValue__c=='TODAY'||field.HardcodedValue__c=='Today'){
                        rec.put(field.FieldName__c,system.today());
                    }else{
                        Date dateValue = Date.valueOf(field.HardcodedValue__c.left(4)+'-'+field.HardcodedValue__c.right(4).left(2)+'-'+field.HardcodedValue__c.right(2));
                        rec.put(field.FieldName__c,dateValue);
                    }
                }else if(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field.FieldName__c).getDescribe().getSOAPType()==SoapType.DOUBLE){
                    rec.put(field.FieldName__c,decimal.valueOf(field.HardcodedValue__c));
                }else{
                    rec.put(field.FieldName__c,(String)field.HardcodedValue__c);
                }
            }
        }
        return rec;
    }
    
    public static EventWrapper getEvent(String eventId, IBRegisterSetting__mdt setting){        
        sObject event = database.query(buildEventQuery(eventId,setting));
        EventWrapper eventWrap = new EventWrapper();
        eventWrap.eventID = (String)event.get('Id');
        eventWrap.event = event;
        if(setting.EventProgrammeLookupField__c!=null){
            eventWrap.programmeId = (String)event.get(setting.EventProgrammeLookupField__c);    
        }
        if(setting.EventTitleField__c!=null){
            eventWrap.name = (String)event.get(setting.EventTitleField__c);            
        }
        if(setting.EventDateField__c!=null){
            eventWrap.eventDate = (Date)event.get(setting.EventDateField__c);            
        }
        if(setting.EventDateTimeField__c!=null){
            eventWrap.eventDateTime = (Datetime)event.get(setting.EventDateTimeField__c);            
        }
        if(setting.EventTimeField__c!=null){
            eventWrap.eventTime = (Time)event.get(setting.EventTimeField__c);            
        }
        eventWrap.notes = (String)event.get('SessionNotes__c');
        eventWrap.eventType = (String)event.get('SessionType__c');
        
        return eventWrap;
    }
    
    public static String buildEventQuery(String eventId, IBRegisterSetting__mdt setting){
        String query = 'SELECT Name, Id, SessionNotes__c, SessionType__c ';
        if(setting.EventProgrammeLookupField__c!=null){
            query = query+', '+setting.EventProgrammeLookupField__c;
        }
        if(!query.contains(setting.EventTitleField__c)){
             query = query+', '+setting.EventTitleField__c;
        }
        if(setting.EventDateField__c !=null){
            query = query+', '+setting.EventDateField__c;
        }
        if(setting.EventDateTimeField__c !=null){
            query = query+', '+setting.EventDateTimeField__c;
        }
        if(setting.EventTimeField__c !=null){
            query = query+', '+setting.EventTimeField__c;
        }
        
        query = query+' FROM '+setting.EventObject__c+' WHERE Id = \''+eventId+'\'' ;
        return query;
    }
    
    public static List<AttendanceWrapper> getAllWrappers(EventWrapper event, IBRegisterSetting__mdt setting){
        Map<String, sObject> enrols;
        if(setting.EnrolmentObject__c!=null){
            //enrols = getEnrolments(event.programmeId, setting);
        }
        List<AttendanceWrapper> wraps = getExistingAttendanceWrappers(setting, event, enrols);
        Map<String, AttendanceWrapper> wrapsMAp = new Map<String, AttendanceWrapper>();
        
        Set<String> existingAttIds = new Set<String>();
        for(AttendanceWrapper wrap: wraps){
            existingAttIds.add((String)wrap.enrolmentId);
        }
        /*if(enrols!=null){
            for(sObject rec:enrols.values()){
                if(!existingAttIds.contains(rec.Id)){
                    AttendanceWrapper wrap = new AttendanceWrapper();
                    sObject att = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).newSObject();
                    att.put(setting.AttendanceEventLookupField__c, event.eventId);
                    att.put(setting.AttendanceEnrolmentLookupField__c, rec.Id);
                    wrap.attRec = att;
                    wrap.name = (String)rec.get(setting.EnrolmentDisplayName__c );
                    wrap.enrolmentId =rec.Id;
                    wrap.statusBoolean = false;
                    wrap.absentBoolean = false;
                    wraps.add(wrap);
                }
            }
        }*/
        
        return wraps;
    }
    
    /*public static Map<String, sObject> getEnrolments(String programmeId,IBRegisterSetting__mdt setting){
        String query = 'SELECT Id, '+setting.EnrolmentProgrammeLookupField__c  +', '+setting.EnrolmentDisplayName__c+' FROM '+setting.EnrolmentObject__c+' WHERE '+setting.EnrolmentProgrammeLookupField__c +' = \''+programmeId+'\'' ;
        if(setting.EnrolmentSOQLWHEREClause__c!=null){
            query = query +' AND '+setting.EnrolmentSOQLWHEREClause__c;
        }
        
        if(setting.EnrolmentSortField__c!=null){
            query = query + ' ORDER BY '+setting.EnrolmentSortField__c;
            if(setting.EnrolmentSortOrder__c!=null){
                query = query + ' '+setting.EnrolmentSortOrder__c;
            }
        }
        //system.debug(query);
        return new Map<String, sObject>(database.query(query));
    }*/ 
    
    public static List<AttendanceWrapper> getExistingAttendanceWrappers(IBRegisterSetting__mdt setting, EventWrapper event, Map<String, sObject> enrols){
        List<AttendanceWrapper> wraps = new List<AttendanceWrapper>();
        String query = 'SELECT Id, Name, '+setting.AttendanceEventLookupField__c;
        if(setting.AttendanceDisplayFieldName__c!=null){
            query = query +', '+setting.AttendanceDisplayFieldName__c;
        }        
        if(setting.AttendanceEnrolmentLookupField__c!=null){
            query = query +', '+setting.AttendanceEnrolmentLookupField__c;
        }        
        if(setting.AttendanceBooleanField__c!=null){
            query = query +', '+setting.AttendanceBooleanField__c;
        }
        if(setting.AttendanceStatusField__c!=null){
            query = query +', '+setting.AttendanceStatusField__c;
        }
        if(setting.RegisterFields__r!=null&&setting.RegisterFields__r.size()>0){
            for(IB_RegisterField__mdt field: setting.RegisterFields__r){
                if(!query.contains(field.FieldName__c)){
                    query = query+', '+field.FieldName__c;
                }
            }
        }
        query = query +' FROM '+setting.AttendanceObject__c +' WHERE '+setting.AttendanceEventLookupField__c+' = \''+event.eventId+'\' ' ;
        if(setting.AttendanceSOQLWHEREClause__c!=null){
            query = query +' AND '+setting.AttendanceSOQLWHEREClause__c;
        }
        List<sObject> records = database.query(query);
        for(sObject rec: records){
            AttendanceWrapper wrap = new AttendanceWrapper();
            wrap.attRec = rec;
            if(enrols!=null&&enrols.get((String)rec.get(setting.AttendanceEnrolmentLookupField__c))!=null){
                wrap.name = (String)enrols.get((String)rec.get(setting.AttendanceEnrolmentLookupField__c)).get(setting.EnrolmentDisplayName__c);
            }else{
                // add attendance name function*********************************
                wrap.name = (String)rec.get(setting.AttendanceDisplayFieldName__c);
            }
            if(setting.AttendanceEnrolmentLookupField__c!=null){
                wrap.enrolmentId = (String)rec.get(setting.AttendanceEnrolmentLookupField__c);
            }
            if(setting.AttendanceStatusField__c!=null){
                wrap.status = (String)rec.get(setting.AttendanceStatusField__c);
            }
            if(setting.AttendanceBooleanField__c!=null){
                wrap.statusBoolean = (Boolean)rec.get(setting.AttendanceBooleanField__c );
                wrap.absentBoolean = !(Boolean)rec.get(setting.AttendanceBooleanField__c );
            }
            wraps.add(wrap);
        }
        return wraps;
    }    
    
    public class AttendanceWrapper{
        public sObject attRec{get; set;}
        public Contact contact{get; set;}
        public String name {get; set;}
        public boolean selected {get; set;}
        public Id enrolmentId {get; set;}
        public String status {get; set;}
        public Boolean statusBoolean {get; set;}        
        public Boolean absentBoolean {get; set;}        
    }
    
    public class EventWrapper{
        public date eventDate {get; set;}
        public datetime eventDateTime {get; set;}
        public time eventTime {get; set;}
        public String name {get; set;}
        public String eventId {get; set;}
        public String programmeId {get; set;}
        public sObject event {get; set;}
        public String notes {get; set;}  
        // Added
        public String eventType {get; set;}   
    }
}