User.create([
              {
                name: 'dev dev',
                email: 'dev@zanza.com',
                bio: 'dev bio',
                tag_list: %w(ruby javascript docker grunt webpack),
                password: '123123123',
                confirmed_at: Time.zone.now
              },
              {
                name: 'Sophia Smith',
                email: 'sophia.smith@zanza.com',
                bio: 'Sophias bio',
                tag_list: %w(ruby javascript docker grunt webpack),
                password: '123123123',
                confirmed_at: Time.zone.now
              },
              {
                name: 'Aiden Jones',
                email: 'aiden.jones@zanza.com',
                bio: 'Aidens bio',
                tag_list: %w(ruby javascript docker grunt),
                password: '123123123',
                confirmed_at: Time.zone.now
              },
              {
                name: 'Emma Williams',
                email: 'emma.williams@zanza.com',
                bio: 'Emmas bio',
                tag_list: %w(ruby javascript docker),
                password: '123123123',
                confirmed_at: Time.zone.now
              },
              {
                name: 'Jackson Taylor',
                email: 'jackson.taylorh@zanza.com',
                bio: 'Jacksons bio',
                tag_list: %w(docker grunt webpack),
                password: '123123123',
                confirmed_at: Time.zone.now
              }
            ])

Job.create([
             {
               title: 'Ruby development',
               text: 'Develop ruby to save the world',
               user: User.find_by(email: 'dev@zanza.com'),
               per_diem: { min: 100, max: 1000 },
               tag_list: %w(ruby docker)
             },
             {
               title: 'Docker project',
               text: 'Develop docker to make pigs fly',
               user: User.find_by(email: 'dev@zanza.com'),
               per_diem: { min: 300, max: 400 },
               tag_list: ['docker']
             },
             {
               title: 'Javascript fluff',
               text: 'Copy and paste javascript from stackoverflow until it works',
               user: User.find_by(email: 'dev@zanza.com'),
               per_diem: { min: 800, max: 1000 },
               tag_list: %w(javascript grunt webpack)
             },
             {
               title: 'develop securely',
               text: 'Dont leak all our info into the wild. But no one matches this job description!',
               user: User.find_by(email: 'dev@zanza.com'),
               per_diem: { min: 800, max: 1000 },
               tag_list: ['security']
             },
             {
               title: 'Killer app',
               text: 'Literally, not figuratively',
               user: User.find_by(email: 'sophia.smith@zanza.com'),
               per_diem: { min: 100, max: 1000 },
               tag_list: %w(ruby javascript)
             },
             {
               title: 'Python project',
               text: 'Actualy snake handling abilities is a bonus',
               user: User.find_by(email: 'aiden.jones@zanza.com'),
               per_diem: { min: 100, max: 1000 },
               tag_list: %w(docker python javascript)
             }
           ])
