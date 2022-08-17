@isTest
private class JobOfferStatusManagerTest {
    private static Job_Posting__c generateJobPosting(String jobPostingName, String status, Integer numOpenPositions) {
        Job_Posting__c testJobPosting = new Job_Posting__c();
        testJobPosting.Name = jobPostingName;
        testJobPosting.Status__c = status; 
        testJobPosting.No_Open_Positions__c = numOpenPositions;
        return testJobPosting;
    }

    private static Contact generateCandidate(String lastName) {
        Contact testCandidate = new Contact();
        testCandidate.LastName = lastName;
        return testCandidate;
    }

    private static Job_Offer__c generateJobOffer(Id jobPostingId, Id candidateId, String status) {
        Job_Offer__c testJobOffer = new Job_Offer__c();
        testJobOffer.Job_Posting__c = jobPostingId;
        testJobOffer.Candidate__c = candidateId;
        testJobOffer.Status__c = status;
        return testJobOffer;
    }

    @TestSetup
    static void createJobOfferData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Posting', 'Open', 2);
        insert testJobPosting; 

        Contact testCandidate = generateCandidate('Shaw');
        insert testCandidate;

        Job_Offer__c testJobOffer = generateJobOffer(testJobPosting.Id, testCandidate.Id, 'Sent');
        insert testJobOffer;
    }

    @isTest
    static void updateRelatedJobPostingAcceptedCount_givenAcceptedJobOffer_shouldIncrementAcceptedCount() {
        List<Job_Offer__c> testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];

        Test.startTest();

        Job_Offer__c jobOffer = testJobOffers[0];
        jobOffer.Status__c = 'Accepted';
        update jobOffer;

        Test.stopTest();

        List<Job_Posting__c> testJobPostings = [SELECT Id, No_Job_Offers_Accepted__c, Status__c FROM Job_Posting__c];
        Job_Posting__c jobPosting = testJobPostings[0];

        testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];
        jobOffer = testJobOffers[0];

        System.assertEquals('Accepted', jobOffer.Status__c,
                            'Job Offer status should be accepted');

        System.assertEquals(1, jobPosting.No_Job_Offers_Accepted__c,
                            'No. of Job Offers Accepted should be incremented');

        System.assertEquals('Open', jobPosting.Status__c,
                            'Job Posting status should not change');

    }

    @isTest
    static void updateRelatedJobPostingAcceptedCount_givenAcceptedJobOfferReachesLimit_shouldCloseJobPosting(){
        List<Job_Posting__c> testJobPostings = [SELECT Id, Status__c, No_Open_Positions__c FROM Job_Posting__c];
        Job_Posting__c jobPosting = testJobPostings[0];
        jobPosting.No_Open_Positions__c = 1; 
        update jobPosting;

        List<Job_Offer__c> testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];

        Test.startTest();

        Job_Offer__c jobOffer = testJobOffers[0];
        jobOffer.Status__c = 'Accepted';
        update jobOffer;

        Test.stopTest();

        testJobPostings = [SELECT Id, No_Job_Offers_Accepted__c, Status__c FROM Job_Posting__c];
        jobPosting = testJobPostings[0];

        testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];
        jobOffer = testJobOffers[0];

        System.assertEquals(1, jobPosting.No_Job_Offers_Accepted__c,
                            'No. of Job Offers Accepted should be incremented');

        System.assertEquals('Closed', jobPosting.Status__c,
                            'Job Posting status should change when no. of job offers accepted equals no. of open positions');

    }

    @isTest
    static void updateRelatedJobPostingAcceptedCount_givenClosedJobPosting_shouldNotIncrementCount(){
        List<Job_Posting__c> testJobPostings = [SELECT Id, Status__c FROM Job_Posting__c];
        Job_Posting__c jobPosting = testJobPostings[0];
        jobPosting.Status__c = 'Closed';
        update jobPosting;

        List<Job_Offer__c> testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];

        Test.startTest();

        Job_Offer__c jobOffer = testJobOffers[0];
        jobOffer.Status__c = 'Accepted';
        update jobOffer;

        Test.stopTest();

        testJobPostings = [SELECT Id, No_Job_Offers_Accepted__c FROM Job_Posting__c];
        jobPosting = testJobPostings[0];

        System.assertEquals(0, jobPosting.No_Job_Offers_Accepted__c,
                            'No. of Job Offers Accepted should not be incremented');
    }

    @isTest
    static void updateRelatedJobPostingAcceptedCount_givenAlreadyAccepted_shouldNotIncrementCount(){
        List<Job_Offer__c> testJobOffers = [SELECT Id, Job_Posting__c, Status__c FROM Job_Offer__c];
        Job_Offer__c jobOffer = testJobOffers[0];
        jobOffer.Status__c = 'Accepted';
        update jobOffer;

        Test.startTest();
        
        update jobOffer;

        Test.stopTest();

        List<Job_Posting__c> testJobPostings = [SELECT Id, No_Job_Offers_Accepted__c FROM Job_Posting__c];
        Job_Posting__c jobPosting = testJobPostings[0];

        System.assertEquals(1, jobPosting.No_Job_Offers_Accepted__c,
                            'No. of Job Offers Accepted should not be incremented');
    }
}
