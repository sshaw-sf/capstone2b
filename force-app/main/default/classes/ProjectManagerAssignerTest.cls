@isTest
private class ProjectManagerAssignerTest {
    private static Contact generateContact(String lastName) {
        Contact testContact = new Contact();
        testContact.LastName = lastName;
        return testContact;
    }

    private static Project__c generateProject(String projectName, Id projectManagerId) {
        Project__c testProject = new Project__c();
        testProject.Name = projectName;
        testProject.Project_Manager__c = projectManagerId;
        return testProject;
    }

    private static Timesheet__c generateTimesheet(Id projectId) {
        Timesheet__c testTimesheet = new Timesheet__c();
        testTimesheet.Project__c = projectId;
        return testTimesheet;
    }

    @TestSetup
    static void createTimesheetData(){
        Contact testContact = generateContact('Shaw');
        insert testContact; 

        Project__c testProject = generateProject('Unit Test Project', testContact.Id);
        insert testProject; 
    }

    @isTest
    static void assignTimesheetManagerFromProject_givenNewTimesheet_shouldAssignProjectManager() {
        List<Project__c> testProjects = [SELECT Id, Project_Manager__c FROM Project__c];

        Test.startTest();

        Timesheet__c testTimesheet = generateTimesheet(testProjects[0].Id);
        insert testTimesheet;

        Test.stopTest();

        List<Project__c> insertedTimesheet = [SELECT Id, Project_Manager__c FROM Project__c];

        System.assertEquals(testProjects[0].Project_Manager__c, insertedTimesheet[0].Project_Manager__c,
                                    'Project Manager should be the same');

    }

}
