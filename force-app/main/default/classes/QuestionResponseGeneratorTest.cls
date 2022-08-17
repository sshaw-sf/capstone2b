@isTest
private class QuestionResponseGeneratorTest {
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

    private static Question__c generateQuestion(String name) {
        Question__c testQuestion = new Question__c();
        testQuestion.Name = name;
        return testQuestion;
    }

    private static Interview_Questions__c generateInterviewQuestion(Id stageId, Id questionId) {
        Interview_Questions__c testInterviewQuestion = new Interview_Questions__c();
        testInterviewQuestion.Interview_Stage__c = stageId;
        testInterviewQuestion.Question__c = questionId;
        return testInterviewQuestion;
    }

    @TestSetup
    static void createJobPostData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Posting', 'Open');
        insert testJobPosting;

        Contact testCandidate = generateContact('Shaw');
        insert testCandidate;

        Job_Application__c testJobApp = generateJobApplication('Interview', testJobPosting.Id, testCandidate.Id);
        insert testJobApp; 

        Interview_Stage__c testStage = generateInterviewStage('Unit Test Interview Stage', testJobPosting.Id);
        insert testStage;

        Question__c testQuestion = generateQuestion('Unit Test Question');
        insert testQuestion;

        Interview_Questions__c testInterviewQuestion = generateInterviewQuestion(testStage.Id, testQuestion.Id);
        insert testInterviewQuestion;

        Interview__c testInterview = generateInterview(testStage.Id, testCandidate.Id, testJobApp.Id);
        insert testInterview; 
    }

    @isTest 
    static void generateQuestionResponses_givenAssignedInterview_shouldCreateQuestionResponses() {
        List<Interview__c> interviews = [SELECT Id FROM Interview__c];

        Test.startTest();
        Assigned_Interviewer__c testAssignedInterviewer = generateAssignedInterview(interviews[0].Id);
        insert testAssignedInterviewer;

        Test.stopTest();

        List<Question_Response__c> questionResponses = [SELECT Id, Interview_Question__c, Assigned_Interviewer__c FROM Question_Response__c];
        List<Interview_Questions__c> interviewQuestions = [SELECT Id FROM Interview_Questions__c];
        List<Assigned_Interviewer__c> assignedInterviewers = [SELECT Id FROM Assigned_Interviewer__c];

        System.assertEquals(questionResponses[0].Interview_Question__c, interviewQuestions[0].Id);
        System.assertEquals(questionResponses[0].Assigned_Interviewer__c, assignedInterviewers[0].Id);

    }

}
