class AccessPolicy
  include AccessGranted::Policy

  def configure
    # Example policy for AccessGranted.
    # For more details check the README at
    #
    # https://github.com/chaps-io/access-granted/blob/master/README.md

    role :member, ->(user) { user.confirmed? } do
      job_policy
      estimate_policy
      position_policy
      scope_policy
      user_policy
      review_policy
    end
  end
end

def job_policy
  can %i[create list read], Job
  can %i[update destroy verify], Job do |job, user|
    job.user == user
  end
  can %i[register_interest accept complete], Job do |job, user|
    job.user != user
  end
end

def estimate_policy
  can %i[create list read], Estimate
  can %i[update destroy], Estimate do |estimate, user|
    estimate.user == user
  end
  can %i[accept reject], Estimate do |estimate, user|
    user.jobs.include? estimate.job
  end
end

def position_policy
  can %i[create list], Position
  can %i[update destroy], Position do |position, user|
    position.user == user
  end
end

def scope_policy
  can %i[create list], Scope
  can %i[complete], Scope do |scope, user|
    [scope.job.user, scope.job.accepted_user].include? user
  end
  can %i[update reject verify destroy], Scope do |scope, user|
    scope.job.user == user
  end
end

def user_policy
  can %i[read list], User
  can %i[update], User do |user, current_user|
    user == current_user
  end
  can %i[invite award reject], User do |user, current_user|
    user != current_user
  end
end

def review_policy
  can :list, Review
  can :create, Review do |review, user|
    [review.job.accepted_user, review.job.user].include?(user) &&
      review.job.state == 'verified'
  end
  can :update, Review do |review, user|
    review.user = user
  end
end
