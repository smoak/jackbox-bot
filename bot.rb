require 'logger'
require 'securerandom'
require_relative 'room_info'
require_relative 'jackbox_client'
require_relative 'fibbage_client'
require_relative 'customer_state'
require_relative 'room_state'
require 'bundler'
Bundler.require

class Bot

  ROOM_INFO_URL = "http://blobcast.jackboxgames.com/room/%{room_id}/?userId=%{user_id}"
  CLIENTS = {
    "fibbage" => FibbageClient
  }

  attr_accessor :room_id, :user_id, :logger

  def initialize(room_id)
    @room_id = room_id
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @user_id = SecureRandom.uuid
  end

  def run!
    room_info = get_room_info
    web_socket_url = get_websocket_url(room_info)

    client = CLIENTS[room_info.apptag.to_s].new(room_info, user_id, web_socket_url)

    # here is our "main" bot thread
    EM.run {
      client.run!
    }
  end

  private
  def get_room_info
    response = HTTParty.get(ROOM_INFO_URL % { room_id: room_id, user_id: user_id }, logger: logger)
    RoomInfo.new(response.body)
  end

  def get_websocket_url(room_info)
    now = Time.now.utc
    response = HTTParty.get("http://#{room_info.server}:38202/socket.io/1/?t=#{now}", logger: logger)
    unknown = response.body.split(':').first
    "ws://#{room_info.server}:38202/socket.io/1/websocket/#{unknown}"
  end

end

room_id = ENV['JACKBOX_ROOMID']
Bot.new(room_id).run!
