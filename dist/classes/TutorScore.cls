public class TutorScore {
    
    @AuraEnabled
    public static List<wrapperClass> getAllObjects() {
        List<MatchingCriteria__mdt> matchingCriteria = getMetaData();
        Map<String,Boolean> positionMapFieldPresent =  fieldAlreadyQueriedPosition();
        Map<String,Boolean> tutorMapFieldPresent =  fieldAlreadyQueriedTutor();
        Map<String,String> queryForTutorAndPosition = getAllRelevantFieldsForObject(matchingCriteria,positionMapFieldPresent,tutorMapFieldPresent);
        List<wrapperClass> returnwrapperClassList = new List<wrapperClass>(); 
        User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug(user.Id);
        
        String fieldContact;
        if(queryForTutorAndPosition.get('tutor') == '') {
            fieldContact = '';
        } else {
            fieldContact = ',' + queryForTutorAndPosition.get('tutor').substring(0, queryForTutorAndPosition.get('tutor').length() - 1);
        }
        String fieldPosition;
        if(queryForTutorAndPosition.get('position') == '') {
            fieldPosition = '';
        } else {
            fieldPosition = ',' + queryForTutorAndPosition.get('position').substring(0, queryForTutorAndPosition.get('position').length() - 1);
        }
        
        String queryContact = 'SELECT Id,Name,Area__c, School_Type__c, FirstName, LastName, Geolocation__Longitude__s, Geolocation__Latitude__s ' + fieldContact + ' FROM Contact WHERE Id = \'' + user.ContactId + '\'';
        System.debug(queryContact + 'queryContact');
        Contact tutor = Database.query(queryContact);
        
        String queryPosition = 'SELECT Id,Name,Area__c,DayofWeek__c,Subject__c, AdvancedTutorPathwaySpecific__c,' +
            					'Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s, Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s,' +
                                'Cohort__r.Opportunity__r.School__c ' + fieldPosition + ' FROM Position__c';
        System.debug(queryPosition + 'queryPosition');
        List<Position__c> allPosition = Database.query(queryPosition);
        
        for(Position__c position : allPosition) {
            wrapperClass returnwrapperClass = new wrapperClass();
            Map<String,Decimal> scoreScore = calculateScoreFromMeta(position,tutor,matchingCriteria);
            if(scoreScore !=null) {
             	returnwrapperClass.score = scoreScore.get('Score');
            	returnwrapperClass.position = position;
                returnwrapperClass.distance = scoreScore.get('Distance');
            	returnwrapperClassList.add(returnwrapperClass);   
            }
        }
        return returnwrapperClassList;
    }
    
    @AuraEnabled
    public static List<wrapperClass> getAllPositions(Id recordId) {
        List<MatchingCriteria__mdt> matchingCriteria = getMetaData();
        Map<String,Boolean> positionMapFieldPresent =  fieldAlreadyQueriedPosition();
        Map<String,Boolean> tutorMapFieldPresent =  fieldAlreadyQueriedTutor();
        Map<String,String> queryForTutorAndPosition = getAllRelevantFieldsForObject(matchingCriteria,positionMapFieldPresent,tutorMapFieldPresent);
        
        String fieldContact;
        if(queryForTutorAndPosition.get('tutor') == '') {
            fieldContact = '';
        } else {
            fieldContact = ',' + queryForTutorAndPosition.get('tutor').substring(0, queryForTutorAndPosition.get('tutor').length() - 1);
        }
        String fieldPosition;
        if(queryForTutorAndPosition.get('position') == '') {
            fieldPosition = '';
        } else {
            fieldPosition = ',' + queryForTutorAndPosition.get('position').substring(0, queryForTutorAndPosition.get('position').length() - 1);
        }
        
        String queryContact = 'SELECT Id,Name,Area__c,School_Type__c,FirstName,LastName,Geolocation__Longitude__s,Geolocation__Latitude__s ' + fieldContact + ' FROM Contact';
        System.debug(queryContact + 'queryContact');
        List<Contact> tutors = Database.query(queryContact);
        
        String queryPosition = 'SELECT Id,Name,Area__c,DayofWeek__c,Subject__c, AdvancedTutorPathwaySpecific__c,' + 
            					'Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s, Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s,' +
                                'Cohort__r.Opportunity__r.School__c ' + fieldPosition + ' FROM Position__c WHERE Id = \'' + recordId + '\'';
        System.debug(queryPosition + 'queryPosition');
        Position__c position = Database.query(queryPosition);
        
        
        List<wrapperClass> returnwrapperClassList = new List<wrapperClass>();
        Map<Contact,Decimal> returnObjectMap = new Map<Contact,Decimal>();
        
        for(Contact tutor : tutors) {
            wrapperClass returnwrapperClass = new wrapperClass();
            Map<String,Decimal> scoreScore = calculateScoreFromMeta(position,tutor,matchingCriteria);
            if(scoreScore !=null) {
            	returnwrapperClass.score = scoreScore.get('Score');
            	returnwrapperClass.tutor = tutor;
                returnwrapperClass.distance = scoreScore.get('Distance');
            	returnwrapperClassList.add(returnwrapperClass);
            }
        }
        return returnwrapperClassList;
    }
    
    @AuraEnabled
    public static List<Contact> getAllRelevantContacts(List<Position__c> listRecordId) {
        List<MatchingCriteria__mdt> matchingCriteria = getMetaData();
        Map<String,Boolean> positionMapFieldPresent =  fieldAlreadyQueriedPosition();
        Map<String,Boolean> tutorMapFieldPresent =  fieldAlreadyQueriedTutor();
        Map<String,String> queryForTutorAndPosition = getAllRelevantFieldsForObject(matchingCriteria,positionMapFieldPresent,tutorMapFieldPresent);
        
        List<Id> positionIds = new List<Id>();
        for(Position__c pos : listRecordId) {
            positionIds.add(pos.Id);
        }
        
        String fieldContact;
        if(queryForTutorAndPosition.get('tutor') == '') {
            fieldContact = '';
        } else {
            fieldContact = ',' + queryForTutorAndPosition.get('tutor').substring(0, queryForTutorAndPosition.get('tutor').length() - 1);
        }
        String fieldPosition;
        if(queryForTutorAndPosition.get('position') == '') {
            fieldPosition = '';
        } else {
            fieldPosition = ',' + queryForTutorAndPosition.get('position').substring(0, queryForTutorAndPosition.get('position').length() - 1);
        }
        
        String queryContact = 'SELECT Id,WeeklyPositionSubscription__c,Name,Area__c,School_Type__c,FirstName,LastName,Geolocation__Longitude__s,Geolocation__Latitude__s ' + fieldContact + ' FROM Contact';
        System.debug(queryContact + 'queryContact');
        List<Contact> tutors = Database.query(queryContact);
        
        String queryPosition = 'SELECT Id,Name,Area__c,DayofWeek__c,Subject__c, AdvancedTutorPathwaySpecific__c,' + 
            					'Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s, Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s,' +
                                'Cohort__r.Opportunity__r.School__c ' + fieldPosition + ' FROM Position__c WHERE Id IN : positionIds';
        System.debug(queryPosition + 'queryPosition');
        List<Position__c> positions = Database.query(queryPosition);
        
        List<wrapperClass> returnwrapperClassList = new List<wrapperClass>();
        Map<Contact,Decimal> returnObjectMap = new Map<Contact,Decimal>();
        List<Contact> listOfTutors = new List<Contact>();
        
        for(Contact tutor : tutors) {
            if(tutor.WeeklyPositionSubscription__c) {
                for(Position__c pos : positions) {
                    if(calculateScoreFromMeta(pos,tutor,matchingCriteria) != null) {
                        listOfTutors.add(tutor);
                        break;
                    }
                }
            }
        }
        return listOfTutors;
    }
    
    @AuraEnabled
    public static List<MatchingCriteria__mdt> getMetaData() {
        List<MatchingCriteria__mdt> matchingCriteria = [SELECT Id, Label, DeveloperName, CriteriaOperator__c, CriteriaType__c,
                                                        Field1__c, Field2__c, Point__c, GivenValue__c, GivenValue2__c,
                                                        CriteriaLogicOperand__c
                                                  		FROM MatchingCriteria__mdt];
        return matchingCriteria;
    }
    
    @AuraEnabled
    public static Map<String,Boolean> fieldAlreadyQueriedPosition() {
        Map<String,Boolean> mapIfFieldPresentPosition = new Map<String,Boolean>();
        mapIfFieldPresentPosition.put('Name',true);
        mapIfFieldPresentPosition.put('Id',true);
        mapIfFieldPresentPosition.put('Area__c',true);
        mapIfFieldPresentPosition.put('DayofWeek__c',true);
        mapIfFieldPresentPosition.put('Subject__c',true);
        mapIfFieldPresentPosition.put('AdvancedTutorPathwaySpecific__c',true);
        mapIfFieldPresentPosition.put('Cohort__r.Opportunity__r.School__c',true);
        mapIfFieldPresentPosition.put('Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s',true);
        mapIfFieldPresentPosition.put('Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s',true);
        return mapIfFieldPresentPosition;
    }
    
    @AuraEnabled
    public static Map<String,Boolean> fieldAlreadyQueriedTutor() {
        Map<String,Boolean> mapIfFieldPresentTutor = new Map<String,Boolean>();
        mapIfFieldPresentTutor.put('Name',true);
        mapIfFieldPresentTutor.put('Id',true);
        mapIfFieldPresentTutor.put('School_Type__c',true);
        mapIfFieldPresentTutor.put('Area__c',true);
        mapIfFieldPresentTutor.put('FirstName',true);
        mapIfFieldPresentTutor.put('LastName',true);
        mapIfFieldPresentTutor.put('Geolocation__Longitude__s',true);
        mapIfFieldPresentTutor.put('Geolocation__Latitude__s',true);
        mapIfFieldPresentTutor.put('WeeklyPositionSubscription__c', true);
        return mapIfFieldPresentTutor;
    }
    
    @AuraEnabled
    public static Map<String,String> getAllRelevantFieldsForObject(List<MatchingCriteria__mdt> matchingCriteria, Map<String,Boolean> positionMapFieldPresent, Map<String,Boolean> tutorMapFieldPresent) {
       String fieldsTutor = '';
       String fieldsPosition = '';
        
        for(Integer i =0; i < matchingCriteria.size(); i++) {
            // Creating string for tutor query
            if((matchingCriteria[i].Field1__c!=null &&
                matchingCriteria[i].Field1__c!='' &&
                tutorMapFieldPresent.get(matchingCriteria[i].Field1__c)==null) || 
               (matchingCriteria[i].Field1__c!='' && 
                matchingCriteria[i].Field1__c!= null && 
                tutorMapFieldPresent.get(matchingCriteria[i].Field1__c)==null)) {
                fieldsTutor += matchingCriteria[i].Field1__c + ',';
                tutorMapFieldPresent.put(matchingCriteria[i].Field1__c,true);
            }
            // Creating string for position query 
            if((matchingCriteria[i].Field2__c!= null &&
                matchingCriteria[i].Field2__c!= '' && 
                positionMapFieldPresent.get(matchingCriteria[i].Field2__c)==null) ||
               (matchingCriteria[i].Field2__c!='' &&
                matchingCriteria[i].Field2__c!= null &&
                positionMapFieldPresent.get(matchingCriteria[i].Field2__c)==null)) {
                fieldsPosition += matchingCriteria[i].Field2__c + ',';
                   positionMapFieldPresent.put(matchingCriteria[i].Field2__c,true);
            }
        }
        Map<String,String> queriesFields = new Map<String,String>();
        queriesFields.put('tutor',fieldsTutor);
        queriesFields.put('position',fieldsPosition);
        return queriesFields;
    }
    
    @AuraEnabled
    public static Map<String,Decimal> calculateScoreFromMeta(Position__c pos, Contact tutor, List<MatchingCriteria__mdt> matchingCriteria) {
        Map<String,Decimal> scoreAndDistance = new Map<String,Decimal>();
        Decimal score = 0;
        scoreAndDistance.put('Score',score);
        scoreAndDistance.put('Distance',-1);
        
        for(MatchingCriteria__mdt criteria: matchingCriteria) {
            System.debug(criteria.Label + ' Label');
            System.debug(criteria.DeveloperName + ' DeveloperName');
            System.debug(pos.SchoolTypeMatching__c + ' pos.SchoolTypeMatching__c');
            // Implement Hard criteria
            if(criteria.CriteriaType__c == 'Hard' && criteria.DeveloperName == 'ContainsSecondary') {
                if(pos.SchoolTypeMatching__c == 'Secondary') {
                    if(!determineType(criteria,pos,tutor)) {
                        return null;
                    } 
                }
            }
            
            if(criteria.CriteriaType__c == 'Hard' && criteria.DeveloperName != 'ContainsSecondary') {
                if(!determineType(criteria,pos,tutor)) {
                      return null;
                }
            }
            // Implement Soft criteria
            if(criteria.CriteriaType__c == 'Soft') {
                if(determineType(criteria,pos,tutor)) {
                    score += criteria.Point__c;
                }
            }
            System.debug(score);
        }
        
        // Distance hard coded
        if(tutor.Geolocation__Latitude__s != null && tutor.Geolocation__Latitude__s != 0 &&
           tutor.Geolocation__Longitude__s != null && tutor.Geolocation__Longitude__s != 0 && 
           pos.Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s != null && pos.Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s  != 0 && 
           pos.Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s != null && pos.Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s != 0) {
               
               Decimal distanceBetweenContactAndSchool = calculateDistance(tutor.Geolocation__Latitude__s, tutor.Geolocation__Longitude__s, pos.Cohort__r.Opportunity__r.School__r.Geolocation__Latitude__s, pos.Cohort__r.Opportunity__r.School__r.Geolocation__Longitude__s);
               System.debug('distanceBetweenContactAndSchool' + distanceBetweenContactAndSchool);
               scoreAndDistance.put('Distance',distanceBetweenContactAndSchool);
               if(distanceBetweenContactAndSchool <= 1) {
                   System.debug('In 1');
                   score += 3;
               } else if(distanceBetweenContactAndSchool <= 2) {
                   System.debug('In 2');
                   score += 2;
               } else if(distanceBetweenContactAndSchool <= 3) {
                   System.debug('In 3');
                   score += 1;
               }
           }
        System.debug(score);
        scoreAndDistance.put('Score',score);
        System.debug(score);
        return scoreAndDistance;
    }
    
    @AuraEnabled
    public static Boolean determineType(MatchingCriteria__mdt crit,Position__c pos, Contact tutor) {
        System.debug(crit.CriteriaOperator__c );
        if(crit.CriteriaOperator__c == 'Matching value') {
            if(tutor.get(crit.Field1__c) != null && pos.get(crit.Field2__c) != null) {
                return matchinValue(String.valueOf(tutor.get(crit.Field1__c)), String.valueOf(pos.get(crit.Field2__c)));   
            }
        }
        if(crit.CriteriaOperator__c == 'Contains') {
            if(tutor.get(crit.Field1__c) != null && pos.get(crit.Field2__c) != null) {
                return contains(String.valueOf(tutor.get(crit.Field1__c)), String.valueOf(pos.get(crit.Field2__c)));  
            }
        }
        if(crit.CriteriaOperator__c == 'Field2ContainsField1') {
            if(tutor.get(crit.Field1__c) != null && pos.get(crit.Field2__c) != null) {
                return contains(String.valueOf(pos.get(crit.Field2__c)),String.valueOf(tutor.get(crit.Field1__c)));
            }
        }
        if(crit.CriteriaOperator__c == 'ContainsGivenValue') {
            if(crit.Field1__c != null &&  crit.Field1__c != '' && crit.Field2__c != null && crit.Field2__c != '') {
                if(crit.CriteriaLogicOperand__c == 'OR') {
                    if(contains(String.valueOf(tutor.get(crit.Field1__c)),crit.GivenValue__c) || contains(String.valueOf(pos.get(crit.Field2__c)),crit.GivenValue2__c)) {
                        return true;
                    }
                }
                if(crit.CriteriaLogicOperand__c == 'AND') {
                    if(tutor.get(crit.Field1__c) != null && pos.get(crit.Field2__c) != null) {
                        if(contains(String.valueOf(tutor.get(crit.Field1__c)),crit.GivenValue__c) && contains(String.valueOf(pos.get(crit.Field2__c)),crit.GivenValue2__c)) {
                            return true;
                        }  
                    }
                }
            } else {
                String relevantField, relevantGivenValue;
                if(crit.Field1__c == null || crit.Field1__c == '') {
                    relevantField = String.valueOf(pos.get(crit.Field2__c));
                    relevantGivenValue = String.valueOf(crit.GivenValue2__c);
                } else {
                    relevantField = String.valueOf(tutor.get(crit.Field1__c));
                    relevantGivenValue = String.valueOf(crit.GivenValue__c);
                }
                return contains(relevantField,relevantGivenValue);
            }
        }
        if(crit.CriteriaOperator__c == 'Is') {
            if(crit.Field1__c != null &&  crit.Field1__c != '' && crit.Field2__c != null &&  crit.Field2__c != '') {
                if(crit.CriteriaLogicOperand__c == 'OR') {
                    if(matchinValue(String.valueOf(tutor.get(crit.Field1__c)),crit.GivenValue__c) || matchinValue(String.valueOf(pos.get(crit.Field2__c)),crit.GivenValue2__c)) {
                        return true;
                    }
                }
                if(crit.CriteriaLogicOperand__c == 'AND') {
                    if(matchinValue(String.valueOf(tutor.get(crit.Field1__c)),crit.GivenValue__c) && matchinValue(String.valueOf(pos.get(crit.Field2__c)),crit.GivenValue2__c)) {
                        return true;
                    }
                }
            } else {
                String valueOne, valueTwo;
                if(crit.Field1__c == null || crit.Field1__c == '') {
                    valueOne = String.valueOf(pos.get(crit.Field2__c));
                    valueTwo = crit.GivenValue2__c;
                } else {
                    valueOne = String.valueOf(tutor.get(crit.Field1__c));
                    valueTwo = crit.GivenValue__c; 
                }
                return matchinValue(valueOne,valueTwo);
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean matchinValue(String fieldOne, String fieldTwo) {
        System.debug(fieldOne+' '+fieldTwo );
        if(fieldOne != fieldTwo) {
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static Boolean contains(String fieldOne, String fieldTwo) {
        if(!fieldOne.contains(fieldTwo)) {
            return false;
        }
        return true;
    }
    
    /*
    
        Map<String, List<Engagement__c>> tutorEngagments = getEngagements(new List<Contact>{tutor});
        Boolean schoolEng = false;
        for(Engagement__c eng: tutorEngagments.get(tutor.Id)){
            if(eng.Cohort__r.Opportunity__r.School__c==pos.Cohort__r.Opportunity__r.School__c){
                schoolEng = true;
            }
        }
        if(schoolEng){
            score += 2;
        }        
        return score;
    }*/
    
    public static Map<String, List<Engagement__c>> getEngagements(List<Contact> tutors){
        Map<String, List<Engagement__c>> engs = new Map<String, List<Engagement__c>>();
        for(Engagement__c engagement: [SELECT ID, Tutor__c, Cohort__r.StartDate__c, Cohort__r.EndDate__c, 
                                Cohort__r.Opportunity__r.School__c 
                                FROM Engagement__c WHERE Tutor__c in: tutors]){
            List<Engagement__c> engagementList;
            if(engs.get(engagement.Tutor__c)!=null){
                engagementList = engs.get(engagement.Tutor__c);
            }else{
                engagementList = new List<Engagement__c>();
            }
            engagementList.add(engagement);
            engs.put(engagement.Tutor__c, engagementList);
        }
        return engs;
    }
    
    public static Decimal calculateDistance(Decimal lat1, Decimal long1, Decimal lat2, Decimal long2) {
		Decimal theta = long1 - long2;
        Decimal distance = Math.sin(lat1 *(Math.PI/180)) * Math.sin(lat2*(Math.PI/180)) + Math.cos(lat1*(Math.PI/180)) * Math.cos(lat2*(Math.PI/180)) * Math.cos(theta*(Math.PI/180));
        distance = Math.acos(distance);
        distance = distance / (Math.PI/180);
        Decimal miles = distance * 60 * 1.1515;
        return miles.setScale(2, RoundingMode.CEILING);
    }
    
    
    public class wrapperClass {
        @AuraEnabled public Decimal score {get;set;}
        @AuraEnabled public Decimal distance {get;set;}
        @AuraEnabled public Position__c position {get;set;}
        @AuraEnabled public Contact tutor {get;set;}
    }
       

}