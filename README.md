# API

### Dependencies

  - docker ^1.13
  - docker-compose ^1.11
  
## To run for demo purposes

```
docker-compose build
docker-compose up
curl 127.0.0.1:3000
```

## To run for development purposes

### To access the api container console
```
cd zanza/app
./scripts/api-console

# run tests
rake spec
# drop everything then create db, tables and seed it with dev data, 
# or reset the DB at any time
rake db:reset
# start the server, will not seed data into the DB on first run
startup-dev.sh
```

### Seed data
Seed data is set in api/src/db/seeds/[environment].rb
Your default login is dev@zanza.com/123123123, other users are set up
with tags and jobs. Running `rake db:reset` will set the database back to
the original schema and seed data

### Run the frontend app
It's quicker to run the frontend from local machine instead of docker,
as watching files change on a mounted docker volume is extremely slow (10x so)
```
cd zanza/app
npm install

# run tests
npm run test
# run standalone lint, and auto fix errors
npm run lint
# run frontend dev server 
npm run build:watch
```


### Confirmation emails in development mode

A mail server `mailcatcher` is set up under the `mail_server` container
Rails Development will send emails over smtp to `mail_server:7025`, 
and they can be viewed by pointing your browser to `http://0.0.0.0:7080`
Useful for viewing signup emails
In production, stmp settings will be set via ENV variables

### Manually posting data to an API

Use your favourite tool, `postman` is a chrome extension that will post data easily
Try posting: 
```
127.0.0.1:3000/auth?email=test@zanza.com&password=123123123&password_confirmation=123123123
```

Then goto `http://127.0.0.1:7080` to see the confirmation email
