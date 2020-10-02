trigger AccountTrigger on Account (after insert, after update, after undelete) {
    
    String objectType = trigger.new[0].Id.getSObjectType().getDescribe().getName();
    GeolocationObjects__mdt objectSettings = GeolocationService.getObjectSettings(objectType);
		
    if(objectSettings!=null){
        if(CheckToRun.checkRun()){
            List<sObject> recordsNewAddress = new List<sObject>();        
            List<sObject> recordsNewGeo = new List<sObject>();        
            List<Id> idsNewGeo = new List<Id>();
            for(sObject rec: trigger.new){
                if(Trigger.isInsert||Trigger.isUndelete){
                    if(rec.get(objectSettings.PostcodeField__c) != null){
                        recordsNewAddress.add(rec);
                    }
                }else{
                    if(rec.get(objectSettings.PostcodeField__c) != trigger.oldmap.get(rec.Id).get(objectSettings.PostcodeField__c)){
                        System.debug('POSTCODE' + rec.get(objectSettings.PostcodeField__c));
                        recordsNewAddress.add(rec);
                    }       
                }
            }        
            
            GeolocationService run = new GeolocationService();
            if(recordsNewAddress.size()>0|| CheckToRun.checkOutboundTest()){
                System.debug('RUNNING');
                run.setGeolocationFields(recordsNewAddress);
                CheckToRun.preventRun();
            }
        }
    }
}