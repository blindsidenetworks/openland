var BBBUtils;

(function() {

    if(BBBUtils == null)
        BBBUtils = new Object();

    // Get meeting info from BBB server
    BBBUtils.getRoomStatus = function(room_status_url) {
        var room_status = null;

        console.info (room_status_url);
        jQuery.ajax({
            url: room_status_url,
            dataType : "json",
            async : true,
            success : function(data) {
                console.info (data);
                room_status = data;
            },
            error : function(xmlHttpRequest, status, error) {
                //BBBUtils.handleError(bbb_err_get_meeting, xmlHttpRequest.status, xmlHttpRequest.statusText);
                return null;
            }
        });

        return room_status;
    }
})();

(function() {

    function updateRoomStatus(status) {
        $("#room_status").html (status);
    }

    function refreshRoom() {
        jQuery.ajax({
            url: $('#room').data('url'),
            dataType : "json",
            async : true,
            success : function(data) {
                if( data.error == null ) {
                    var info = data.info;
                    console.info (info);
                    // Update the status
                    var status = "A session in this room is in progress.";
                    if(!info.enter_url) {
                        status += " But you can not enter now.";
                    } else {
                        status += " You can enter right now.";
                    }
                    $('#room_status').html (status);
                    // Update the actionbar

                } else {
                    console.info (data.error);
                    var error = data.error;
                    if( error.key == 'BBBNotfound' )
                        updateRoomStatus ("Room is ready to enter.");
                    else
                        updateRoomStatus ("Room can not be used right now.");
                }
            },
            error : function(xmlHttpRequest, status, error) {
                //BBBUtils.handleError(bbb_err_get_meeting, xmlHttpRequest.status, xmlHttpRequest.statusText);
            }
        });
    };

    $(document).ready(function($) {
        console.info ("ready!");
        refreshRoom();
    });
})();
