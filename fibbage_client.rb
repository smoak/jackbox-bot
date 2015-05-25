class FibbageClient < JackboxClient


  protected
  
  def on_jackbox_message(message_args)
    message_args.each do |arg|
      arg_type = arg["type"]
      process_event(arg) if arg_type == EVENT_MESSAGE
    end
  end

  private

  def process_event(arg)
    case arg["event"]
    when "RoomBlobChanged"
      room_state.update(arg["state"], arg["blob"])
    when "CustomerBlobChanged"
      customer_state.update(arg["state"], arg["blob"])
    end
  end
end
