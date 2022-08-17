public with sharing class TaskGenerator {
    //ignore
    public static void handleTimesheetReminders(List<Timesheet__c> insertedTimesheets) {
        List<Id> timesheetIds = new List<Id>();
        for(Timesheet__c t : insertedTimesheets) {
            timesheetIds.add(t.Id);
        }

        generateTimecardReminders(timesheetIds);
    }

    //ignore
    @future
    public static void generateTimecardReminders(List<Id> timesheetIds){
        List<Task> timesheetReminders = new List<Task>(); 
        for(Id i : timesheetIds) {
            Task reminder = new Task();
            reminder.WhatId = i;
            reminder.Subject = 'Submit your Timecard!';
            reminder.ActivityDate = Date.today().addDays(7);

            timesheetReminders.add(reminder);
        }

        insert timesheetReminders;
    }

    //ignore
    public static void generateTimecardRemindersInTheFuture(List<Timesheet__c> insertedTimesheets){
        List<Id> timesheetIds = new List<Id>();
        for(Timesheet__c t : insertedTimesheets) {
            timesheetIds.add(t.Id);
        }

        ScheduledTask futureTask = new ScheduledTask(timesheetIds);
        Datetime scheduledDate = Datetime.now().addMinutes(3);
        String schCronExp = scheduledDate.format('s m H d M \'?\' yyyy');
        String jobID = System.schedule('Timecard Reminder ' + System.currentTimeMillis(), schCronExp, futureTask);
    }

    public static void generateInterviewInvite(List<Assigned_Interviewer__c> newAssignedInterviewers) {
        List<Id> assignedInterviewerIds = new List<Id>();
        List<Task> interviewInvites = new List<Task>(); 

        for(Assigned_Interviewer__c assignedInterviewer : newAssignedInterviewers) {
            Task invite = new Task();
            invite.OwnerId = assignedInterviewer.Interviewer__c;
            invite.WhatId = assignedInterviewer.Id;
            invite.Subject = 'Accept/Decline Interview Invite';
            invite.ActivityDate = Date.today().addDays(1);

            interviewInvites.add(invite);
        }

        insert interviewInvites;
    }

    public static void generateJobOfferTask(List<Job_Application__c> newApplicationValues, Map<Id,Job_Application__c> oldApplicationValues) {
        List<Id> jobPostingIds = new List<Id>(); 

        for(Job_Application__c application : newApplicationValues) {
            if (application.Status__c == 'Offered' && oldApplicationValues.get(application.Id).Status__c != 'Offered') {
                jobPostingIds.add(application.Job_Posting__c);
            }
        }

        Map<Id, Job_Posting__c> jobPostingsWithCandidates = new Map<Id, Job_Posting__c>([SELECT Id, Posted_by__c 
                                                                                        FROM Job_Posting__c 
                                                                                        WHERE Id IN :jobPostingIds]);

        List<Task> sendJobOfferTasks = new List<Task>();
        for(Job_Application__c application : newApplicationValues) {
            if(jobPostingsWithCandidates.containsKey(application.Job_Posting__c)) {
                Task sendOffer = new Task();
                sendOffer.OwnerId = jobPostingsWithCandidates.get(application.Job_Posting__c).Posted_by__c;
                sendOffer.WhatId = application.Id;
                sendOffer.Subject = 'Create Job Offer';
                sendOffer.ActivityDate = Date.today().addDays(7);

                sendJobOfferTasks.add(sendOffer);
            }
        }

        insert sendJobOfferTasks;
    }

}
