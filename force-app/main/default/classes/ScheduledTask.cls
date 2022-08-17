global class ScheduledTask implements Schedulable{

    private List<Id> insertedTimesheetIds;

    public ScheduledTask(List<Id> insertedTimesheetIds) {
        this.insertedTimesheetIds = insertedTimesheetIds;
    }

    /* My solution:
    global void execute(SchedulableContext SC) {
        List<Task> timesheetReminders = new List<Task>(); 
        for(Id i : insertedTimesheetIds) {
            Task reminder = new Task();
            reminder.WhatId = i;
            reminder.Subject = 'Submit your Timecard!';
            reminder.ActivityDate = Date.today().addDays(7);

            timesheetReminders.add(reminder);
        }

        insert timesheetReminders;
    }
    */

    public void execute(SchedulableContext SC) {
        List<Timesheet__c> timesheetNeedingTasks = new List<Timesheet__c>();
        timesheetNeedingTasks = [SELECT Id
                                FROM Timesheet__c
                                WHERE CreatedDate = :Date.today().addDays(-7)];
        List<Task> generatedTasks = new List<Task>();
        for(Timesheet__c t : timesheetNeedingTasks) {
            Task reminder = new Task();
            reminder.WhatId = t.Id;
            reminder.Subject = 'Submit your Timecard!';
            reminder.ActivityDate = Date.today().addDays(1);

            generatedTasks.add(reminder);
        }
        insert generatedTasks;
    }
}
