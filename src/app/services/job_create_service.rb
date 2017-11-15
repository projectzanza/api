require_relative '../../lib/zanza/rocket_chat.rb'

class JobCreateService
  attr_accessor :job

  def initialize(current_user, job_params)
    @job = Job.new(job_params)
    @current_user = current_user
  end

  def call
    @current_user.jobs << @job
    @job.chat_room_id = create_chat_room.id
    @job.save!
  end

  def create_chat_room
    session = Zanza::RocketChat.login(@current_user)
    room = session.groups.create(
      Zanza::RocketChat.chat_title(@job),
      members: [@current_user.nickname]
    )
    session.groups.set_attr(
      room_id: room.id,
      topic: @job.title,
      description: @job.text,
      purpose: 'General notifications for all collaborators of this job'
    )
    room
  end
end
