({
	doInit : function(cmp, event, helper) {
		helper.getfields(cmp,event,helper)
	},

    viewDetails : function(cmp, event, helper) {
        var recordId = event.currentTarget.id;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/invoice/' + recordId
        });
        urlEvent.fire();
    },
    
    sortAccordingToString : function(cmp, event, helper) {
        helper.getSortedByString(cmp, event, helper);
    },
    
    sortAccordingToNumber : function(cmp, event, helper) {
        helper.getSortedByNumber(cmp, event, helper);
    },

})