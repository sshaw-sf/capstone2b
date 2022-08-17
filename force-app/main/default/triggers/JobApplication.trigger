trigger JobApplication on Job_Application__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        TaskGenerator.generateJobOfferTask(Trigger.new, Trigger.oldMap);
    }

}