class RoomState
  attr_reader :blob, :state

  def update(state, blob)
    @state = state
    @blob = blob
  end

  def pick_random_category
    rand(blob["choices"].length)
  end
end
