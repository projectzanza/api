class JobMailer < ApplicationMailer
  def client_email(job)
    @client = job.user
    @consultant = job.accepted_user
    @state = job.state
    @job = job
    mail(to: @client.email, subject: "State Change - #{@state}")
  end

  def consultant_email(job)
    @client = job.user
    @consultant = job.accepted_user
    @state = job.state
    @job = job
    mail(to: @consultant.email, subject: "State Change - #{@state}")
  end
end
