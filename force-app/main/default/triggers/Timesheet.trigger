trigger Timesheet on Timesheet__c (before update, before insert, after update, after insert) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        TimesheetStatusManager.updateRejectionCount(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isBefore && Trigger.isInsert) {
        ProjectManagerAssigner.assignTimesheetManagerFromProject(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        TimesheetStatusManager.closeRelatedTasks(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        TaskGenerator.handleTimesheetReminders(Trigger.new);
        //TaskGenerator.generateTimecardRemindersInTheFuture(Trigger.new);
    }
}