({
    
    doInit : function(cmp, event, helper) {
        helper.getMapData(cmp, event, helper);
    },
    
    sortAccordingToDistance : function(cmp, event, helper) {
        helper.getSortedByDistance(cmp, event, helper);
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
    
    sortAccordingToDay : function(cmp, event, helper) {
        helper.getSortedByDay(cmp, event, helper);
    },
    
})