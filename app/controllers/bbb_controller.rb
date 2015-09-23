require 'bigbluebutton_api'
require 'digest/sha1'

class BbbController < ApplicationController
  include ApplicationHelper

  def enter
    error = nil

    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)
      if (can? :read, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
        if !bbb
          error = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s

          #See if the meeting is running
          begin
            bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
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
    room_data = nil
    meeting_data = nil
    error_data = nil

    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)
      if (can? :read, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
        if !bbb
          error_data = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s

          #Set room information based on permissions
          room_data = {}
          room_data[:can_use] = (can? :use, room)
          room_data[:can_close] = (can? :manage, room) || (can? :close, room)

          #See if the meeting is running
          begin
            bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
            #remove sensible information
            meeting_data = {}
            meeting_data[:running] = bbb_meeting_info[:running]
            meeting_data[:startTime] = bbb_meeting_info[:startTime]
            meeting_data[:endTime] = bbb_meeting_info[:endTime]
            meeting_data[:participantCount] = bbb_meeting_info[:participantCount]
            meeting_data[:listenerCount] = bbb_meeting_info[:listenerCount]
            meeting_data[:moderatorCount] = bbb_meeting_info[:moderatorCount]
          rescue BigBlueButton::BigBlueButtonException => exc
            error_data = { :key => 'BBB'+exc.key.capitalize, :message => exc.message }
          end
        end
      else
        error_data = { :key => "RoomAccessNotAllowed", :message => "Access to room with id ["+room_id.to_s+"] is not allowed"  }
      end

    rescue ActiveRecord::RecordNotFound => exc
      error_data = { :key => 'RoomNotFound', :message => exc.message }
    end

    status = { :room => room_data, :meeting => meeting_data, :error => error_data}
    render :text => status.to_json(:indent => 2), :content_type => "application/json"
  end

  #delete 'bbb/room/:id', to: 'bbb#room_close', as: :bbb_room_close
  def room_close
    error_data = nil

    logger.info "EXECUTING CLOSE"
    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)

      if (can? :close, room)
        bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
        if !bbb
          error_data = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
        else
          meeting_id = (Digest::SHA1.hexdigest request.host+room.user_id.to_s+room.id.to_s).to_s
          # Get meeting info in order to have access to the moderator password
          begin
            bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
            if bbb_meeting_info[:running]
              bbb.end_meeting(meeting_id, bbb_meeting_info[:moderatorPW])
            end

          rescue BigBlueButton::BigBlueButtonException => exc
            error_data = { :key => 'BBB'+exc.key.capitalize, :message => exc.message }
          end

        end
      end

    rescue ActiveRecord::RecordNotFound => exc
      error_data = { :key => 'RoomNotFound', :message => exc.message }
    end

    status = {:error => error_data}
    render :text => status.to_json(:indent => 2), :content_type => "application/json"

  end

  #get    'bbb/meetings', to: 'bbb#meeting_list'
  def meeting_list
  end

  #get    'bbb/meeting/:id', to: 'bbb#meeting_info'
  def meeting_info
    meeting_id = params[:id].to_i
  end

  #delete 'bbb/meeting/:id', to: 'bbb#meeting_end'
  def meeting_end
    meeting_id = params[:id].to_i
  end

  #get    'bbb/recordings/:id', to: 'bbb#recording_list'
  def recording_list
    meeting_id = params[:id].to_i
  end

  #get    'bbb/recording/:id', to: 'bbb#recording_info'
  def recording_info
    recording_id = params[:id].to_i
  end

  #update 'bbb/recording/:id', to: 'bbb#recording_publish'
  def recording_publish
    recording_id = params[:id].to_i
  end

  #delete 'bbb/recording/:id', to: 'bbb#recording_delete'
  def recording_delete
    recording_id = params[:id].to_i
  end

end
