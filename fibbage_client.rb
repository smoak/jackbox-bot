class FibbageClient < JackboxClient
  SEND_MESSAGE_TO_ROOM_OWNER = "SendMessageToRoomOwner"

  def on_customer_blob_changed(blob)
    if blob["state"] == "Gameplay_CategorySelection" && blob["isChoosing"]
      puts "Choosing category"
      sleep(2)
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { 'chosenCategory' => 0 }))
    end
    if blob["state"] == "Gameplay_EnterLie"
      puts "Entering a lie"
      sleep(2)
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { "lieEntered": "FIXME", "usedSuggestion": false }))
    end
    if blob["state"] == "Gameplay_ChooseLie" && !blob["choosingDone"] && !blob["chosen"]
      puts "Choosing lie"
      sleep(2)
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { choice: blob["choices"].first }))
    end
  end

  def on_room_blob_changed(blob)
  end
end
