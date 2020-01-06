({
    showToast : function(event, message, type, mode) {
        var title = type.includes('error') ? 'Error' : type.includes('success') ? 'Success' : 
        type.includes('warning') ? 'Warning' : 'Unknown Error Occurred';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type : type, 
            duration: '100',
            key: 'info_alt',
            mode: mode,
            message: message
        });
        toastEvent.fire();
    },
    closeQuickAction: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();  
        $A.get("e.force:closeQuickAction").fire();
    }
})