module HasCollaborator
  extend ActiveSupport::Concern

  def add_collaborators(entities, type, state)
    time = Time.zone.now
    Array(entities).each do |entity|
      collaborators.find_or_initialize_by(type => entity).update_attributes!(state => time)
    end
  end
end
