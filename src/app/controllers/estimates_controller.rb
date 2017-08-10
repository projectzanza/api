class EstimatesController < ApplicationController
  include Rescuable

  # TODO: no authorizathion here! fix me.
  def create
    @job = Job.find(params[:job_id])
    @user = User.find(params[:user_id])

    @job.add_collaborators(@user, :user, :interested_at).each do |collaborator|
      if collaborator.estimate
        raise ActiveRecord::RecordNotSaved, 'Cannot create a second estimate for this user/job combination'
      end
      @estimate = Estimate.create(estimate_params)
      collaborator.update_attributes!(estimate: @estimate)
    end
    render json: { data: @estimate }
  end

  def update
    @estimate = Estimate.find(params[:id])
    @estimate.update_attributes!(estimate_params)
    render json: { data: @estimate.reload }
  end

  def estimate_params
    params.permit(
      :days,
      :start_at,
      :end_at,
      :per_diem,
      :total
    ).to_h
  end
end
