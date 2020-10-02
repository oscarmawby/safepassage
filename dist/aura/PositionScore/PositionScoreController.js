({
    doInit : function(cmp, event, helper) {
        helper.getData(cmp, event, helper);
    },
    
    sortAccordingToScore : function(cmp, event, helper) {
        helper.getSortedByScore(cmp, event, helper);
    },
    
    sortAccordingToName : function(cmp, event, helper) {
        helper.getSortedByName(cmp, event, helper);
    },
    
    sortAccordingToArea : function(cmp, event, helper) {
        helper.getSortedByArea(cmp, event, helper);
    },
    
    sortAccordingToSchoolType : function(cmp, event, helper) {
        helper.getSortedBySchoolType(cmp, event, helper);
    },
    
    sortAccordingToDistance : function(cmp, event, helper) {
        helper.getSortedByDistance(cmp, event, helper);
    },
})