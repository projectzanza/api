User.create([
              {
                name: 'dev dev',
                email: 'dev@zanza.com',
                bio: 'dev bio',
                tag_list: %w[ruby javascript docker grunt webpack java apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 500 }
              },
              {
                name: 'Sophia Smith',
                email: 'sophia.smith@zanza.com',
                bio: 'Sophias bio',
                tag_list: %w[ruby javascript docker grunt webpack],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 1000 }
              },
              {
                name: 'Aiden Jones',
                email: 'aiden.jones@zanza.com',
                bio: 'Aidens bio',
                tag_list: %w[ruby javascript docker grunt apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 200, max: 500 }
              },
              {
                name: 'Emma Williams',
                email: 'emma.williams@zanza.com',
                bio: 'Emmas bio',
                tag_list: %w[ruby javascript docker],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 600 }
              },
              {
                name: 'Jackson Taylor',
                email: 'jackson.taylorh@zanza.com',
                bio: 'Jacksons bio',
                tag_list: %w[docker grunt webpack],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 }
              },
              {
                name: 'Liam Neeson',
                email: 'liam.neeson@zanza.com',
                bio: 'Liams bio',
                tag_list: %w[docker grunt webpack ruby apache],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 }
              },
              {
                name: 'Taylor Swift',
                email: 'taylor.swift@zanza.com',
                bio: 'Taylors bio',
                tag_list: %w[security physical],
                password: '123123123',
                confirmed_at: Time.zone.now,
                per_diem: { min: 400, max: 900 }
              }
            ])

job = Job.create(title: 'Ruby development',
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
                 ])
job.invite_user([
                  User.find_by(email: 'aiden.jones@zanza.com'),
                  User.find_by(email: 'emma.williams@zanza.com')
                ])
job.register_interested_users([
                                User.find_by(email: 'jackson.taylorh@zanza.com'),
                                User.find_by(email: 'sophia.smith@zanza.com')
                              ])
Estimate.create(
  days: 2,
  start_at: Time.zone.now + 5.days,
  end_at: Time.zone.now + 7.days,
  per_diem: 200,
  total: 400,
  job_id: job.id,
  user_id: User.find_by(email: 'jackson.taylorh@zanza.com').id
)

Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1200,
  job_id: job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)
Estimate.create(
  days: 5,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 12.days,
  per_diem: 300,
  total: 1500,
  job_id: job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)

job = Job.create(title: 'Docker project',
                 text: 'Develop docker to make pigs fly',
                 user: User.find_by(email: 'dev@zanza.com'),
                 per_diem: { min: 300, max: 400 },
                 tag_list: ['docker'],
                 proposed_start_at: Time.zone.now + 1.day,
                 proposed_end_at: Time.zone.now + 3.day,
                 allow_contact: true)

job.register_interested_users([
                                User.find_by(email: 'jackson.taylorh@zanza.com'),
                                User.find_by(email: 'sophia.smith@zanza.com')
                              ])
Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1200,
  job_id: job.id,
  user_id: User.find_by(email: 'sophia.smith@zanza.com').id
)

job = Job.create(title: 'Javascript fluff',
                 text: 'Copy and paste javascript from stackoverflow until it works',
                 user: User.find_by(email: 'dev@zanza.com'),
                 per_diem: { min: 800, max: 1000 },
                 tag_list: %w[javascript grunt webpack],
                 proposed_start_at: Time.zone.now + 1.day,
                 proposed_end_at: Time.zone.now + 3.day,
                 allow_contact: true)

job.register_interested_users([
                                User.find_by(email: 'jackson.taylorh@zanza.com'),
                                User.find_by(email: 'sophia.smith@zanza.com')
                              ])
Estimate.create(
  days: 2,
  start_at: Time.zone.now + 5.days,
  end_at: Time.zone.now + 7.days,
  per_diem: 200,
  total: 400,
  job_id: job.id,
  user_id: User.find_by(email: 'jackson.taylorh@zanza.com').id
)

job = Job.create(title: 'Apache Security Consulting',
                 text: 'security consulting for apache server',
                 user: User.find_by(email: 'taylor.swift@zanza.com'),
                 per_diem: { min: 100, max: 1000 },
                 tag_list: %w[docker javascript grunt apache],
                 proposed_start_at: Time.zone.now + 10.day,
                 proposed_end_at: Time.zone.now + 13.day,
                 allow_contact: true)
