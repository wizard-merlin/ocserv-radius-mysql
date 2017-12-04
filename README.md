Bring up the services by 
```
docker-compose up
```

Run `docker-compose run radtest radtest testing password freeradius 0 testing123` to test if freeradius is working. You should see "Access-Accept" in the output.

Download and install anyconnect client.

Windows client download https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect-windows-4.4.02034.msi
mac OS client download  https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect-macos-4.4.02034.dmg
Android client download  https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect.android-4.0.05062.apk

The VPN server will be listening at `<host machine IP address>:8388`. A user is already added for testing purpose. The username is `testing`, password is `password`. Login from an AnyConnect client or OpenConnect client. When you are done testing, open freeradius/authorize and delete this user.

Then go to http://localhost:8080/ and login as root. The server is mysql. The password of root is the value of environment variable `MYSQL_ROOT_PASSWORD` in docker-compose.yml. The database has been pre-populated with the sql statement in mysql/initdb/02-populate.sql. You may use those sql statements as an example of how to add user, add user to a group, set accounting interval, set monthly data quota, set auto disconnect interval, etc.


