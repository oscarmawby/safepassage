({
	doInit : function(cmp, event, helper) {
		
	},

	toggleAbsent : function(cmp, event, helper) {
		var wrap = cmp.get("v.wrapper")
		if(wrap.statusBoolean && wrap.absentBoolean){
			wrap.statusBoolean = false;
		}
		cmp.set("v.wrapper",wrap);
	},

	toggleAttended : function(cmp, event, helper) {
		var wrap = cmp.get("v.wrapper")
		if(wrap.statusBoolean && wrap.absentBoolean){
			wrap.absentBoolean = false;
		}
		cmp.set("v.wrapper",wrap);
	},
})