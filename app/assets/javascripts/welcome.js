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

function status_attendees_in (moderators, participants) {
    var msg_attendees_in = '';

    if (typeof moderators != 'undefined' && typeof participants != 'undefined') {
        var viewers = participants - moderators;
        if( participants > 1 ) {
            var viewers = participants - moderators;
            msg_attendees_in += 'There are ' + ' <b>' + moderators + '</b> ' + (moderators == 1? 'moderator': 'moderators') + ' and ';
            msg_attendees_in += '<b>' + viewers + '</b> ' + (viewers == 1? 'viewer': 'viewers') + '.';

        } else {
            if( viewers > 0 ) {
                msg_attendees_in += 'There is' + ' <b>1</b> ' + 'viewer' + '.';
            } else if ( moderators > 0 ) {
                msg_attendees_in += 'There is' + ' <b>1</b> ' + 'moderator' + '.';
            }
        }

    } else {
        msg_attendees_in = bigbluebuttonbn.locales.session_no_users + '.';
    }

    return msg_attendees_in;
}

function status_started_at(startTime) {
    console.info (startTime);
    //var start_timestamp = (parseInt(startTime) -  parseInt(startTime) % 1000);
    var date = new Date(startTime);
    //datevalues = [
    //    date.getFullYear(),
    //    date.getMonth()+1,
    //    date.getDate(),
    //    date.getHours(),
    //    date.getMinutes(),
    //    date.getSeconds(),
    // ];
    var hours = date.getHours();
    var minutes = date.getMinutes();

    return 'This session started at ' + ' <b>' + hours + ':' + (minutes<10? '0': '') + minutes + '</b>';
}

function status_running_for() {
    return ' and has been running for <b><span id="elapsed_time"></span></b> <span id="elapsed_time_units"></span>.';
}


function startTimer(startTime) {
    var start = new Date(startTime);
    var elapsed;
    window.setInterval( function() { tick(start); }, 1000);
    tick(start);
}

function tick(start) {
    var t_hrs = "hours";
    var t_mns = "minutes";
    var t_scs = "seconds";

    var time = new Date().getTime() - start;

    elapsed = Math.floor(time / 1000);
    if(Math.round(elapsed) == elapsed) { elapsed += '.0'; }

    var secs = elapsed;
    var hrs = Math.floor( secs / 3600 );
    secs %= 3600;
    var mns = Math.floor( secs / 60 );
    secs %= 60;

    var pretty = ( hrs < 10 ? "0" : "" ) + hrs
               + ":" + ( mns < 10 ? "0" : "" ) + mns
               + ":" + ( secs < 10 ? "0" : "" ) + parseInt(secs);

    //$("#elapsed_time").html = pretty;
    //$("#elapsed_time_units").html = ( hrs > 0 ? t_hrs: mns > 0? t_mns: t_scs );
    document.getElementById("elapsed_time").innerHTML = pretty;
    document.getElementById("elapsed_time_units").innerHTML = ( hrs > 0 ? t_hrs: mns > 0? t_mns: t_scs );

}

    function executeCall(execute_url) {
        console.info (execute_url);
        $.ajax({
            url : execute_url,
            dataType : "json",
            async : true,
            type : 'DELETE',
            success : function(data) {
                console.info (data);
            },
            error : function(xmlHttpRequest, status, error) {
                //BBBUtils.handleError(bbb_err_get_meeting, xmlHttpRequest.status, xmlHttpRequest.statusText);
            }
        });
    }


(function() {

    function refreshRoom() {
        $.ajax({
            url: $('#room').data('url'),
            dataType : "json",
            async : true,
            success : function(data) {
                var status = {};
                var room_data = data.room;
                var error_data = data.error;
                if( error_data == null ) {
                    var meeting_data = data.meeting;
                    // Update the status
                    console.info (meeting_data);
                    if( meeting_data.running ){
                        status.current = status_started_at(meeting_data.startTime);
                        status.current += status_running_for();
                        status.current += ' '+status_attendees_in(meeting_data.moderatorCount, meeting_data.participantCount);

                    } else {
                        status.current = 'nothing to say';
                    }

                    status.general = "A session in this room is in progress.";
                    if(!room_data.enter_url) {
                        status.general += " But you can not enter now.";
                    } else {
                        status.general += " You can enter right now.";
                        $('#room_enter').html('<a class="btn btn-primary" role="button" target="_blank" href="'+room_data.enter_url+'">Enter</a>');
                    }
                    if(typeof room_data.close_url === 'undefined') {
                        //Do nothing
                    } else {
                        $('#room_close').html('<a class="btn btn-default" onclick="executeCall(\''+room_data.close_url+'\');">Close</a>');
                    }

                    $('#room_status_current').html (status.current);
                    startTimer(meeting_data.startTime);

                } else {
                    if( error_data.key == 'BBBNotfound' ) {
                        if(!room_data.enter_url) {
                            status.general = "Room is ready, but you can not enter now.";
                        } else {
                            status.general = "Room is ready to enter.";
                            $('#room_enter').html('<a class="btn btn-primary" role="button" target="_blank" href="'+room_data.enter_url+'">Enter</a>');
                        }
                    } else {
                        status.general = "Room can not be used right now.";
                    }
                    status.current = '';
                }

                $('#room_status_general').html (status.general);

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