job.invite_user([
                  User.find_by(email: 'dev@zanza.com')
                ])

job = Job.create(title: 'Bank physical security review',
                 text: 'physical review of security for unicorns
has scopes. invited and awarded to dev@zanza.com',
                 user: User.find_by(email: 'taylor.swift@zanza.com'),
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
                 ])

job.invite_user([
                  User.find_by(email: 'dev@zanza.com')
                ])
job.award_to_user(User.find_by(email: 'dev@zanza.com'))
Estimate.create(
  days: 4,
  start_at: Time.zone.now + 9.days,
  end_at: Time.zone.now + 11.days,
  per_diem: 300,
  total: 1600,
  job_id: job.id,
  user_id: User.find_by(email: 'dev@zanza.com').id
)

job = Job.create(title: 'Flash development',
                 text: 'for Internet Explorer 4',
                 user: User.find_by(email: 'taylor.swift@zanza.com'),
                 per_diem: { min: 100, max: 1000 },
                 tag_list: %w[security physical camera],
                 proposed_start_at: Time.zone.now + 10.day,
                 proposed_end_at: Time.zone.now + 13.day,
                 allow_contact: true)
job.register_interested_users([
                                User.find_by(email: 'dev@zanza.com')
                              ])

Job.create([{
             title: 'develop securely',
             text: 'Dont leak all our info into the wild. But no one matches this job description!',
             user: User.find_by(email: 'dev@zanza.com'),
             per_diem: { min: 800, max: 1000 },
             tag_list: ['security'],
             proposed_start_at: Time.zone.now + 1.day,
             proposed_end_at: Time.zone.now + 3.day,
             allow_contact: true
           },
            {
              title: 'Killer app',
              text: 'Literally, not figuratively',
              user: User.find_by(email: 'sophia.smith@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby javascript],
              proposed_start_at: Time.zone.now + 1.day,
              proposed_end_at: Time.zone.now + 3.day,
              allow_contact: true
            },
            {
              title: 'Python project',
              text: 'Actualy snake handling abilities is a bonus',
              user: User.find_by(email: 'aiden.jones@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[docker python javascript],
              proposed_start_at: Time.zone.now + 10.day,
              proposed_end_at: Time.zone.now + 13.day,
              allow_contact: true
            },
            {
              title: 'Java development',
              text: 'You will need boxing gloves to type, and an editor to fix all your mistakes',
              user: User.find_by(email: 'sophia.smith@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby javascript docker grunt webpack java],
              proposed_start_at: Time.zone.now,
              proposed_end_at: Time.zone.now + 3.day,
              allow_contact: true
            },
            {
              title: 'Just one small job',
              text: 'It will not explode out into 100 more small jobs, promise',
              user: User.find_by(email: 'sophia.smith@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby javascript docker grunt],
              proposed_start_at: Time.zone.now,
              proposed_end_at: Time.zone.now + 3.day,
              allow_contact: true
            },
            {
              title: 'Sitting around doing nothing',
              text: 'It is hard work but someone has gotta drag everyone else down',
              user: User.find_by(email: 'sophia.smith@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby docker javascript grunt],
              proposed_start_at: Time.zone.now + 10.day,
              proposed_end_at: Time.zone.now + 13.day,
              allow_contact: true
            },
            {
              title: 'Android security review',
              text: 'Android jellybean review (orange flavour)',
              user: User.find_by(email: 'taylor.swift@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby javascript docker grunt webpack java apache],
              proposed_start_at: Time.zone.now + 10.day,
              proposed_end_at: Time.zone.now + 13.day,
              allow_contact: true
            },
            {
              title: 'Docker, ruby and javascript development',
              text: 'Huge multi million euro platform',
              user: User.find_by(email: 'taylor.swift@zanza.com'),
              per_diem: { min: 100, max: 1000 },
              tag_list: %w[ruby javascript docker grunt webpack java apache],
              proposed_start_at: Time.zone.now + 10.day,
              proposed_end_at: Time.zone.now + 13.day,
              allow_contact: true
            }])
