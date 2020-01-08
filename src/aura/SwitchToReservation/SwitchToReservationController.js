({
    doInit: function(cmp, event, helper) {
        var action = cmp.get("c.updateRecordType");
        action.setParams({ recordId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var successMsg = 'The record has been updated.';
                helper.showToast(event, successMsg, 'success', 'dismissible', null);  
                helper.closeQuickAction(cmp, event, helper);
            } else if (state === "INCOMPLETE") {
                var errorMsg = 'User is offline, device does not support drafts.';
                helper.showToast(event, errorMsg, 'error', 'dismissible', null);
                $A.get("e.force:closeQuickAction").fire();
            } else if (state === "ERROR") {
                helper.showToast(event, response.getError()[0].message, 'error', 'dismissible', null);
                $A.get("e.force:closeQuickAction").fire();
            } 
        });
        $A.enqueueAction(action);
    }
})