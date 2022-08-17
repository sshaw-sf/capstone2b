public with sharing class JobOfferStatusManager {
    public JobOfferStatusManager() {

    }

    public static void updateRelatedJobPostingAcceptedCount(List<Job_Offer__c> updatedJobOffers,
                                                            Map<Id,Job_Offer__c> oldJobOfferValues) {
        List<Id> jobPostingIds = new List<Id>();
        for(Job_Offer__c jobOffer : updatedJobOffers) {
            if(jobOffer.Status__c == 'Accepted' 
                && oldJobOfferValues.get(jobOffer.Id).Status__c != 'Accepted') {
                    jobPostingIds.add(jobOffer.Job_Posting__c);
            }
        }

        Map<Id, Job_Posting__c> relatedJobPostings = new Map<Id, Job_Posting__c>([SELECT Id, No_Job_Offers_Accepted__c, No_Open_Positions__c, Status__c
                                                                                FROM Job_Posting__c
                                                                                WHERE Id IN :jobPostingIds AND Status__c!='Closed']);
        
        for(Job_Offer__c jobOffer : updatedJobOffers) {
            if(relatedJobPostings.containsKey(jobOffer.Job_Posting__c)) {
                if (relatedJobPostings.get(jobOffer.Job_Posting__c).No_Job_Offers_Accepted__c == null) {
                    relatedJobPostings.get(jobOffer.Job_Posting__c).No_Job_Offers_Accepted__c = 0;
                }
                relatedJobPostings.get(jobOffer.Job_Posting__c).No_Job_Offers_Accepted__c += 1; 

                if (relatedJobPostings.get(jobOffer.Job_Posting__c).No_Job_Offers_Accepted__c == relatedJobPostings.get(jobOffer.Job_Posting__c).No_Open_Positions__c) {
                    relatedJobPostings.get(jobOffer.Job_Posting__c).Status__c = 'Closed';
                }
            }
        }

        List<Job_Posting__c> updatedRelatedJobPostings = relatedJobPostings.values();


        update updatedRelatedJobPostings;
    }
}
