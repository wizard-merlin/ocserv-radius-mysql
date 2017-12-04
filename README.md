Bring up the services by 
```
docker-compose up
```

Run `docker-compose run radtest radtest testing password freeradius 0 testing123` to test if freeradius is working. You should see "Access-Accept" in the output.

Download and install anyconnect client.

Windows client download https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect-windows-4.4.02034.msi
mac OS client download  https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect-macos-4.4.02034.dmg
Android client download  https://github.com/wizard-merlin/clients-download/blob/master/anyConnect/anyconnect.android-4.0.05062.apk

The VPN server will be listening at <host machine IP address>:8388. A user is already added for testing purpose. The username is `testing`, password is `password`. Login from an AnyConnect client or OpenConnect client. When you are done testing, open freeradius-3/authorize and delete this user.

Then go to http://localhost:8080/ and login as root. The server is mysql. The password of root is the value of environment variable `MYSQL_ROOT_PASSWORD` in docker-compose.yml.

Add the VPN server as an NAS
```
INSERT INTO `nas` (`nasname`, `shortname`, `type`, `ports`, `secret`, `server`, `community`, `description`)
VALUES ('172.16.238.20', 'ocserv', 'other', NULL, 'testing123', NULL, NULL, 'RADIUS Client');
```

Add a user. To get the hash value of a password, run `radcrypt <password>`. In the following example, the password is `foobar`.
```
INSERT INTO `radcheck` (`username`, `attribute`, `op`, `value`)
VALUES ('testuser', 'Crypt-Password', ':=', 'dTX25UxtVmFPM');
```

Add a user to a group called `basic`
```
INSERT INTO `radusergroup` (`username`, `groupname`, `priority`)
VALUES ('testuser', 'basic', '1');
```

Now try to connect the VPN server as user `testuser` with password `foobar`.

You can add more configuration. For example,

Ask VPN server to report the data usage statistics of users in group `basic` every 10 minites.
```
INSERT INTO `radgroupreply` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Acct-Interim-Interval', ':=', '600');
```

Set monthly data quota to 2 GB for usrs of group `basic`
```
INSERT INTO `radgroupcheck` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Monthly-Data-Quota', ':=', '2147483648');
```

Automatically disconnect users in group `basic` from VPN server every 12 hours.
```
INSERT INTO `radgroupreply` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Session-Timeout', ':=', '43200');
```


