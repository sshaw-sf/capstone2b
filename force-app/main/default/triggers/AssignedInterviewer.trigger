trigger AssignedInterviewer on Assigned_Interviewer__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        QuestionResponseGenerator.generateQuestionResponses(Trigger.new);
        TaskGenerator.generateInterviewInvite(Trigger.new);
    }
}