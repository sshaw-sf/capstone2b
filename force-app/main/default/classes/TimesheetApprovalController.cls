public with sharing class TimesheetApprovalController {

    @AuraEnabled(cacheable=true)
    public static List<Timesheet__c> getRelatedTimesheets(Id projectId){
        try {
            return [
                SELECT Id, Name, Timesheet_Status__c, Rejected_Count__c
                FROM Timesheet__c
                WHERE Project__c = :projectId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void rejectTimesheets(List<Timesheet__c> timesheets){
        try {
            for(Timesheet__c timesheet: timesheets) {
                timesheet.Timesheet_Status__c = 'Rejected';
            }

            update timesheets;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void approveTimesheets(List<Timesheet__c> timesheets){
        try {
            for(Timesheet__c timesheet: timesheets) {
                timesheet.Timesheet_Status__c = 'Approved';
            }

            update timesheets;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Timesheet__c> getRecentTimesheets(Id projectId) {
        try {
            return [SELECT Id, Name, Timesheet_Status__c, Rejected_Count__c
                    FROM Timesheet__c
                    WHERE Project__c = :projectId AND CreatedDate = TODAY
                    ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
