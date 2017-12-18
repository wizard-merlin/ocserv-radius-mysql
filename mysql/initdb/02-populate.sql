USE radius;

# Add the VPN server as an NAS
INSERT INTO `nas` (`nasname`, `shortname`, `type`, `ports`, `secret`, `server`, `community`, `description`)
VALUES ('172.16.238.20', 'ocserv', 'other', NULL, 'testing123', NULL, NULL, 'RADIUS Client');

# Add a user. To get the hash value of a password, run `pbkdf2.pl <password>`. In the following example, the password is `foobar`.
INSERT INTO `radcheck` (`username`, `attribute`, `op`, `value`)
VALUES ('testuser', 'Cleartext-Password', ':=', '{X-PBKDF2}HMACSHA2+512:AAAnEA:pJ1dOkNCKR3pWw==:NpQziayA1kVAIhWHSueYuTT66/VwANjvFDMqKhyNqNIwS2AQvcHDhHLBEteMYTRjHGbH/ukyOOaw4q+LKUZTpg==');

# Add a user to a group called `basic`
INSERT INTO `radusergroup` (`username`, `groupname`, `priority`)
VALUES ('testuser', 'basic', '1');

# Ask VPN server to report the data usage statistics of users in group `basic` every 10 minites.
INSERT INTO `radgroupreply` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Acct-Interim-Interval', ':=', '600');

# Set monthly data quota to 2 GB for usrs of group `basic`
INSERT INTO `radgroupcheck` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Monthly-Data-Quota', ':=', '2147483648');

# Automatically disconnect users in group `basic` from VPN server every 12 hours.
INSERT INTO `radgroupreply` (`groupname`, `attribute`, `op`, `value`)
VALUES ('basic', 'Session-Timeout', ':=', '43200');
