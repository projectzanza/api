# API

### Dependencies

  - docker ^1.13
  - docker-compose ^1.11
  
### To run

```
docker-compose build
docker-compose up
curl 127.0.0.1:3000
```

### To access the api container console
```
./scripts/api-console

# run tests
rake spec
# start the server
startup-dev.sh
```


### Confirmation emails in development mode

A mail server `mailcatcher` is set up under the `mail_server` container
Rails Development will send emails over smtp to `mail_server:7025`, 
and they can be viewed by pointing your browser to `http://127.0.0.1:7080`
Useful for viewing signup emails
In production, stmp settings will be set via ENV variables

### Manually posting data to an API

Use your favourite tool, `postman` is a chrome extension that will post data easily
Try posting: 
```
127.0.0.1:3000/auth?email=test@zanza.com&password=123123123&password_confirmation=123123123
```

Then goto `http://127.0.0.1:7080` to see the confirmation email
