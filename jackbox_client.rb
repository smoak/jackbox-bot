class JackboxClient
  attr_reader :room_info, :user_id, :ws_url, :ws, :room_state, :customer_state

  PING = "2::"
  EVENT = "5::"
  EVENT_MESSAGE = "Event"

  def initialize(room_info, user_id, ws_url)
    @room_info = room_info
    @user_id = user_id
    @ws_url = ws_url
    @room_state = RoomState.new
    @customer_state = CustomerState.new
  end

  def run!
    @ws = Faye::WebSocket::Client.new(ws_url)
    ws.on :message do |event|
      on_message(event)
    end
    ws.on :close do |event|
      @ws = nil
    end
  end

  def emit_event(event)
    ws.send("5:::#{event}")
  end

  protected

  def join_room
    join = {
      name: "msg",
      args: [{
        "roomId" => room_info.room_id,
        "name" => "RANDO", # FIXME: allow this to be configurable
        "appId" => room_info.appid,
        "joinType" => room_info.join_as,
        "type" => "Action",
        "userId" => user_id,
        "action" => "JoinRoom"
      }]
    }.to_json
    emit_event(join)
  end

  def on_message(event)
    puts "Received message: #{event.data}"
    case event.data[0,3]
    when "1::"
      join_room
    when PING
      pong
    when EVENT
      message_args = JSON.parse(event.data[4..-1])["args"]
      on_jackbox_message(message_args) 
      process_state
    end
  end

  def process_state
    if customer_state.category_selection? && customer_state.choosing?
      # pick a random choice from the list
      category = room_state.pick_random_category
      choose_category(category)
    end
  end

  private

  def pong
    ws.send(PING)
  end

  def choose_category(category)
    # 5:::{"name":"msg","args":[{"roomId":"VNFU","userId":"c29d7669-cff5-459b-ab15-c0a91e4433d7","message":{"chosenCategory":4},"type":"Action","appId":"3Mcei9GjIFpBUGwhQRtHRyGQpQUYoJfy","action":"SendMessageToRoomOwner"}]}
    event = {
      name: "msg",
      args: [{
        "roomId" => room_info.room_id,
        "userId" => user_id,
        "message" => { "chosenCategory" => category },
        "type" => "Action",
        "appId" => room_info.appid,
        "action" => "SendMessageToRoomOwner"
      }]
    }.to_json
    emit_event(event)
  end
end
