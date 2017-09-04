module HasCollaborator
  extend ActiveSupport::Concern

  def add_collaborator(state, entity)
    type = entity.keys.first
    value = entity.values.first
    collab = collaborators.find_or_initialize_by(type => value)
    collab.send(state.to_s + '!')
    collab.save!
  rescue StateMachines::InvalidTransition => e
    raise ActiveRecord::RecordNotSaved, e
  end
  alias update_collaborator add_collaborator

  def update_collaborator?(state, entity)
    type = entity.keys.first
    value = entity.values.first
    collab = collaborators.find_or_initialize_by(type => value)
    collab.send("can_#{state}?")
  end
end
