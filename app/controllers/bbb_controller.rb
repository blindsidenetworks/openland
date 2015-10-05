class BbbController < ApplicationController
  include ApplicationHelper
  include BbbHelper
  protect_from_forgery with: :null_session

  def enter
    error = nil
    logger.info "**********************************************"
    logger.info params.inspect

    room_id = params[:id].to_i
    begin
      room = Room.find(room_id)
      bbb_meeting_join_url = bbb_get_meeting_join_url room
      if bbb_meeting_join_url[:returncode]
        #Execute the redirect
        logger.info "#Execute the redirect"
        redirect_to bbb_meeting_join_url[:join_url]
      else
        error = { :key => bbb_meeting_join_url[:messageKey], :message => bbb_meeting_join_url[:message] }
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
      #Set room information based on permissions
      room_data = {}
      room_data[:can_use] = (can? :use, room)
      room_data[:can_close] = (can? :manage, room) || (can? :close, room)
      room_data[:user_signed_in] = (user_signed_in?)

      bbb_meeting_info = bbb_get_meeting_info room
      if bbb_meeting_info[:returncode]
        #remove sensitive information
        meeting_data = {}
        meeting_data[:running] = bbb_meeting_info[:meeting_info][:running]
        meeting_data[:startTime] = bbb_meeting_info[:meeting_info][:startTime]
        meeting_data[:endTime] = bbb_meeting_info[:meeting_info][:endTime]
        meeting_data[:participantCount] = bbb_meeting_info[:meeting_info][:participantCount]
        meeting_data[:listenerCount] = bbb_meeting_info[:meeting_info][:listenerCount]
        meeting_data[:moderatorCount] = bbb_meeting_info[:meeting_info][:moderatorCount]
      else
        error_data = { :key => bbb_meeting_info[:messageKey], :message => bbb_meeting_info[:message] }
      end

    rescue ActiveRecord::RecordNotFound => exc
      error_data = { :key => 'RoomNotFound', :message => exc.message }
    end

    status = { :room => room_data, :meeting => meeting_data, :error => error_data}
    render :text => status.to_json(:indent => 2), :content_type => "application/json"
  end

  def room_close
    error_data = nil

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
