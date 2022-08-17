public with sharing class ProjectManagerAssigner {
    public ProjectManagerAssigner() {

    }

    public static void assignTimesheetManagerFromProject(List<Timesheet__c> insertedTimesheets) {
        List<Id> projectIds = new List<Id>();

        for(Timesheet__c t: insertedTimesheets) {
            if (t.Project__c != null) {  
                projectIds.add(t.Project__c);
            } 
        }

        Map<Id, Project__c> queriedProjects = new Map<Id, Project__c>([SELECT Id, Project_Manager__c 
                                                                        FROM Project__C 
                                                                        WHERE Id IN :projectIds]);
        
        for(Timesheet__c t: insertedTimesheets) {
            if(queriedProjects.containsKey(t.Project__c)) {
                t.Project_Manager__c = queriedProjects.get(t.Project__c).Project_Manager__c;
            }
        } 

    }

}