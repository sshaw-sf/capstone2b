@isTest
private class InterviewGeneratorTest {
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

    @TestSetup
    static void createJobOfferData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Posting', 'Open');
        insert testJobPosting;

        Contact testCandidate = generateContact('Shaw');
        insert testCandidate;

        Job_Application__c testJobApp = generateJobApplication('Interview', testJobPosting.Id, testCandidate.Id);
        insert testJobApp; 

        Interview_Stage__c testStage = generateInterviewStage('Unit Test Interview Stage', testJobPosting.Id);
        insert testStage;

        Interview__c testInterview = generateInterview(testStage.Id, testCandidate.Id, testJobApp.Id);
        insert testInterview; 
    }

    @isTest
    static void insertAssignedInterviewers_givenInterviewAndPossibleInterviewers_shouldCreateAssignedInterviews() {
        List<Interview__c> interviews = [SELECT Id FROM Interview__c];
        Id interviewId = interviews[0].Id;

        List<Id> possibleInterviewerIds = new List<Id>();
        possibleInterviewerIds.add(UserInfo.getUserId());

        Test.startTest();
        InterviewGenerator.insertAssignedInterviewers(interviewId, possibleInterviewerIds);
        Test.stopTest();

        List<Assigned_Interviewer__c> testAssignedInterviewer = [SELECT Id, Interviewer__c, Interview__c FROM Assigned_Interviewer__c];
        Assigned_Interviewer__c assignedInterviewer = testAssignedInterviewer[0];

        System.assertEquals(interviewId, assignedInterviewer.Interview__c,
                            'Assigned Interviewer should be assigned to the interview that was selected');
    
        System.assertEquals(possibleInterviewerIds[0], assignedInterviewer.Interviewer__c,
                            'Assigned Interviewer should be the possible interviewer that was selected');
    }

    @isTest
    static void getInterviewerUsername_givenUserIds_shouldReturnUserFirstAndLastNames() {
        List<Id> users = new List<Id>();
        users.add(UserInfo.getUserId());

        Test.startTest();
        List<User> response = InterviewGenerator.getInterviewerUsername(users);
        Test.stopTest();

        System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), response[0].FirstName + ' ' + response[0].LastName,
                            'Name of user should be returned');
    }


}
