({
	getfields : function(cmp, event, helper) {
		var listName = cmp.get('v.listName');		
		var action = cmp.get("c.returnFields");
		action.setParams({
			listName: listName
		});         
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.fields", JSON.parse(response.getReturnValue()));
                console.log(cmp.get("v.fields") + ' Fields');
				this.getRecords(cmp, event, helper)
			}
			else {
				console.log("Failed to get fields");
			}
		});
		$A.enqueueAction(action);

	},

	getRecords : function(cmp, event, helper) {
		//console.log("getRecords")
		var recordId = cmp.get('v.recordId');
		var fields = cmp.get('v.fields');
		var listName = cmp.get('v.listName');
        
        console.log(cmp.get('v.recordId') + ' RecordId');
        console.log(listName + ' RecordId');

		var action = cmp.get("c.getRelatedRecords");
		action.setParams({
			listName: listName,
			recordId: recordId
		});         
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.allRecValues", this.createListFromApex(cmp,response.getReturnValue(),fields));
			}
			else {
				console.log("Failed to get related records");
			}
		});
		$A.enqueueAction(action);

		var action = cmp.get("c.getNonRelatedRecords");
		action.setParams({
			listName: listName,
			recordId: recordId
		});         
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.nonRelatedRecords", response.getReturnValue());
			}
			else {
				console.log("Failed to get unrelated records");
			}
		});
		$A.enqueueAction(action);

		var action = cmp.get("c.returnJunctionFields");
		action.setParams({
			listName: listName
		});         
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.junctionFields", response.getReturnValue());
			}
			else {
				console.log("Failed to get unrelated records");
			}
		});
		$A.enqueueAction(action);
	},

	addRecord : function(cmp, event, helper){
		var recordsList = cmp.get("v.recordsList");
		
	},

	getPDF : function(cmp, event, helper) {
		// See PDF value
	},

	separateRecordsFromWrapper: function(wrappers) {
		console.log("separateRecordsFromWrapper NEW")
		var records = [];
		for(var wrap of wrappers){
			var rec = wrap.opt;
			for(var field of wrap.value){
				rec[field.opt] = field.value
			}
			records.push(rec)
		}
		return records;
	},

	createListFromApex : function(cmp, recordsList,fields) {
		var allRecValues = [];
		for(var rec of recordsList){
			var recVals = [];
			for(var field of fields){
				if(field.editable){
					cmp.set("v.editable",true)
				}
				var parName='';
				if(field.type=='REFERENCE'&&rec[field.value]!=null&&rec[field.value]!=undefined){
					var fieldName = this.createFieldName(field.value);
					parName = rec[fieldName]['Name'];
				}

				recVals.push({opt: field.value, value: rec[field.value], type:field.type, editable: field.editable, parName: parName, button:field.button, pVals :field.pVals})
			}
			allRecValues.push({opt: rec, value: recVals })
		}
		return allRecValues;
	},

	createFieldName : function(field){
		var newField;
		if(field.substring(field.length-1, field.length)=='c'){
			newField = field.substring(0, field.length-1)+'r';
		}else if(field.substring(field.length-2, field.length)=='Id'){
			newField = field.substring(0, field.length-2)+'';
		}else{
			newField = field;
		}
		return newField;
	},

	fireToast : function(cmp, event, helper, message, status){
        var mode;
        var duration;
        if(status === 'success'){
            mode = 'pester';
            duration = 50;
        }else{
            mode = 'pester';
            duration = 100; 
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: mode,
            duration: duration,
            type: status,
            message: message,
            messageTemplate: message,
            messageTemplateData: ['Salesforce', {
                url: 'http://www.salesforce.com/',
                label: 'here',
            }]
        });
        toastEvent.fire(); 
    },
    
    getSortedByString : function(component, event, helper) {
        component.set('v.allRecValues', this.sortByString(component.get('v.allRecValues')));
    },
    
    getSortedByNumber : function(component, event, helper) {
        component.set('v.allRecValues', this.sortByNumber(component.get('v.allRecValues')));
    },
    
    sortByString: function(arrayOfWrapper) {
		var currentOrder = false;        
        arrayOfWrapper.sort((a, b) => (a.value > b.value) ? 1 : -1);
        return arrayOfWrapper;
    },
    
    sortByNumber: function(arrayOfWrapper) {
        var currentOrder = false;
        arrayOfWrapper.sort(function(a,b) {
            var t1 = a.value == b.value, t2 = a.value < b.value;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        return arrayOfWrapper
    },
})