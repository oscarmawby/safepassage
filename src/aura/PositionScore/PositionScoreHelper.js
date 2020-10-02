({
	getData : function(cmp, event, helper) {        
        var recordId = cmp.get("v.recordId")
        var action = cmp.get('c.getAllPositions');
        var arrayOfWrappers = [];
        action.setParams({
			recordId: recordId
		});    
        console.log('Here');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state + ' state');
            if (state === "SUCCESS") {
                var responseCom = response.getReturnValue();
                for(var rec of responseCom){
                    arrayOfWrappers.push({
                        score: rec['score'],
                        tutor: rec['tutor'],
                        distance: rec['distance']
                    });
                }
                cmp.set('v.tutors', this.sortByScore(arrayOfWrappers))
                //cmp.set('v.tutors', this.convertMapToList(response.getReturnValue()));                
            }else{
                console.log('Failed to get tutors')
            }
        });
        $A.enqueueAction(action);
	},
    
    sortByScore: function(tutors) {
        var currentOrder = false;
        tutors.sort(function(a,b) {
            //var t1 = a.tutor.FirstName == b.tutor.FirstName, t2 = a.tutor.FirstName < b.tutor.FirstName;
            var t1 = a.score == b.score, t2 = a.score < b.score;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        return tutors
    },
    
    convertMapToList : function(tmap) {
        var li = [];
        for(var key in tmap){
            var c;
            console.log(tmap[key])
            for(var field in tmap[key]){
                console.log(field)
                c[field] = tmap[key][field];
            }
            li.push(c)
        }
        return li;
    },
    
    getSortedByScore : function(component, event, helper) {
        component.set('v.tutors', this.sortByScore(component.get('v.tutors'))); 
        component.set('v.sortedName', false); 
        component.set('v.sortedSchoolType', false);
        component.set('v.sortedArea', false);
        component.set('v.sortedDistance', false);
    },
    
    getSortedByName : function(component, event, helper) {
        component.set('v.tutors', this.sortByName(component.get('v.tutors')));
		component.set('v.sortedName', true);
        component.set('v.sortedSchoolType', false);
        component.set('v.sortedArea', false);
        component.set('v.sortedDistance', false);
    },
    
    getSortedByArea : function(component, event, helper) {
        component.set('v.tutors', this.sortByArea(component.get('v.tutors')));
		component.set('v.sortedArea', true);
        component.set('v.sortedSchoolType', false);
        component.set('v.sortedName', false);
        component.set('v.sortedDistance', false);
    },
    
    getSortedBySchoolType : function(component, event, helper) {
        component.set('v.tutors', this.sortBySchoolType(component.get('v.tutors')));
		component.set('v.sortedSchoolType', true);
        component.set('v.sortedArea', false);
        component.set('v.sortedName', false);
        component.set('v.sortedDistance', false);
    },
    
    getSortedByDistance : function(component, event, helper) {
        component.set('v.tutors', this.sortByDistance(component.get('v.tutors')));
    	component.set('v.sortedDistance', true);
        component.set('v.sortedName', false);
        component.set('v.sortedSchoolType', false);
        component.set('v.sortedArea', false);
    },
    
    sortByName: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.tutor.FirstName > b.tutor.FirstName) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortByArea: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.tutor.Area__c > b.tutor.Area__c) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortBySchoolType: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.tutor.School_Type__c > b.tutor.School_Type__c) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortByDistance: function(arrayOfWrapper) {
        arrayOfWrapper.sort(function(a,b) {
            var t1 = a.distance == b.distance, t2 = a.distance > b.distance;
            return t1? 0: (1)*(t2?1:-1);
        });
        return arrayOfWrapper
    },
})