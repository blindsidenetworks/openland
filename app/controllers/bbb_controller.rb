require 'bigbluebutton_api'
require 'digest/sha1'

class BbbController < ApplicationController
  BBB_ENDPOINT = 'http://test-install.blindsidenetworks.com/bigbluebutton/'
  BBB_SECRET = '8cd8ef52e8e101574e400365b55e11a6'

  def join
    @bbb_endpoint = BBB_ENDPOINT
    @bbb_secret = BBB_SECRET
    bbb ||= BigBlueButton::BigBlueButtonApi.new(@bbb_endpoint + "api", @bbb_secret, "0.8", true)

    if !bbb
      error = { :key => "BBBAPICallInvalid", :message => "BBB API call invalid." }
    else
      room = Room.find(params[:id])
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
      if current_user.id == room.user_id
         password = meeting_info[:moderatorPW]
         #user_name = 'Moderator'
      else
         password = meeting_info[:attendeePW]
         #user_name = 'Viewer'
      end
      user_name = current_user.username
      join_url = bbb.join_meeting_url(meeting_id, user_name, password)

      #Execute the redirect
      redirect_to join_url

      #render plain: current_user.inspect + '*************************' + room.inspect
    end
  end

  def close
  end
end
