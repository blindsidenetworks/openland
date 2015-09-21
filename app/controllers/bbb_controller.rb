require 'bigbluebutton_api'
require 'digest/sha1'

class BbbController < ApplicationController
  BBB_ENDPOINT = 'http://test-install.blindsidenetworks.com/bigbluebutton/'
  BBB_SECRET = '8cd8ef52e8e101574e400365b55e11a6'

  def enter
    error = nil

    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)
      if (can? :read, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(BBB_ENDPOINT + "api", BBB_SECRET, "0.8", true)
        if !bbb
          error = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s

          #See if the meeting is running
          begin
            meeting_info = bbb.get_meeting_info( meeting_id, nil )
          rescue BigBlueButton::BigBlueButtonException => exc
            logger.info "Message for the log file #{exc.key}: #{exc.message}"
            #This means that is not created, so create the meeting
            base_url = request.protocol+request.host+(request.port!=80? ':'+request.port.to_s: '')
            #logout_url = base_url+'/landing/'+room.id.to_s #Redirects to public page for the room
            logout_url = base_url+'/bbb/close'              #Closes the window after correct logout
            meeting_options = {:record => room.recording.to_s, :logoutURL => logout_url}
            logger.info meeting_options.inspect
            bbb.create_meeting(room.name, meeting_id, meeting_options)

            #And then get meeting info
            meeting_info = bbb.get_meeting_info( meeting_id, nil )
          end

          #Get the join url
          if current_user != nil
            if current_user.id == room.user_id
              password = meeting_info[:moderatorPW]
              #user_name = 'Moderator'
            else
              password = meeting_info[:attendeePW]
              #user_name = 'Viewer'
            end
            user_name = (current_user.fullname == '')? current_user.username: current_user.fullname
          else
            password = meeting_info[:attendeePW]
            user_name = 'Viewer'
          end

          join_url = bbb.join_meeting_url(meeting_id, user_name, password)

          #Execute the redirect
          logger.info "#Execute the redirect"
          redirect_to join_url
        end
      else
        error = { :key => "RoomAccessNotAllowed", :message => "Access to room with id ["+room_id.to_s+"] is not allowed"  }
      end

    rescue ActiveRecord::RecordNotFound => exc
      error = { :key => 'RoomNotFound', :message => exc.message }
    end

    if error != nil
      logger.info error.inspect
      render 'close'
    end
  end


  def close
  end

  #get    'bbb/room/:id', to: 'bbb#room_status', as: :bbb_room_status
  def room_status
    info = nil
    error = nil

    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)
      if (can? :read, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(BBB_ENDPOINT + "api", BBB_SECRET, "0.8", true)
        if !bbb
          error = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s

          #See if the meeting is running
          begin
            meeting_info = bbb.get_meeting_info( meeting_id, nil )
            #remove sensible information
            info = {}
            info[:running] = meeting_info[:running]
            info[:startTime] = meeting_info[:startTime]
            info[:endTime] = meeting_info[:endTime]
            info[:participantCount] = meeting_info[:participantCount]
            info[:listenerCount] = meeting_info[:listenerCount]
            info[:moderatorCount] = meeting_info[:moderatorCount]
            if (can? :use, room)
              info[:enter_url] = bbb_room_enter_path(room)
            end
            if (can? :manage, room) || (can? :close, room)
              info[:close_url] = bbb_room_close_path(room)
            end
          rescue BigBlueButton::BigBlueButtonException => exc
            error = { :key => 'BBB'+exc.key.capitalize, :message => exc.message }
          end
        end
      else
        error = { :key => "RoomAccessNotAllowed", :message => "Access to room with id ["+room_id.to_s+"] is not allowed"  }
      end

    rescue ActiveRecord::RecordNotFound => exc
      error = { :key => 'RoomNotFound', :message => exc.message }
    end

    status = { :info => info, :error => error}
    render :text => status.to_json(:indent => 2), :content_type => "application/json"
  end

  #delete 'bbb/room/:id', to: 'bbb#room_close', as: :bbb_room_close
  def room_close(room_id)
  end

  #get    'bbb/meetings', to: 'bbb#meeting_list'
  def meeting_list
  end

  #get    'bbb/meeting/:id', to: 'bbb#meeting_info'
  def meeting_info(meeting_id)
  end

  #delete 'bbb/meeting/:id', to: 'bbb#meeting_end'
  def meeting_end(meeting_id)
  end

  #get    'bbb/recordings/:id', to: 'bbb#recording_list'
  def recording_list(meeting_id)
  end

  #get    'bbb/recording/:id', to: 'bbb#recording_info'
  def recording_info(recording_id)
  end

  #update 'bbb/recording/:id', to: 'bbb#recording_publish'
  def recording_publish(recording_id)
  end

  #delete 'bbb/recording/:id', to: 'bbb#recording_delete'
  def recording_delete(recording_id)
  end

end
