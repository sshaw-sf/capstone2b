public with sharing class TimesheetStatusManager {
    public TimesheetStatusManager() {

    }

    public static void updateRejectionCount(List<Timesheet__c> updatedTimesheets,
                                            Map<Id,Timesheet__c> oldTimesheetValues) {
        for(Timesheet__c t : updatedTimesheets) {
            if(t.Timesheet_Status__c == 'Rejected' 
                && oldTimesheetValues.get(t.Id).Timesheet_Status__c != 'Rejected') {
                t.Rejected_Count__c += 1;
            }
        }
    }

    public static void closeRelatedTasks(List<Timesheet__c> updatedTimesheets) {
        List<Id> submittedTimesheetIds = new List<Id>();

        for(Timesheet__c t : updatedTimesheets) {
            if(t.Timesheet_Status__c == 'Submitted') {
                submittedTimesheetIds.add(t.Id);
            }
        }

        List<Task> relatedTasks = [SELECT Id, Status 
                                    FROM Task
                                    WHERE WhatId IN :submittedTimesheetIds];

        for(Task t: relatedTasks) {
            t.Status = 'Completed';
        }
        
        update relatedTasks;
    }
    
}
