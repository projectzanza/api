class JobService
  def initialize(job)
    @job = job
  end

  def complete
    @job.complete
    JobMailer.client_email(@job).deliver_now
  end

  def verify
    @job.verify
    JobMailer.consultant_email(@job).deliver_now
  end
end
