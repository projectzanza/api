class UserMatchingService
  attr_accessor :users

  def initialize(job, filters)
    @job = job
    @filters = filters
  end

  def match_users
    @job.interested_users.union_all(User.tagged_with(@job.tag_list)) - @job.default_collaborating_users
  end

  def call
    if @filters && @filters[:save]
      @filters.delete(:save)
      @job.update!(consultant_filter: @filters)
    end
    @users = match_users
  end
end
