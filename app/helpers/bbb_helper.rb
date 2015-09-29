module BbbHelper
  def bbb_get_recordings(room)
    response_data = nil

    if (can? :read, room)
      bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
      if !bbb
        response_data = { :returncode => false, :messageKey => "BBBAPICallInvalid", :message => "BBB API call invalid." }
      else
        meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s
        begin
          response_data = bbb.get_recordings({:meetingID => meeting_id })
        rescue BigBlueButton::BigBlueButtonException => exc
          response_data = { :returncode => false, :messageKey => 'BBB'+exc.key.capitalize, :message => exc.message }
        end
      end
    else
      response_data = { :returncode => false, :messageKey => 'APPError', :message => "Access denied to this resource" }
    end

    response_data
  end

  def bbb_get_meeting_join_url(room)
    response_data = nil

    if (can? :read, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
        if !bbb
          response_data = { :returncode => false, :messageKey => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s

          #See if the meeting is running
          begin
            bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
          rescue BigBlueButton::BigBlueButtonException => exc
            logger.info "Message for the log file #{exc.key}: #{exc.message}"
            #This means that is not created, so create the meeting
            base_url = request.protocol+request.host+(request.port!=80? ':'+request.port.to_s: '')
            logout_url = base_url+'/bbb/close'              #Closes the window after correct logout
            meeting_options = {:welcome => room.welcome, :record => room.recording.to_s, :logoutURL => logout_url, :moderatorPW => room.moderator_password, :attendeePW => room.viewer_password }
            bbb.create_meeting(room.name, meeting_id, meeting_options)

            #And then get meeting info
            bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
          end

          #Get the join url
          if current_user != nil
            if (can? :manage, room)
              password = bbb_meeting_info[:moderatorPW]
              #user_name = 'Moderator'
            else
              password = bbb_meeting_info[:attendeePW]
              #user_name = 'Viewer'
            end
            user_name = (current_user.fullname == '')? current_user.username: current_user.fullname
          else
            password = bbb_meeting_info[:attendeePW]
            user_name = 'Viewer'
          end

          join_url = bbb.join_meeting_url(meeting_id, user_name, password)
          response_data = { :returncode => true, :join_url => join_url, :messageKey => "", :message => "" }
        end
    else
      response_data = { :returncode => false, :messageKey => "RoomAccessNotAllowed", :message => "Access to room with id ["+room_id.to_s+"] is not allowed" }
    end

    response_data
  end

  def bbb_get_meeting_info(room)
    response_data = nil

    if (can? :read, room)
      bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
      if !bbb
        response_data = { :returncode => false, :messageKey => "BBBAPICallInvalid", :message => "BBB API call invalid." }
      else
        meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s
        #See if the meeting is running
        begin
          bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
          response_data = { :returncode => true, :meeting_info => bbb_meeting_info, :messageKey => "", :message => "" }
        rescue BigBlueButton::BigBlueButtonException => exc
          response_data = { :returncode => false, :messageKey => "BBB"+exc.key.capitalize, :message => exc.message }
        end
      end
    else
      response_data = { :returncode => false, :messageKey => "RoomAccessNotAllowed", :message => "Access to room with id ["+room_id.to_s+"] is not allowed" }
    end

    response_data
  end
end
