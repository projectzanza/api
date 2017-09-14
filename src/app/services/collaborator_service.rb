class CollaboratorService
  attr_reader :collaborator

  def initialize(job, user)
    raise ArgumentError unless [job, user].compact.length == 2

    @job = job
    @user = user
    @collaborator = Collaborator.find_or_initialize_by(job: @job, user: @user)
  end

  def event=(new_state)
    @collaborator.send("#{new_state}!")
  end

  def transition?(new_state)
    @collaborator.send("can_#{new_state}?")
  end
end
