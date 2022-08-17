public with sharing class InterviewStageGenerator {
    @AuraEnabled
    public static List<Profile> getInterviewers(){
        try {
            return [SELECT Id, (SELECT Id, FirstName, LastName FROM Users)
                                FROM Profile
                                WHERE Name = 'Interviewer'];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Question__c> getQuestions(){
        try {
            return [SELECT Id, Name
                    FROM Question__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertPossibleInterviewers(Id stageId, List<Id> possibleInterviewers){
        try {
            List<Possible_Interviewer__c> newPossibleInterviewers = new List<Possible_Interviewer__c>();
            for(Id interviewer : possibleInterviewers) {
                Possible_Interviewer__c newInterviewer = new Possible_Interviewer__c();
                newInterviewer.Interview_Stage__c = stageId;
                newInterviewer.Interviewer__c = interviewer;
                newPossibleInterviewers.add(newInterviewer);
            }

            insert newPossibleInterviewers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertInterviewQuestions(Id stageId, List<Id> questions){
        try {
            List<Interview_Questions__c> newInterviewQuestions = new List<Interview_Questions__c>();
            for(Id question : questions) {
                Interview_Questions__c interviewQuestion = new Interview_Questions__c();
                interviewQuestion.Interview_Stage__c = stageId;
                interviewQuestion.Question__c = question;
                newInterviewQuestions.add(interviewQuestion);
            }

            insert newInterviewQuestions;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
