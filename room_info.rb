class RoomInfo
  attr_accessor :server, :apptag, :appid, :join_as, :room_id
  
  def initialize(json_str)
    json = JSON.parse(json_str)
    @server = json["server"]
    @apptag = json["apptag"]
    @appid = json["appid"]
    @join_as = json["joinAs"]
    @room_id = json["roomid"]
  end
end
