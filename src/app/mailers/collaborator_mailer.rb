class CollaboratorMailer < ApplicationMailer
  def client_email(collaborator)
    @client = collaborator.job.user
    @consultant = collaborator.user
    @state = collaborator.state
    @job = collaborator.job
    mail(to: @client.email, subject: "State Change - #{@state}")
  end

  def consultant_email(collaborator)
    @client = collaborator.job.user
    @consultant = collaborator.user
    @state = collaborator.state
    @job = collaborator.job
    mail(to: @consultant.email, subject: "State Change - #{@state}")
  end
end
