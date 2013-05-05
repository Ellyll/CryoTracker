class FixedBugsService
  def initialize(bugs_provider)
    @bugs = bugs_provider
  end
  def get_recently_fixed_bugs(days_within)
    raise(ArgumentError, 'days_within must be a positive non-zero integer') if (days_within.nil? || days_within <= 0)
    @bugs.all(
             :current_state_id => 3,
             :last_modified.gte => DateTime.now - days_within
            )
  end

  def get_bugs_requiring_verification
    @bugs.all(:current_state_id => 3)
  end
end