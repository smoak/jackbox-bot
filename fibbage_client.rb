class FibbageClient < JackboxClient

  def on_customer_blob_changed(blob)
    super(blob)

    if blob["state"] == "Gameplay_CategorySelection" && blob["isChoosing"]
      puts "Choosing category"
      sleep(2)
      choices = @room_blob["choices"]
      chosen_category = choices.index(choices.sample)
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { 'chosenCategory' => chosen_category }))
    end
    if blob["state"] == "Gameplay_EnterLie"
      puts "Entering a lie"
      sleep(2)
      lie = @customer_blob["suggestions"].sample
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { "lieEntered": lie, "usedSuggestion": false }))
    end
    if blob["state"] == "Gameplay_ChooseLie" && !blob["choosingDone"] && !blob["chosen"]
      puts "Choosing lie"
      sleep(2)
      choice = blob["choices"].sample
      send(create_action_packet(SEND_MESSAGE_TO_ROOM_OWNER,
                                message: { choice: choice }))
    end
  end
end
