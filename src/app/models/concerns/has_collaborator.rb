module HasCollaborator
  extend ActiveSupport::Concern

  def add_collaborators(entities, type, state)
    time = Time.zone.now
    Array(entities).collect do |entity|
      collab = collaborators.find_or_initialize_by(type => entity)
      collab.update!(state => time) unless collab[state.to_sym]
      collab
    end
  end
end
