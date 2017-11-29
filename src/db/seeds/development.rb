User.create([
              {
                name: 'dev dev',
                email: 'dev@zanza.com',
                headline: 'Dev dev dev, security, security, security',
                summary: 'summary of the summary of a summary of a summary',
                tag_list: %w[ruby javascript docker grunt webpack java apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 500 },
                country: 'IE',
                city: 'dublin',
                onsite: true
              },
              {
                name: 'Sophia Smith',
                email: 'sophia.smith@zanza.com',
                summary: 'Sophias bio',
                tag_list: %w[ruby javascript docker grunt webpack],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 1000 },
                country: 'IE',
                city: 'dublin',
                onsite: true
              },
              {
                name: 'Aiden Jones',
                email: 'aiden.jones@zanza.com',
                summary: 'Aidens bio',
                tag_list: %w[ruby javascript docker grunt apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 200, max: 500 },
                country: 'IE',
                city: 'dublin',
                onsite: true
              },
              {
                name: 'Emma Williams',
                email: 'emma.williams@zanza.com',
                summary: 'Emmas bio',
                tag_list: %w[ruby javascript docker],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 600 },
                country: 'IE',
                city: 'dublin',
                onsite: true
              },
              {
                name: 'Jackson Taylor',
                email: 'jackson.taylorh@zanza.com',
                summary: 'Jacksons bio',
                tag_list: %w[docker grunt webpack],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 },
                country: 'AU',
                city: 'melbourne',
                onsite: true
              },
              {
                name: 'Liam Neeson',
                email: 'liam.neeson@zanza.com',
                summary: 'Liams bio',
                tag_list: %w[docker grunt webpack ruby apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 },
                country: 'AU',
                city: 'melbourne',
                onsite: true
              },
              {
                name: 'Taylor Swift',
                email: 'taylor.swift@zanza.com',
                summary: 'Taylors bio',
                tag_list: %w[security physical],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 },
                country: 'AU',
                city: 'melbourne',
                onsite: true
              }
            ])
User.all.each do |user|
  UserCreateService.new(user).call
end

Position.create([
                  {
                    title: 'Queen of pop',
                    summary: 'singing about stuff n stuff',
                    company: 'Swift Inc',
                    start_at: Time.zone.now - 1.years,
                    end_at: Time.zone.now - 4.months,
                    user: User.find_by(email: 'taylor.swift@zanza.com')
                  },
                  {
                    title: 'Country and western',
                    summary: 'just singing a few songs',
                    company: 'canada',
                    start_at: Time.zone.now - 4.months,
                    end_at: Time.zone.now - 1.months,
                    user: User.find_by(email: 'taylor.swift@zanza.com')
                  }
                ])
Position.create([
                  {
                    title: 'Security consultant',
                    summary: 'consultant for security, exactly what is says on the tin',
                    company: 'The Company',
                    start_at: Time.zone.now - 1.years,
                    end_at: Time.zone.now - 4.months,
                    user: User.find_by(email: 'dev@zanza.com')
                  },
                  {
                    title: 'Overseer of Light',
                    summary: 'staring at the eclipse',
                    company: 'The White House',
                    start_at: Time.zone.now - 4.months,
                    end_at: Time.zone.now - 1.months,
                    user: User.find_by(email: 'dev@zanza.com')
                  }
                ])

jcs = JobCreateService.new(
  User.find_by(email: 'dev@zanza.com'),
  title: 'Ruby development',
  text: 'Develop ruby to save the world.
2 invited users, 2 interested users and 2 scopes',
  user: User.find_by(email: 'dev@zanza.com'),
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby docker],
  proposed_start_at: Time.zone.now,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true,
  scopes: [
    Scope.create(
      title: 'start ruby on rails project',
      description: 'like a train wreck'
    ),
    Scope.create(
      title: 'save the world',
      description: 'its a 2 step job only'
    )
  ]
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'aiden.jones@zanza.com')).call(:invite)
CollaboratorStateService.new(jcs.job, User.find_by(email: 'emma.williams@zanza.com')).call(:invite)
CollaboratorStateService.new(jcs.job, User.find_by(email: 'jackson.taylorh@zanza.com')).call(:interested)
CollaboratorStateService.new(jcs.job, User.find_by(email: 'sophia.smith@zanza.com')).call(:interested)

Estimate.create(
  days: 2,
  start_at: Time.zone.now + 5.days,
  end_at: Time.zone.now + 7.days,
  per_diem: 200,
  total: 400,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'jackson.taylorh@zanza.com').id
)

Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1200,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)
Estimate.create(
  days: 5,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 12.days,
  per_diem: 300,
  total: 1500,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)

