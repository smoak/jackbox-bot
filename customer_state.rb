class CustomerState
  attr_reader :state, :blob

  def update(state, blob)
    @state = state
    @blob = blob
  end

  def category_selection?
    state == "Gameplay_CategorySelection"
  end

  def choosing?
    blob["isChoosing"]
  end
end
