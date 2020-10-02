({
    getDetails : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.position.Id"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})