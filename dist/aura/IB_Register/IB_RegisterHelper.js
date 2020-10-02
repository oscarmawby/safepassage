({
    getAttRecords : function(cmp, event, helper){
        var recordId = cmp.get('v.recordId');
        if(recordId!=null){
            var action = cmp.get("c.getAttendees");
            action.setParams({eventId: recordId});         
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.wrappers", JSON.parse(response.getReturnValue()));
                    cmp.set("v.loading",false)

                }
                else {
                    console.log("Failed to get attendees");
                    cmp.set("v.loading",false)
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getStatusOptions : function(cmp, event, helper){
        console.log("getStatusOptions")
        var action = cmp.get("c.getStatusOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var setOptions = [];
                var options = response.getReturnValue();
                for(var opt in options){
                    setOptions.push({value:options[opt], opt:opt})
                }
                cmp.set("v.statusOptions", setOptions);
                helper.getAttRecords(cmp, event, helper)
            }
            else {
                console.log("Failed to get optionss");
            }
        });
        $A.enqueueAction(action);
    },
    
    getPicklistValues : function(cmp, event, helper){
        console.log("getPicklistvalues")
        var action = cmp.get("c.getPicklistvalues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                cmp.set("v.typePicklist", options);
            }
            else {
                console.log("Failed to get optionss");
            }
        });
        $A.enqueueAction(action);
    },
    
    getRegisterOptions : function(cmp, event, helper){
        var recordID = cmp.get('v.recordId');
        if(recordID!=null){
            var action = cmp.get("c.getSettings");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.registerOptions", response.getReturnValue());
                }
                else {
                    console.log("Failed to get register options");
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    getEventDetails : function(cmp, event, helper){
        var recordID = cmp.get('v.recordId');
        if(recordID!=null){
            var action = cmp.get("c.getEventWrapperString");
            action.setParams({eventId: recordID});         
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.event", JSON.parse(response.getReturnValue()));
                }
                else {
                    console.log("Failed to get event");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    helperSave: function(cmp, event, helper){
        cmp.set("v.loading",true)
        var event = cmp.get('v.event')
        var wrappers = JSON.stringify(cmp.get('v.wrappers'));
        var event = JSON.stringify(cmp.get('v.event'));
        console.log(event + " event");
        if(wrappers!=null){ 
            var action = cmp.get("c.saveRecords");
            action.setParams({
                wrappersString: wrappers,
                eventString: event
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.wrappers", JSON.parse(response.getReturnValue()));
                    helper.fireToast(cmp, event, helper, "Records Saved!", "success")
                    cmp.set("v.loading",false)
                }
                else {
                    console.log("Failed to Save attendees");
                    helper.fireToast(cmp, event, helper, "Error in Save - please contact your system administrator", "error")
                    cmp.set("v.loading",false)
                }
            });
            $A.enqueueAction(action);
        }
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
})