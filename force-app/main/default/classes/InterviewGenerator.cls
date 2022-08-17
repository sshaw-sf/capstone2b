public with sharing class InterviewGenerator {
    @AuraEnabled
    public static List<Id> insertAssignedInterviewers(Id interviewId, List<Id> possibleInterviewers){
        try {
            List<Assigned_Interviewer__c> newAssignedInterviewers = new List<Assigned_Interviewer__c>();

            for(Id i : possibleInterviewers) {
                Assigned_Interviewer__c interviewer = new Assigned_Interviewer__c();
                interviewer.Interviewer__c = i; 
                interviewer.Interview__c = interviewId;
                newAssignedInterviewers.add(interviewer);
            }
            
            insert newAssignedInterviewers;
            return possibleInterviewers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<User> getInterviewerUsername(List<Id> userIds){
        try {
            return [SELECT Id, FirstName, LastName
                    FROM User
                    WHERE Id IN :userIds];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
