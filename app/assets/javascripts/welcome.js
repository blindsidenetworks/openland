var BBBUtils;

(function() {

    if(BBBUtils == null)
        BBBUtils = new Object();

    var broker_endpoint = "/bbb/";

    // Get meeting info from BBB server
    BBBUtils.getMeetingInfo = function(meeting_id) {
        var meeting_info = null;

        jQuery.ajax({
            url: broker_endpoint + "/room/get/" + meeting_id + ".json",
            dataType : "json",
            async : true,
            success : function(data) {
                meeting_info = data;
            },
            error : function(xmlHttpRequest,status,error) {
                BBBUtils.handleError(bbb_err_get_meeting, xmlHttpRequest.status, xmlHttpRequest.statusText);
                return null;
            }
        });

        return meeting_info;
    }
});

(function() {
    console.info ("ready!");
    $(document).ready(function($) {
        console.info ("ready!");
        BBBUtils.getMeetingInfo ('1');
    });
});
