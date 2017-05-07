module HasCollaborator
  extend ActiveSupport::Concern

  def add_collaborators(entities, type, state)
    time = Time.zone.now
    Array(entities).each do |entity|
      collabs = collaborators.find_or_initialize_by(type => entity)
      collabs.update_attributes!(state => time) unless collabs[state.to_sym]
    end
  end
end
