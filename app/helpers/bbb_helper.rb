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
end
