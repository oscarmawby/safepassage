public class IB_EditableRelatedListServerController {
    
    @AuraEnabled
    Public static List<sObject> getRelatedRecords(String listName, String recordId){
        IB_EditableListSetting__mdt setting;
        setting = findSetting(listName);
        String matchId = getMatchingId(setting,recordId);

        String query = 'SELECT '+setting.LookupFieldName__c;

        if(setting.JunctionObjectFieldName__c!=null){
            query = query +', '+setting.JunctionObjectFieldName__c ;
        }

        for(FieldWrap field: getFields(setting,true,null)){           
            if(!query.contains(field.value)){
                query = query + ', '+field.value;
                if(field.type==Schema.DisplayType.REFERENCE){
                    query = query + ', '+getParentNameString(field);
                }
            }            
        }
        query = query +' FROM '+setting.ChildObjectName__c+' WHERE '+setting.LookupFieldName__c+' = \''+matchId+'\'';
        if(setting.ChildSOQLClause__c!=null) {
            query = query + ' AND ' + setting.ChildSOQLClause__c; 
         }
        List<sObject> records = database.query(query);        
        return records;
    }

    public static String getParentNameString(FieldWrap field){
        String fieldString;
        if(field.value.right(1)=='c'){
            fieldString = field.value.left(field.value.length()-1)+'r.Name';
        }else if(field.value.right(2)=='Id'){
            fieldString = field.value.left(field.value.length()-2)+'.Name';
        }else{
            fieldString = field.value+'.Name';
        }
        return fieldString;

    }

    @AuraEnabled
    Public static List<sObject> getNonRelatedRecords(String listName, String recordId){
        IB_EditableListSetting__mdt setting = findSetting(listName);
        if(setting.JunctionObjectName__c==null){
            return null;
        }else{
            Set<String> currentIds = new Set<String>();
            for(sObject rec: getRelatedRecords(listName, recordId)){
                currentIds.add((String)rec.get(setting.JunctionObjectFieldName__c ));
            }
            
            String query = 'SELECT Id '+setting.JunctionObjectRecordTitle__c+' FROM '+setting.JunctionObjectName__c+' WHERE Id NOT in: currentIds AND '+setting.JunctionObjectWhere__c;
            return database.query(query);
        }
    }

    @AuraEnabled
    Public static String returnFields(String listName){
        system.debug(getFields(findSetting(listName),true,null));
        return JSON.serialize(getFields(findSetting(listName),true,null));
    }

    @AuraEnabled
    Public static String returnJunctionFields(String listName){
        return JSON.serialize(getFields(findSetting(listName),false,null));
    }

    @AuraEnabled
    Public static List<sObject> save(list<sObject> records){
        update records;
        return records;
    }

    public static String getMatchingId(IB_EditableListSetting__mdt setting, Id recordId){
        String matchId ;
        if(recordId!=null&&setting.ParentMatchingFieldName__c!=null){
            String originQuery = 'SELECT '+setting.ParentMatchingFieldName__c+' FROM '+recordId.getSObjectType().getDescribe().getName()+' WHERE Id =: recordId';
            sObject rec = database.query(originQuery);
            matchId = (String)rec.get(setting.ParentMatchingFieldName__c);
        }

        if(matchId == null){
            User u = [SELECT ContactId FROM User WHERE Id = : UserInfo.getUserId()];
            if(u.ContactId==null){
                matchId = u.Id;
            }else{
                matchId = u.ContactId;
            }  
        }
        return matchId;
    }

    Public static IB_EditableListSetting__mdt findSetting(String listName ){
        if(listName==null){
            return getSettings().values()[0];
        }else{
            return getSettings().get(listName);
        }
    }
    
    Public static Map<String,IB_EditableListSetting__mdt> getSettings(){
        Map<String,IB_EditableListSetting__mdt> settings = new Map<String,IB_EditableListSetting__mdt>();
        for(IB_EditableListSetting__mdt setting: [SELECT DeveloperName, MatchingFieldName__c,  ParentSOQLClause__c, ChildSOQLClause__c, ChildObjectName__c, LookupFieldName__c, 
                                    ParentObjectName__c, JunctionObjectFieldName__c, JunctionObjectName__c, JunctionObjectWhere__c, JunctionObjectRecordTitle__c, ParentMatchingFieldName__c
                                    //(SELECT DeveloperName, Label, Editable__c, FieldName__c, ChildRecord__c, OrderNumber__c FROM IB_EditableListFields__r ORDER BY OrderNumber__c ASC)
                                    FROM IB_EditableListSetting__mdt]){
            settings.put(setting.DeveloperName,setting);
        }
        return settings;
    }

    public static Map<String, List<IB_EditableListField__mdt>> getSettingFields(){
        Map<String, List<IB_EditableListField__mdt>> fields = new Map<String, List<IB_EditableListField__mdt>>();
        for(IB_EditableListField__mdt field : [SELECT DeveloperName, Label, Editable__c, FieldName__c, ChildRecord__c, OrderNumber__c, IB_EditableListSetting__c, Button__c FROM IB_EditableListField__mdt ORDER BY OrderNumber__c ASC]){
            List<IB_EditableListField__mdt> settingFields = fields.get(field.IB_EditableListSetting__c);
            if(settingFields==null){
                settingFields = new List<IB_EditableListField__mdt>();
            }
            settingFields.add(field);
            fields.put(field.IB_EditableListSetting__c,settingFields);
        }
        return fields;
    }
    
    public static List<FieldWrap> getFields(IB_EditableListSetting__mdt setting, Boolean childRecord, Map <String, Schema.SObjectField> fieldMap) {
        Map<String, List<IB_EditableListField__mdt>> fields = getSettingFields();
        if(fieldMap==null){
            fieldMap = Schema.getGlobalDescribe().get(setting.ChildObjectName__c).getDescribe().fields.getMap();  
        }

        List<FieldWrap> allFields = new List<FieldWrap>();
        for(IB_EditableListField__mdt f: fields.get(setting.Id)){
            Schema.SObjectField sField = fieldMap.get(f.FieldName__c);
            if(f.ChildRecord__c == childRecord){
                allFields.add(constructWrapper(sField, f));
            }            
        }
        return allFields;
    }

    public static FieldWrap constructWrapper(Schema.SObjectField f, IB_EditableListField__mdt field){
        FieldWrap wrap = new FieldWrap();
        wrap.label = f.getDescribe().getLabel();
        wrap.value = f.getDescribe().getName();
        wrap.type = f.getDescribe().getType();
        wrap.editable = field.Editable__c;
        wrap.button = field.Button__c;
        if(wrap.type==Schema.DisplayType.PICKLIST||wrap.type==Schema.DisplayType.MULTIPICKLIST){
            List<PVal> pValues = new List<PVal>();
            for(Schema.PicklistEntry plOption: f.getDescribe().getPicklistValues()){
                PVal val = new PVal();
                val.value = plOption.getValue();
                val.label = plOption.getLabel();
                pValues.add(val);
            }
            wrap.pVals = pValues;
        }
        return wrap;
    }

    public class FieldWrap{
        public String label;
        public String parentName;
        public String value;
        public Schema.DisplayType type;
        public Boolean editable;
        public Boolean button;
        public List<PVal> pVals;
    }

    public class PVal{
        public String label;
        public String value;
        public String selected;
    }
}