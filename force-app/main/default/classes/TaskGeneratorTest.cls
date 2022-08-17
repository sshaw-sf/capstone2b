@isTest
private class TaskGeneratorTest {
    
    private static Job_Posting__c generateJobPosting(String jobPostingName, String status) {
        Job_Posting__c testJobPosting = new Job_Posting__c();
        testJobPosting.Name = jobPostingName;
        testJobPosting.Status__c = status; 
        testJobPosting.Posted_by__c =  UserInfo.getUserId();
        return testJobPosting;
    }

    private static Contact generateContact(String lastName) {
        Contact testCandidate = new Contact();
        testCandidate.LastName = lastName;
        return testCandidate;
    }

    private static Job_Application__c generateJobApplication(String status, Id jobPost, Id candidate) {
        Job_Application__c testJobApplication = new Job_Application__c();
        testJobApplication.Status__c = status;
        testJobApplication.Job_Posting__c = jobPost; 
        testJobApplication.Candidate__c = candidate;
        return testJobApplication;
    }

    private static Interview_Stage__c generateInterviewStage(String name, Id jobPost) {
        Interview_Stage__c testInterviewStage = new Interview_Stage__c();
        testInterviewStage.Name = name;
        testInterviewStage.Job_Posting__c = jobPost;
        return testInterviewStage;
    }

    private static Interview__c generateInterview(Id stage, Id candidate, Id application) {
        Interview__c testInterview = new Interview__c();
        testInterview.Interview_Stage__c = stage;
        testInterview.Contact__c = candidate;
        testInterview.Job_Application__c = application;
        return testInterview;
    }

    private static Assigned_Interviewer__c generateAssignedInterview(Id interview) {
        Assigned_Interviewer__c testAssignedInterviewer = new Assigned_Interviewer__c();
        testAssignedInterviewer.Interviewer__c = UserInfo.getUserId();
        testAssignedInterviewer.Interview__c = interview;
        return testAssignedInterviewer;
    }

    private static Id getJobPostId(){
        List<Job_Posting__c> jobPosts = [SELECT Id FROM Job_Posting__c];
        return jobPosts[0].Id;
    }

    private static Id getCandidateId(){
        List<Contact> candidates = [SELECT Id FROM Contact];
        return candidates[0].Id;
    }

    @TestSetup
    static void createJobPostData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Posting', 'Open');
        insert testJobPosting;

        Contact testCandidate = generateContact('Shaw');
        insert testCandidate;

    }

    @isTest 
    static void generateJobOfferTask_givenUpdatedCandidateStatus_shouldCreateTask() {
        Id jobPostId = getJobPostId();
        Id candidateId = getCandidateId();

        Job_Application__c testJobApp = generateJobApplication('Interview', jobPostId, candidateId);
        insert testJobApp;

        Test.startTest();
        testJobApp.Status__c = 'Offered';
        update testJobApp;
        Test.stopTest();

        List<Task> generatedTasks = [SELECT Id, OwnerId, WhatId
                                    FROM Task];
        List<Job_Posting__c> jobPost = [SELECT Id, Posted_by__c
                                        FROM Job_Posting__c];

        System.assertEquals(jobPost[0].Posted_by__c, generatedTasks[0].OwnerId,
                            'The task should be assigned to the owner of the job posting');

        System.assertEquals(testJobApp.Id, generatedTasks[0].WhatId,
                            'The task should be assigned to the owner of the job posting');

    }
    
    
    @isTest 
    static void generateJobOfferTask_givenAlreadyOfferedCandidate_shouldNotCreateTask() {
        Id jobPostId = getJobPostId();
        Id candidateId = getCandidateId();

        Job_Application__c testJobApp = generateJobApplication('Offered', jobPostId, candidateId);
        insert testJobApp;

        Test.startTest();
        update testJobApp;
        Test.stopTest();

        List<Task> generatedTasks = [SELECT Id, OwnerId, WhatId
                                    FROM Task];

        System.assert(generatedTasks.isEmpty());
    }

    @isTest 
    static void generateInterviewInvite_givenNewAssignedInterviewers_shouldGenerateNewTask() {
        Id jobPostId = getJobPostId();
        Id candidateId = getCandidateId();

        Interview_Stage__c testInterviewStage = generateInterviewStage('Unit Test Interview Stage', jobPostId);
        insert testInterviewStage;

        Job_Application__c testJobApp = generateJobApplication('Interview', jobPostId, candidateId);
        insert testJobApp;

        Interview__c testInterview = generateInterview(testInterviewStage.Id, candidateId, testJobApp.Id);
        insert testInterview;

        Assigned_Interviewer__c testAssignedInterviewer = generateAssignedInterview(testInterview.Id);

        Test.startTest();
        insert testAssignedInterviewer;
        Test.stopTest();

        List<Task> generatedTasks = [SELECT Id, OwnerId, WhatId, WhoId
                                    FROM Task];

        System.assertEquals(UserInfo.getUserId(), generatedTasks[0].OwnerId, 
                            'Owner of task should be the assigned interviewer');
        
        System.assertEquals(testAssignedInterviewer.Id, generatedTasks[0].WhatId, 
                            'Task should be related to assigned interviewer record');
    }

}
