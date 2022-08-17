public with sharing class QuestionResponseGenerator {
    public static void generateQuestionResponses(List<Assigned_Interviewer__c> insertedAssignedInterviewer){
        List<Id> assignedInterviewerIds = new List<Id>();

        for(Assigned_Interviewer__c assignedInterviewer : insertedAssignedInterviewer){
            assignedInterviewerIds.add(assignedInterviewer.Id);
        }

        List<Assigned_Interviewer__c> assignedInterviewers = [SELECT Id, Interview__r.Interview_Stage__r.Id
                                            FROM Assigned_Interviewer__c
                                            WHERE Id IN :assignedInterviewerIds];

        List<Id> stageIds = new List<Id>();
        
        for(Assigned_Interviewer__c assignedInterviewer : assignedInterviewers) {
            stageIds.add(assignedInterviewer.Interview__r.Interview_Stage__r.Id);
        }


        Map<Id, Interview_Stage__c> stages = new Map<Id, Interview_Stage__c>([SELECT Id, (SELECT Id, Question__c FROM Interview_Questions__r)
                                                FROM Interview_Stage__c
                                                WHERE Id IN :stageIds]);

        List<Question_Response__c> responses = new List<Question_Response__c>();

        for(Assigned_Interviewer__c assignedInterviewer : assignedInterviewers) {
            Id stageId = assignedInterviewer.Interview__r.Interview_Stage__r.Id;
            if(stages.containsKey(stageId)) {
                List<Interview_Questions__c> questions = stages.get(stageId).Interview_Questions__r;
                for(Interview_Questions__c question: questions) {
                    Question_Response__c newQuestionResponse = new Question_Response__c();
                    newQuestionResponse.Interview_Question__c = question.Id;
                    newQuestionResponse.Assigned_Interviewer__c = assignedInterviewer.Id;
                    responses.add(newQuestionResponse);
                }
            }
        }

        insert responses;
    }

    @AuraEnabled
    public static string updateQuestionResponses(Object data){
        List<Question_Response__c> questionResponsesToUpdate = (List<Question_Response__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Question_Response__c>.class
       );
        try {
            update questionResponsesToUpdate;
            return 'Success: question responses updated successfully';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
