
function status_attendees_in (moderators, participants) {
    var msg_attendees_in = '';

    if (typeof moderators != 'undefined' && typeof participants != 'undefined') {
        var viewers = participants - moderators;
        if ( participants > 1 ) {
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

function status_started_at (startTime) {
    var start = new Date(startTime);
    var hours = start.getHours();
    var minutes = start.getMinutes();

    return 'This session started at ' + ' <b>' + hours + ':' + (minutes<10? '0': '') + minutes + '</b>';
}

function status_running_for (startTime) {
    var start = new Date (startTime);
    return ' and has been running for <span id="elapsed_time">' + elapsed_time (start) +'</span>.';
}

function startTimer (startTime) {
    var start = new Date (startTime);
    var ticker = Ticker.getInstance ();
    ticker.start ( function() { tick (start); }, 1000);
}

function stopTimer (timerId) {
    var ticker = Ticker.getInstance ();
    ticker.stop ();
}

function elapsed_time (start) {
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

    return "<b>" + pretty + "</b> " + ( hrs > 0 ? t_hrs: mns > 0? t_mns: t_scs );
}

function tick (start) {
    $("#elapsed_time").html ( elapsed_time (start) );
}

function refreshRoom () {
    $.ajax({
        url: $('#room').data ('url'),
        dataType : "json",
        async : true,
        success : function (data) {
            var status = {};
            var room_data = data.room;
            var error_data = data.error;
            if( error_data == null ) {
                var meeting_data = data.meeting;
                // Update the status
                if( meeting_data.running ){
                    status.current = status_started_at (meeting_data.startTime);
                    status.current += status_running_for(meeting_data.startTime);
                    status.current += ' '+status_attendees_in(meeting_data.moderatorCount, meeting_data.participantCount);
                } else {
                    status.current = 'There are no users in this session.';
                }

                status.general = "A session in this room is in progress.";
                if(!room_data.can_use) {
                    status.general += " But you can not enter now.";
                    $('#room_enter').html ('');
                } else {
                    status.general += " You can enter right now.";
                    if(!room_data.user_signed_in) {
                        $('#room_enter').html ('<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#modal_room">Enter</button>');
                        $('#modal_room_enter').html ('<button id="modal_room_enter_button" type="submit" class="btn btn-primary" data-dismiss="modal">Enter</button>');
                        $('#modal_room_enter_button').click (function (event) {
                            console.info ('modal_room_enter_button clicked 0');
                            $('#modal_room_enter_form').submit ();
                            $('#modal_room').toggle ();
                        });
                    } else {
                        $('#room_enter').html ('<button id="room_enter_button" type="button" class="btn btn-primary">Enter</button>');
                        $('#room_enter_button').click (function (event) {
                            window.open ($("#room_enter").data ('url'));
                            window.setTimeout (refreshRoom, 15000);
                        });
                    }
                }

                if(!room_data.can_close || !meeting_data.running) {
                    $('#room_close').html('');
                } else {
                    $('#room_close').html ('<a class="btn btn-default" role="button">Close</a>');
                }

                $('#room_status_current').html (status.current);
                startTimer (meeting_data.startTime);

            } else {
                if( error_data.key == 'BBBNotfound' ) {
                    if(!room_data.can_use) {
                        status.general = "Room is ready, but you can not enter now.";
                        $('#room_enter').html ('');
                    } else {
                        status.general = "Room is ready to enter.";
                        if(!room_data.user_signed_in) {
                            $('#room_enter').html ('<button id="room_enter_button" type="button" class="btn btn-primary" data-toggle="modal" data-target="#modal_room">Enter</button>');
                            $('#modal_room_enter').html ('<button id="modal_room_enter_button" type="submit" class="btn btn-primary">Enter</button>');
                            $('#modal_room_enter_button').click (function (event) {
                                console.info ('modal_room_enter_button clicked 1');
                                $('#modal_room_enter_form').submit ();
                                $('#modal_room').toggle ();
                            });
                        } else {
                            $('#room_enter').html ('<button id="room_enter_button" type="button" class="btn btn-primary">Enter</button>');
                            $('#room_enter_button').click (function (event) {
                                window.open ($("#room_enter").data ('url'));
                                window.setTimeout (refreshRoom, 15000);
                            });
                        }
                    }

                    $('#room_close').html ('');

                } else {
                    status.general = "Room can not be used right now.";
                }
                stopTimer ();
                status.current = '';
                $('#room_status_current').html (status.current);
            }

            $('#room_status_general').html (status.general);

        },
        error : function(xmlHttpRequest, status, error) {
            //BBBUtils.handleError(bbb_err_get_meeting, xmlHttpRequest.status, xmlHttpRequest.statusText);
        }
    });
};

function refreshRecordings () {
};

function initButtonRoomRefresh () {
    $('#room_refresh').click (function (event) {
        refreshRoom ();
        refreshRecordings ();
    });
}

function initButtonRoomEnter () {
    //if( $("#room_enter_modal").length ) {
    //    // Modal defined, user NOT signed in
    //} else {
    //    // Modal NOT defined, user signed in
    //}
}

function initButtonRoomClose () {
    $('#room_close').click (function (event) {
        $.ajax({
            url : $("#room_close").data ('url'),
            dataType : "json",
            async : true,
            type : 'DELETE',
            success : function(data) {
            },
            error : function(xhr, status, error) {
            },
            complete : function(xhr, status) {
                refreshRoom ();
            }
        });
    });
}

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

function getRecordingActionButtonId (action, id) {
    return 'recording_'+action+'_'+id;
}

function getRecordingActionButtonText (action) {
    return action.capitalize ();
}

function getRecordingActionMethod (action) {
    var method;
    if (action == 'delete') {
        method = 'DELETE';
    } else {
        method = 'PATCH';
    }
    return method;
}

function getRecordingActionGlyphIcon (action) {
    var glyphicon;
    if (action == 'delete') {
        glyphicon = 'glyphicon-remove';
    } else if (action == 'unpublish') {
        glyphicon = 'glyphicon-eye-open';
    } else {
        glyphicon = 'glyphicon-eye-close';
    }
    return glyphicon;
}

function initRecordingActions () {
    $('.recording_action').each(function(i, obj) {
        var action = $(this).data ('action');
        var button_id = getRecordingActionButtonId (action, $(this).data ('id'));
        var button_text = getRecordingActionButtonText (action);
        var button_glyphicon = getRecordingActionGlyphIcon (action);
        $(this).html ('<button type="button" id="'+button_id+'" title="'+button_text+'" name="'+button_text+'" class="btn btn-default glyphicon '+button_glyphicon+' pull-left" data-id="'+$(this).data ('id')+'" data-action="'+action+'" data-url="'+$(this).data ('url')+'"></button>');

        if ( action == 'delete' ) {
            $('#'+button_id).click (function (event) {
                console.info ($(this));
            });
        } else {
            $('#'+button_id).click (function (event) {
                var recording_id = $(this).data ('id');
                var recording_action = $(this).data ('action');
                var recording_action_url = $(this).data ('url');

                $.ajax({
                    url : recording_action_url+"?id="+recording_id+"&status="+recording_action,
                    dataType : "json",
                    async : true,
                    type : getRecordingActionMethod (recording_action),
                    success : function(data) {
                        var inverse_action = (recording_action == 'publish'? 'unpublish': 'publish');
                        //Update action
                        $('#'+button_id).data ('action', inverse_action);
                        //Update the text
                        var button_text = getRecordingActionButtonText (inverse_action);
                        $('#'+button_id).prop ('title', button_text);;
                        $('#'+button_id).prop ('name', button_text);;
                        //Update the icon
                        var button_glyphicon = getRecordingActionGlyphIcon (recording_action);
                        $('#'+button_id).removeClass (button_glyphicon);
                        button_glyphicon = getRecordingActionGlyphIcon (inverse_action);
                        $('#'+button_id).addClass (button_glyphicon);
                        // Show or hide the links to the recordings
                        if( recording_action == 'publish' ) {
                            $('#recording_playback_'+recording_id).removeClass ('hide');
                        } else {
                            $('#recording_playback_'+recording_id).addClass ('hide');
                        }
                    },
                    error : function(xhr, status, error) {
                    },
                    complete : function(xhr, status) {
                    }
                });

            });
        }
    });
}
