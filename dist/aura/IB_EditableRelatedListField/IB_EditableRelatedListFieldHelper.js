({

	createHoursString: function(time){
		var time = time/3600000;
		var hourString =  parseInt(time,10).toString()
		if(hourString.length===1){
				hourString = '0'+hourString;
		}
		return hourString
},


	createMinsString: function(time){
		var time = time/3600000
		var mins = (time - parseInt(time,10))*60;
		console.log(mins)
		var minsString = Math.round(mins).toString();
		console.log(minsString)
		if(minsString.length===1){
				minsString = '0'+minsString;
		}
		console.log(minsString)
		return minsString;

	},
})