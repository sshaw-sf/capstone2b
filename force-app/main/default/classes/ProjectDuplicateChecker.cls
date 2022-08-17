public with sharing class ProjectDuplicateChecker {
    @InvocableMethod
    public static List<Project__c> checkForDuplicateProjects(List<Project__c> insertedProjects) {
        System.debug('Called Dupe checker');

        List<Contact> newProjectManager = new List<Contact>();
        newProjectManager = [SELECT Id
                            FROM Contact
                            WHERE Name LIKE '%Sarah%' LIMIT 1];

        if(newProjectManager.size() > 0) {
            for (Project__c p : insertedProjects) {
                p.Project_Manager__c = newProjectManager[0].Id;
            }
        }

        return insertedProjects;
    }

    public class DuplicateParameter {
        @InvocableVariable 
        public List<Project__c> projects;

        @InvocableVariable 
        public List<Timecard__c> timecards;

        @InvocableVariable 
        public List<Contact> contacts;
    }
    
}
