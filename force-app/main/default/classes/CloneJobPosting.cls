public with sharing class CloneJobPosting {
    
    public CloneJobPosting() {

    }

    @InvocableMethod(label='Deep Clone Job Posting' description='Returns a deep clone of a job posting.' category='Job Posting')
    public static void deepCloneJobPostings(List<Job_Posting__c> originalJobPosts) {
        List<Id> jobPostIds = new List<Id>();
        for (Job_Posting__c jobPost : originalJobPosts) {
            jobPostIds.add(jobPost.Id);   
        }

        List<Job_Posting__c> jobPosts = [SELECT Id, Name, Department__c, Job_Description__c, Job_Qualifications__c, 
                                            No_Job_Offers_Accepted__c, No_Open_Positions__c, OwnerId, Posted_by__c, Salary__c
                                        FROM Job_Posting__c
                                        WHERE Id IN :jobPostIds];
                                        
        for (Job_Posting__c jobPost : jobPosts) {
            cloneJobPosting(jobPost);   
        }
    }

    public static void cloneJobPosting(Job_Posting__c originalJobPost){
        Job_Posting__c jobPostClone = originalJobPost.clone(false);
        jobPostClone.Status__c = 'Draft';
        jobPostClone.Name = originalJobPost.Name + ' Clone';
        insert jobPostClone;


        List<Interview_Stage__c> interviewStages = [SELECT Id, Name, Number_Of_Interviewers__c, 
                                                            (SELECT Id, Name, Interviewer__c FROM Possible_Interviewers__r),
                                                            (SELECT Id, Question__c FROM Interview_Questions__r)
                                                    FROM Interview_Stage__c
                                                    WHERE Job_Posting__r.Id = :originalJobPost.Id];

        List<Interview_Stage__c> interviewStageClones = new List<Interview_Stage__c>();

        for(Interview_Stage__c stage : interviewStages) {
            Interview_Stage__c stageClone = stage.clone(false);
            stageClone.Job_Posting__c = jobPostClone.Id;
            interviewStageClones.add(stageClone);  
        }

        insert interviewStageClones;

        Map<Id, Id> originalStageToClone = new Map<Id, Id>();

        for(Interview_Stage__c cloneStage : interviewStageClones) {
            originalStageToClone.put(cloneStage.getCloneSourceId(), cloneStage.Id);
        }

        List<Interview_Questions__c> interviewQuestionClones = new List<Interview_Questions__c>();
        List<Possible_Interviewer__c> possibleInterviewersClones = new List<Possible_Interviewer__c>();

        for(Interview_Stage__c ogStage : interviewStages) {
            for(Possible_Interviewer__c possibleInterviewer : ogStage.Possible_Interviewers__r) {
                Possible_Interviewer__c interviewerClone = possibleInterviewer.clone(false);
                interviewerClone.Interview_Stage__c = originalStageToClone.get(ogStage.Id); 
                possibleInterviewersClones.add(interviewerClone);
            }

            for(Interview_Questions__c queestion : ogStage.Interview_Questions__r) {
                Interview_Questions__c questionClone = queestion.clone(false);
                questionClone.Interview_Stage__c = originalStageToClone.get(ogStage.Id); 
                interviewQuestionClones.add(questionClone);
            }

        }

        insert possibleInterviewersClones;
        insert interviewQuestionClones; 

    }
  
}
