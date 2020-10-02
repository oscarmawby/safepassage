({
	getMapData : function(component, event, helper) {
        var arrayOfWrappers = [];
        var action = component.get('c.getAllObjects');
        console.log('inside'); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state '+state); 
            if (state === "SUCCESS") { 
                console.log('SUCCESS'); 
                var StoreResponse = response.getReturnValue();
                console.log('StoreResponse' + StoreResponse);
                for(var rec of StoreResponse){
                    arrayOfWrappers.push({
                        score: rec['score'],
                        position: rec['position'],
                        distance: rec['distance']
                    });
                }
                component.set('v.positionObjectList', this.sortByScore(arrayOfWrappers));
            }
        }); 
        console.log('SUCCESS' + arrayOfWrappers);
        $A.enqueueAction(action);
    },
    
    getSortedByDistance : function(component, event, helper) {
        component.set('v.positionObjectList', this.sortByDistance(component.get('v.positionObjectList')));
    	component.set('v.sortedDistance', true);
        component.set('v.sortedName', false);
        component.set('v.sortedDay', false);
        component.set('v.sortedArea', false);
    },
    
    getSortedByScore : function(component, event, helper) {
        component.set('v.positionObjectList', this.sortByScore(component.get('v.positionObjectList')));
		component.set('v.sortedDistance', false);   
        component.set('v.sortedName', false); 
        component.set('v.sortedDay', false);
        component.set('v.sortedArea', false);
    },
    
    getSortedByName : function(component, event, helper) {
        component.set('v.positionObjectList', this.sortByName(component.get('v.positionObjectList')));
		component.set('v.sortedName', true);
        component.set('v.sortedDistance', false);
        component.set('v.sortedDay', false);
        component.set('v.sortedArea', false);
    },
    
    getSortedByArea : function(component, event, helper) {
        component.set('v.positionObjectList', this.sortByArea(component.get('v.positionObjectList')));
		component.set('v.sortedArea', true);
        component.set('v.sortedDistance', false);
        component.set('v.sortedDay', false);
        component.set('v.sortedName', false);
    },
    
    getSortedByDay : function(component, event, helper) {
        component.set('v.positionObjectList', this.sortByDay(component.get('v.positionObjectList')));
		component.set('v.sortedDay', true);
        component.set('v.sortedDistance', false);
        component.set('v.sortedArea', false);
        component.set('v.sortedDistance', false);
    },
    
    sortByScore: function(arrayOfWrapper) {
        arrayOfWrapper.sort(function(a,b) {
            var t1 = a.score == b.score, t2 = a.score < b.score;
            return t1? 0: (1)*(t2?1:-1);
        });
        return arrayOfWrapper
    },
    
    sortByDistance: function(arrayOfWrapper) {
        arrayOfWrapper.sort(function(a,b) {
            var t1 = a.distance == b.distance, t2 = a.distance > b.distance;
            return t1? 0: (1)*(t2?1:-1);
        });
        return arrayOfWrapper
    },
    
    sortByName: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.position.Name > b.position.Name) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortByArea: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.position.Area__c > b.position.Area__c) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortByDay: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.position.DayofWeek__c > b.position.DayofWeek__c) ? 1 : -1);
        return arrayOfWrapper;
    },
})