jcs = JobCreateService.new(
  User.find_by(email: 'dev@zanza.com'),
  title: 'Docker project',
  text: 'Develop docker to make pigs fly',
  per_diem: { min: 300, max: 400 },
  tag_list: ['docker'],
  proposed_start_at: Time.zone.now + 1.day,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'jackson.taylorh@zanza.com')).call(:interested)
CollaboratorStateService.new(jcs.job, User.find_by(email: 'sophia.smith@zanza.com')).call(:interested)

Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1200,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)

jcs = JobCreateService.new(
  User.find_by(email: 'dev@zanza.com'),
  title: 'Javascript fluff',
  text: 'Copy and paste javascript from stackoverflow until it works',
  per_diem: { min: 800, max: 1000 },
  tag_list: %w[javascript grunt webpack],
  proposed_start_at: Time.zone.now + 1.day,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'jackson.taylorh@zanza.com')).call(:interested)
CollaboratorStateService.new(jcs.job, User.find_by(email: 'sophia.smith@zanza.com')).call(:interested)

Estimate.create(
  days: 2,
  start_at: Time.zone.now + 5.days,
  end_at: Time.zone.now + 7.days,
  per_diem: 200,
  total: 400,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'jackson.taylorh@zanza.com').id
)
jcs = JobCreateService.new(
  User.find_by(email: 'taylor.swift@zanza.com'),
  title: 'Apache Security Consulting',
  text: 'security consulting for apache server',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[docker javascript grunt apache],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'dev@zanza.com')).call(:invite)

jcs = JobCreateService.new(
  User.find_by(email: 'taylor.swift@zanza.com'),
  title: 'Bank physical security review',
  text: 'physical review of security for unicorns
  has scopes. invited and awarded to dev@zanza.com',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[security physical camera],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true,
  scopes: [
    Scope.create(
      title: 'find a bank to break into',
      description: 'there are loads of them around'
    ),
    Scope.create(
      title: 'take them for all they are worth',
      description: '1 million dollars (approx)'
    )
  ]
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'dev@zanza.com')).call(:award)

Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1600,
  job_id: jcs.job.id,
  user_id: User.find_by(email: 'dev@zanza.com').id
)

jcs = JobCreateService.new(
  User.find_by(email: 'taylor.swift@zanza.com'),
  title: 'Flash development',
  text: 'for Internet Explorer 4',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[security physical camera],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)
jcs.call

CollaboratorStateService.new(jcs.job, User.find_by(email: 'dev@zanza.com')).call(:interested)

JobCreateService.new(
  User.find_by(email: 'dev@zanza.com'),
  title: 'develop securely',
  text: 'Dont leak all our info into the wild. But no one matches this job description!',
  per_diem: { min: 800, max: 1000 },
  tag_list: ['security'],
  proposed_start_at: Time.zone.now + 1.day,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
JobCreateService.new(
  User.find_by(email: 'sophia.smith@zanza.com'),
  title: 'Killer app',
  text: 'Literally, not figuratively',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby javascript],
  proposed_start_at: Time.zone.now + 1.day,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
JobCreateService.new(
  User.find_by(email: 'aiden.jones@zanza.com'),

  title: 'Python project',
  text: 'Actualy snake handling abilities is a bonus',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[docker python javascript],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)

JobCreateService.new(
  User.find_by(email: 'sophia.smith@zanza.com'),
  title: 'Java development',
  text: 'You will need boxing gloves to type, and an editor to fix all your mistakes',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby javascript docker grunt webpack java],
  proposed_start_at: Time.zone.now,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
JobCreateService.new(
  User.find_by(email: 'sophia.smith@zanza.com'),
  title: 'Just one small job',
  text: 'It will not explode out into 100 more small jobs, promise',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby javascript docker grunt],
  proposed_start_at: Time.zone.now,
  proposed_end_at: Time.zone.now + 3.day,
  allow_contact: true
)
JobCreateService.new(
  User.find_by(email: 'sophia.smith@zanza.com'),
  title: 'Sitting around doing nothing',
  text: 'It is hard work but someone has gotta drag everyone else down',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby docker javascript grunt],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)

JobCreateService.new(
  User.find_by(email: 'taylor.swift@zanza.com'),
  title: 'Android security review',
  text: 'Android jellybean review (orange flavour)',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby javascript docker grunt webpack java apache],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)

jcs = JobCreateService.new(
  User.find_by(email: 'taylor.swift@zanza.com'),
  title: 'Accepted by Dev - Docker, ruby and javascript development',
  text: 'Huge multi million euro platform',
  per_diem: { min: 100, max: 1000 },
  tag_list: %w[ruby javascript docker grunt webpack java apache],
  proposed_start_at: Time.zone.now + 10.day,
  proposed_end_at: Time.zone.now + 13.day,
  allow_contact: true
)
jcs.call

css = CollaboratorStateService.new(jcs.job, User.find_by(email: 'dev@zanza.com'))
css.call(:award)
css.call(:accept)
JobService.new(jcs.job).verify
