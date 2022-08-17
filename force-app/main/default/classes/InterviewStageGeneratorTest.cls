@isTest
private class InterviewStageGeneratorTest {
    private static Job_Posting__c generateJobPosting(String jobPostingName, String status) {
        Job_Posting__c testJobPosting = new Job_Posting__c();
        testJobPosting.Name = jobPostingName;
        testJobPosting.Status__c = status; 
        testJobPosting.Posted_by__c =  UserInfo.getUserId();
        return testJobPosting;
    }
    
    private static Interview_Stage__c generateInterviewStage(String name, Id jobPost) {
        Interview_Stage__c testInterviewStage = new Interview_Stage__c();
        testInterviewStage.Name = name;
        testInterviewStage.Job_Posting__c = jobPost;
        return testInterviewStage;
    }

    private static Possible_Interviewer__c generatePossibleInterviewer(Id stage) {
        Possible_Interviewer__c testPossibleInterviewer = new Possible_Interviewer__c();
        testPossibleInterviewer.Interviewer__c = UserInfo.getUserId();
        testPossibleInterviewer.Interview_Stage__c = stage;
        return testPossibleInterviewer;
    }

    private static Question__c generateQuestion(String name) {
        Question__c testQuestion = new Question__c();
        testQuestion.Name = name;
        return testQuestion;
    }

    @TestSetup
    static void createJobOfferData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Posting', 'Open');
        insert testJobPosting;

        Interview_Stage__c testStage = generateInterviewStage('Unit Test Interview Stage', testJobPosting.Id);
        insert testStage;

        Question__c testQuestion = generateQuestion('Unit Test Question');
        insert testQuestion;
    }

    @isTest
    static void insertPossibleInterviewers_givenStageAndUsers_shouldCreatePossibleInterviewers() {
        List<Interview_Stage__c> interviewStages = [SELECT Id FROM Interview_Stage__c];
        Id interviewStageId = interviewStages[0].Id;

        List<Id> possibleInterviewerIds = new List<Id>();
        possibleInterviewerIds.add(UserInfo.getUserId());

        Test.startTest();
        InterviewStageGenerator.insertPossibleInterviewers(interviewStageId, possibleInterviewerIds);
        Test.stopTest();

        List<Possible_Interviewer__c> testPossibleInterviewer = [SELECT Id, Interviewer__c, Interview_Stage__c FROM Possible_Interviewer__c];
        Possible_Interviewer__c possibleInterviewer = testPossibleInterviewer[0];

        System.assertEquals(interviewStageId, possibleInterviewer.Interview_Stage__c,
                            'Possible Interviewer should be assigned to the interview stage selected');
    
        System.assertEquals(UserInfo.getUserId(), possibleInterviewer.Interviewer__c,
                            'Possible Interviewer should be the user that was selected');
    }

    @isTest 
    static void insertInterviewQuestions_givenStageAndQuestions_shouldCreateInterviewQuestions(){
        List<Interview_Stage__c> interviewStages = [SELECT Id FROM Interview_Stage__c];
        Id interviewStageId = interviewStages[0].Id;

        List<Question__c> questions = [SELECT Id FROM Question__c];
        List<Id> questionIds = new List<Id>();
        questionIds.add(questions[0].Id);

        Test.startTest();
        InterviewStageGenerator.insertInterviewQuestions(interviewStageId, questionIds);
        Test.stopTest();

        List<Interview_Questions__c> testInterviewQuestion = [SELECT Id, Question__c, Interview_Stage__c FROM Interview_Questions__c];
        Interview_Questions__c interviewQuestion  = testInterviewQuestion[0];

        System.assertEquals(interviewStageId, interviewQuestion.Interview_Stage__c,
                            'Interview Question should belong to the interview stage selected');

        System.assertEquals(questions[0].Id, interviewQuestion.Question__c,
                            'Interview Question should contain the question that was selected');
    }

}
