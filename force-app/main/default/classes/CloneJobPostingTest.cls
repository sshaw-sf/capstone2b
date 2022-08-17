@isTest
private class CloneJobPostingTest {
    private static Job_Posting__c generateJobPosting(String jobPostingName, Integer num, String status) {
        Job_Posting__c testJobPosting = new Job_Posting__c();
        testJobPosting.Name = jobPostingName;
        testJobPosting.No_Open_Positions__c = num;
        testJobPosting.Status__c = status;
        return testJobPosting;
    }

    private static Interview_Stage__c generateInterviewStage(String interviewStageName, Id jobPostingId, Integer num) {
        Interview_Stage__c testInterviewStage = new Interview_Stage__c();
        testInterviewStage.Name = interviewStageName;
        testInterviewStage.Job_Posting__c = jobPostingId;
        testInterviewStage.Number_Of_Interviewers__c = num;
        return testInterviewStage;
    }

    private static Question__c generateQuestion(String questionName) {
        Question__c testQuestion = new Question__c();
        testQuestion.Name = questionName;
        return testQuestion;
    }

    private static Interview_Questions__c generateInterviewQuestion(Id interviewStageId, Id questionId) {
        Interview_Questions__c testInterviewQuestion= new Interview_Questions__c();
        testInterviewQuestion.Interview_Stage__c = interviewStageId;
        testInterviewQuestion.Question__c = questionId;
        return testInterviewQuestion;
    }

    private static Possible_Interviewer__c generatePossibleInterviewers(Id interviewStageId) {
        Possible_Interviewer__c testPossibleInterviewer = new Possible_Interviewer__c();
        testPossibleInterviewer.Interview_Stage__c = interviewStageId;
        testPossibleInterviewer.Interviewer__c = UserInfo.getUserId();
        return testPossibleInterviewer;
    }

    @TestSetup
    static void createTimesheetData(){
        Job_Posting__c testJobPosting = generateJobPosting('Unit Test Job Post', 3, 'Open');
        insert testJobPosting; 

        Interview_Stage__c testInterviewStage = generateInterviewStage('Interview Stage 1', testJobPosting.Id, 2);
        insert testInterviewStage;

        Question__c testQuestion = generateQuestion('Question 1');
        insert testQuestion;

        Interview_Questions__c testInterviewQuestion = generateInterviewQuestion(testInterviewStage.Id, testQuestion.Id);
        insert testInterviewQuestion;

        Possible_Interviewer__c testPossibleInterviewer = generatePossibleInterviewers(testInterviewStage.Id);
        insert testPossibleInterviewer;
    }

    @isTest 
    static void deepCloneJobPosting_givenJobPosting_shouldDeepClone() {
        List<Job_Posting__c> orginialJobPostings = [SELECT Id, No_Open_Positions__c
                                                    FROM Job_Posting__c];

        Test.startTest();
        CloneJobPosting.deepCloneJobPostings(orginialJobPostings);
        Test.stopTest();

        List<Job_Posting__c> jobPostings = [SELECT Id, No_Open_Positions__c, Status__c, Name
                                            FROM Job_Posting__c];

        System.assertEquals(jobPostings[0].No_Open_Positions__c, jobPostings[1].No_Open_Positions__c,
                            'Cloned job post should contain same info. as original job posting');

        System.assertEquals('Draft', jobPostings[1].Status__c, 
                            'Cloned job post status should be draft');

        System.assertEquals(jobPostings[0].Name + ' Clone', jobPostings[1].Name, 
                            'Cloned job post name should have clone appended');
        
        List<Interview_Stage__c> interviewStages = [SELECT Id, Name, Job_Posting__c
                                                    FROM Interview_Stage__c];

        System.assertEquals(interviewStages[0].Name, interviewStages[1].Name, 
                            'Interview stages should be cloned');

        System.assertNotEquals(interviewStages[0].Job_Posting__c, interviewStages[1].Job_Posting__c,
                                'Cloned interview stage should belong to cloned job post');

        List<Interview_Questions__c> interviewQuestions = [SELECT Id, Interview_Stage__c, Question__c
                                                            FROM Interview_Questions__c];

        System.assertEquals(interviewQuestions[0].Question__c, interviewQuestions[1].Question__c,
                            'Questions should be cloned');  
        System.assertNotEquals(interviewQuestions[0].Interview_Stage__c, interviewQuestions[1].Interview_Stage__c,
                            'Cloned questions should belong to cloned interview stage');

        List<Possible_Interviewer__c> possibleInterviewers = [SELECT Id, Interview_Stage__c, Interviewer__c
                                                            FROM Possible_Interviewer__c];

        System.assertEquals(possibleInterviewers[0].Interviewer__c, possibleInterviewers[1].Interviewer__c,
                            'Possible interviewers should be cloned');  
        System.assertNotEquals(possibleInterviewers[0].Interview_Stage__c, possibleInterviewers[1].Interview_Stage__c,
                            'Cloned possible interviewers should belong to cloned interview');
    }

}
