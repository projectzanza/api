class CollaboratorStateService
  attr_reader :collaborator

  def initialize(job, user)
    raise ArgumentError unless [job, user].compact.length == 2

    @job = job
    @user = user
    @collaborator = Collaborator.find_or_initialize_by(job: @job, user: @user)
  end

  def call(new_state)
    @collaborator.send("#{new_state}!")
    case new_state
    when :interested, :accept
      CollaboratorMailer.client_email(@collaborator).deliver_now
    when :invite
      invite_collaborator_to_chat
      CollaboratorMailer.consultant_email(@collaborator).deliver_now
    when :award
      CollaboratorMailer.consultant_email(@collaborator).deliver_now
    when :reject
      kick_collaborator_from_chat
      CollaboratorMailer.consultant_email(@collaborator).deliver_now
    end
  end

  def invite_collaborator_to_chat
    session = Zanza::RocketChat.login(@job.user)
    session.groups.invite(
      room_id: @job.chat_room_id,
      username: @collaborator.user.nickname
    )
  end

  def kick_collaborator_from_chat
    session = Zanza::RocketChat.login(@job.user)
    session.groups.kick(
      room_id: @job.chat_room_id,
      username: @collaborator.user.nickname
    )
  end

  def transition?(new_state)
    @collaborator.send("can_#{new_state}?")
  end
end
