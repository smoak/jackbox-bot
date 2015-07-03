class JackboxClient
  attr_reader :room_info, :user_id, :ws_url, :ws, :room_state, :customer_state

  CONNECT = 0
  JOIN = 1
  PING = 2
  EVENT = 5
  EVENT_MESSAGE = "Event"
  ROOM_BLOB_CHANGED = "RoomBlobChanged"
  CUSTOMER_BLOB_CHANGED = "CustomerBlobChanged"
  ROOM_DESTROYED = "RoomDestroyed"
  SEND_MESSAGE_TO_ROOM_OWNER = "SendMessageToRoomOwner"
  RESULT_MESSAGE = "Result"
  JOIN_ROOM = "JoinRoom"

  def initialize(room_info, user_id, ws_url)
    @room_info = room_info
    @user_id = user_id
    @ws_url = ws_url
    @room_blob = ""
    @customer_blob = ""
  end

  def run!
    @ws = Faye::WebSocket::Client.new(ws_url)
    ws.on :message do |event|
      next unless event.data =~ /^\d+/
      code, body = event.data.scan(/^(\d+):{2,3}(.*)$/).first
      code = code.to_i
      on_message(code, body)
    end
    ws.on :close do |event|
      @ws = nil
    end
  end

  protected

  def join_room
    send(create_action_packet("JoinRoom",
                              name: "RANDO",
                              "joinType" => room_info.join_as))
  end

  def on_message(code, body)
    case code
    when PING
      puts "Got ping"
      send_pong
    when JOIN
      join_room
    when EVENT
      args = JSON.parse(body)["args"]
      args.each { |arg| on_data_received(arg) }
    end
  end

  def send(packet)
    msg = {
      name: "msg",
      args: [packet]
    }.to_json
    puts "Sending #{msg}"
    ws.send("5:::#{msg}")
  end

  def create_action_packet(action, data)
    {
      "type" => "Action",
      "appId" => room_info.appid,
      "userId" => user_id,
      "roomId" => room_info.room_id,
      "action" => action
    }.merge(data)
  end

  private

  def on_data_received(data)
    puts "on_data_received: #{data}"
    on_event_received(data) if data["type"] == EVENT_MESSAGE
    on_result_received(data) if data["type"] == RESULT_MESSAGE
  end

  def on_event_received(data)
    event = data["event"]
    on_customer_blob_changed(data["blob"]) if event == CUSTOMER_BLOB_CHANGED
    on_room_blob_changed(data["blob"]) if event == ROOM_BLOB_CHANGED
    EventMachine::stop_event_loop if event == ROOM_DESTROYED
  end

  def on_result_received(data)
    puts "on_result_received: #{data}"
    action = data["action"]
    on_joined if action == JOIN_ROOM && data["success"] && data["initial"]
  end

  def on_customer_blob_changed(blob)
    @customer_blob = blob
  end

  def on_room_blob_changed(blob)
    @room_blob = blob
  end

  def on_joined
  end

  def send_pong
    puts "Sending pong"
    ws.send("2::")
  end
end
