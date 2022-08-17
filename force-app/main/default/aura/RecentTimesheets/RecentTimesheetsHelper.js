({
    queryRecentTimesheets : function(component, helper) {
        var action = component.get('c.getRecentTimesheets')
        var projectId = component.get('v.recordId');

        action.setParams({ projectId: projectId });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var timesheets = response.getReturnValue();

                console.log('aura timesheets');
                console.log(timesheets);

                component.set('v.timesheets', timesheets)
            } else {
                //error handling
            }
        });

        $A.enqueueAction(action);
    }
})
