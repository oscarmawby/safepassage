({
        doInit: function(cmp, event, helper){
                var fieldValues = cmp.get("v.fieldValues");
                if(fieldValues.type=='TIME'&&fieldValues.value!=null){
                        var timeString = helper.createHoursString(fieldValues.value) +':'+helper.createMinsString(fieldValues.value) ;
                        cmp.set("v.fieldValues.value",timeString)
                }
        },

        
        onSingleSelectChange: function(cmp) {
                console.log("onSingleSelectChange")
                var fieldValues = cmp.get("v.fieldValues");
                var selectCmp = cmp.find("InputSelectSingle");
                fieldValues.value= selectCmp.get("v.value");
                cmp.set("v.fieldValues",fieldValues)
        },

        onMultiSelectChange: function(cmp) {
                var selectCmp = cmp.find("InputSelectMultiple");
                var fieldValues = cmp.get("v.fieldValues");
                fieldValues.value= selectCmp.get("v.value");
                cmp.set("v.fieldValues",fieldValues)
        },

})