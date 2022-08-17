@isTest
private class TimesheetStatusManagerTest {

    private static Project__c generateProject(String projectName) {
        Project__c testProject = new Project__c();
        testProject.Name = projectName;
        return testProject;
    }

    private static Timesheet__c generateTimesheet(Id projectId, String status) {
        Timesheet__c testTimesheet = new Timesheet__c();
        testTimesheet.Project__c = projectId;
        testTimesheet.Timesheet_Status__c = status;
        return testTimesheet;
    }

    @TestSetup
    static void createTimesheetData(){
        Project__c testProject = generateProject('Unit Test Project');
        insert testProject; 

        Timesheet__c testTimesheet = generateTimesheet(testProject.Id, 'Draft');
        insert testTimesheet;

    }

    @isTest
    static void updateRejectionCount_givenRejectedTimesheet_shouldIncrement(){
        List<Timesheet__c> testTimesheets = [SELECT Timesheet_Status__c  FROM Timesheet__c];

        Test.startTest(); //resets governor limits 
        
        testTimesheets[0].Timesheet_Status__c = 'Rejected';
        update testTimesheets[0];

        Test.stopTest();

        List<Timesheet__c> updatedTimesheets = [SELECT Rejected_Count__c 
                                                FROM Timesheet__c];
        System.assertEquals(1, updatedTimesheets[0].Rejected_Count__c, 
                            'Rejection number should have been incremented');

    }

    @isTest
    static void updateRejectionCount_givenSubmittedTimesheet_shouldNotIncrement(){
        List<Timesheet__c> testTimesheets = [SELECT Timesheet_Status__c  FROM Timesheet__c];

        Test.startTest(); 
        
        testTimesheets[0].Timesheet_Status__c = 'Submitted';
        update testTimesheets[0];

        Test.stopTest();

        List<Timesheet__c> updatedTimesheets = [SELECT Rejected_Count__c 
                                                FROM Timesheet__c];
        System.assertEquals(0, updatedTimesheets[0].Rejected_Count__c, 
                            'Rejection number should not have been incremented');
    }

    @isTest
    static void updateRejectionCount_givenAlreadyRejectedTimesheet_shouldNotIncrementAgain(){
        List<Timesheet__c> testTimesheets = [SELECT Timesheet_Status__c  FROM Timesheet__c];

        testTimesheets[0].Timesheet_Status__c = 'Rejected';
        update testTimesheets[0];

        Test.startTest(); 
        
        update testTimesheets[0];

        Test.stopTest();

        List<Timesheet__c> updatedTimesheets = [SELECT Rejected_Count__c 
                                                FROM Timesheet__c];
        System.assertEquals(1, updatedTimesheets[0].Rejected_Count__c, 
                            'Rejection number should not have been incremented more than once');
    }
}