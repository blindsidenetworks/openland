module BbbHelper
  def broker_join_url room_id
    root_path+'bbb/join/'+room_id.to_s
  end
end
