trigger JobOffer on Job_Offer__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        JobOfferStatusManager.updateRelatedJobPostingAcceptedCount(Trigger.new, Trigger.oldMap);
    }
}