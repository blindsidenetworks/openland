module BbbHelper
  def broker_join_url room_id
    url = nil
    if user_signed_in?
      url = root_path+'bbb/join/'+room_id.to_s
      logger.info root_path
      logger.info url
    end

    return url
  end
end
