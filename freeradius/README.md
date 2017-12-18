docker cp freeradiusocserv_freeradius_1:/etc/freeradius/mods-available/sql sql

```
--- sql.original	2017-07-28 00:41:56.000000000 -0600
+++ sql	2017-12-03 17:57:07.363771019 -0700
@@ -28,7 +28,7 @@
 	#    * rlm_sql_sqlite
 	#    * rlm_sql_null (log queries to disk)
 	#
-	driver = "rlm_sql_null"
+	driver = "rlm_sql_mysql"
 
 #
 #	Several drivers accept specific options, to set them, a
@@ -84,14 +84,14 @@
 	#
 	# If you're using rlm_sql_null, then it should be the type of
 	# database the logged queries are going to be executed against.
-	dialect = "sqlite"
+	dialect = "mysql"
 
 	# Connection info:
 	#
-#	server = "localhost"
-#	port = 3306
-#	login = "radius"
-#	password = "radpass"
+	server = "mysql"
+	port = 3306
+	login = "radius"
+	password = "radpass"
 
 	# Database table configuration for everything except Oracle
 	radius_db = "radius"
@@ -242,7 +242,7 @@
 
 	# Set to 'yes' to read radius clients from the database ('nas' table)
 	# Clients will ONLY be read on server startup.
-#	read_clients = yes
+	read_clients = yes
 
 	# Table to keep radius client info
 	client_table = "nas"

```


docker cp freeradiusocserv_freeradius_1:/etc/freeradius/sites-available/default default
```
--- default.original	2017-07-28 00:41:55.000000000 -0600
+++ default	2017-12-02 15:57:06.222610593 -0700
@@ -402,7 +402,7 @@
 	#  is meant to mirror the "users" file.
 	#
 	#  See "Authorization Queries" in mods-available/sql
-	-sql
+	sql
 
 	#
 	#  If you are using /etc/smbpasswd, and are also doing
@@ -637,7 +637,7 @@
 	#  Log traffic to an SQL database.
 	#
 	#  See "Accounting queries" in mods-available/sql
-	-sql
+	sql
 
 	#
 	#  If you receive stop packets with zero session length,
@@ -679,7 +679,7 @@
 
 	#
 	#  See "Simultaneous Use Checking Queries" in mods-available/sql
-#	sql
+	sql
 }
 
 
@@ -729,7 +729,7 @@
 	#  After authenticating the user, do another SQL query.
 	#
 	#  See "Authentication Logging Queries" in mods-available/sql
-	-sql
+	sql
 
 	#
 	#  Un-comment the following if you want to modify the user's object

```

modification to clients.conf
```
@@ -233,6 +233,16 @@
 #	secret		= testing123
 #}
 
+#client ocserv {
+#	    ipaddr = 172.16.238.20
+#	        secret = testing123
+#}
+
+client radtest {
+	    ipaddr = 172.16.238.30
+	        secret = testing123
+}
+
 #
 #  You can now specify one secret for a network of clients.
 #  When a client request comes in, the BEST match is chosen.
```

modification to authorize
```
@@ -1,3 +1,5 @@
+# for testing only, remove in production
+testing Cleartext-Password := "password"
 #
 # 	Configuration file for the rlm_files module.
 # 	Please see rlm_files(5) manpage for more information.

```

modification to dictionary
```
@@ -47,3 +47,5 @@
 #ATTRIBUTE	My-Local-String		3000	string
 #ATTRIBUTE	My-Local-IPAddr		3001	ipaddr
 #ATTRIBUTE	My-Local-Integer	3002	integer
+ATTRIBUTE Monthly-Data-Quota 3003 integer
+ATTRIBUTE Monthly-Traffic-Limit 3004 integer

```

modification to sqlcounter
```
@@ -38,9 +38,12 @@
 #  DEFAULT  Max-Daily-Session > 3600, Auth-Type = Reject
 #      Reply-Message = "You've used up more than one hour today"
 #
+
+# freeradius may load the sqlcounter module before the sql module, causing an error like '${modules.sql.dialect} not found'. 
+# It's a pain to fix this so I will simply replace environment variable modules.sql.dialect, dialect and modconfdir with their values.
 sqlcounter dailycounter {
 	sql_module_instance = sql
-	dialect = ${modules.sql.dialect}
+	dialect = mysql
 
 	counter_name = Daily-Session-Time
 	check_name = Max-Daily-Session
@@ -49,12 +52,12 @@
 	key = User-Name
 	reset = daily
 
-	$INCLUDE ${modconfdir}/sql/counter/${dialect}/${.:instance}.conf
+	$INCLUDE /etc/freeradius/mods-config/sql/counter/mysql/${.:instance}.conf
 }
 
 sqlcounter monthlycounter {
 	sql_module_instance = sql
-	dialect = ${modules.sql.dialect}
+	dialect = mysql
 
 	counter_name = Monthly-Session-Time
 	check_name = Max-Monthly-Session
@@ -62,19 +65,19 @@
 	key = User-Name
 	reset = monthly
 
-	$INCLUDE ${modconfdir}/sql/counter/${dialect}/${.:instance}.conf
+	$INCLUDE /etc/freeradius/mods-config/sql/counter/mysql/${.:instance}.conf
 }
 
 sqlcounter noresetcounter {
 	sql_module_instance = sql
-	dialect = ${modules.sql.dialect}
+	dialect = mysql
 
 	counter_name = Max-All-Session-Time
 	check_name = Max-All-Session
 	key = User-Name
 	reset = never
 
-	$INCLUDE ${modconfdir}/sql/counter/${dialect}/${.:instance}.conf
+	$INCLUDE /etc/freeradius/mods-config/sql/counter/mysql/${.:instance}.conf
 }
 
 #
@@ -84,12 +87,26 @@
 #  attribute.
 sqlcounter expire_on_login {
 	sql_module_instance = sql
-	dialect = ${modules.sql.dialect}
+	dialect = mysql
 
 	counter_name = Expire-After-Initial-Login
 	check_name = Expire-After
 	key = User-Name
 	reset = never
 
-	$INCLUDE ${modconfdir}/sql/counter/${dialect}/${.:instance}.conf
+	$INCLUDE /etc/freeradius/mods-config/sql/counter/mysql/${.:instance}.conf
+}
+
+sqlcounter monthly_data_counter {
+	sql_module_instance = sql
+	dialect = mysql
+
+	counter_name = Monthly-Data-Usage
+	check_name = Monthly-Data-Quota
+        reply_name = Session-Timeout
+	key = User-Name
+	reset = monthly
+
+        # since version 3.0.9, need to use %%b instead of %b in 
+	query = "SELECT SUM(acctinputoctets + acctoutputoctets) FROM radacct WHERE UserName='%{${key}}' AND UNIX_TIMESTAMP(AcctStartTime) > '%%b';"
 }
```

```
--- accounting.original	2017-12-05 00:39:54.641388918 -0700
+++ accounting	2017-12-05 00:47:04.686385116 -0700
@@ -51,7 +51,7 @@
 	#
 	else {
 		update request {
-			&Acct-Unique-Session-Id := "%{md5:%{User-Name},%{Acct-Session-ID},%{%{NAS-IPv6-Address}:-%{NAS-IP-Address}},%{NAS-Identifier},%{NAS-Port-ID},%{NAS-Port}}"
+			&Acct-Unique-Session-Id := "%{md5:%{User-Name},%{Acct-Session-ID},%{%{NAS-IPv6-Address}:-%{NAS-IP-Address}},%{NAS-Identifier}}"
 		 }
 	}
 }
```

```
--- queries.conf.original	2017-07-28 00:41:57.000000000 -0600
+++ queries.conf	2017-12-14 23:51:49.891546102 -0700
@@ -392,10 +392,9 @@
 
 	query =	"\
 		INSERT INTO ${..postauth_table} \
-			(username, pass, reply, authdate) \
+			(username, reply, authdate) \
 		VALUES ( \
 			'%{SQL-User-Name}', \
-			'%{%{User-Password}:-%{Chap-Password}}', \
 			'%{reply:Packet-Type}', \
 			'%S')"
 }
```

```
--- example.pl.original	2017-07-28 00:41:59.000000000 -0600
+++ auth.pl	2017-12-17 20:16:49.860214100 -0700
@@ -32,6 +32,7 @@
 
 # use ...
 use Data::Dumper;
+use Crypt::PBKDF2;
 
 # Bring the global hashes into the package scope
 our (%RAD_REQUEST, %RAD_REPLY, %RAD_CHECK, %RAD_STATE);
@@ -118,22 +119,29 @@
 # Function to handle authenticate
 sub authenticate {
 	# For debugging purposes only
-#	&log_request_attributes;
+	#&log_request_attributes;
 
-	if ($RAD_REQUEST{'User-Name'} =~ /^baduser/i) {
-		# Reject user and tell him why
-		$RAD_REPLY{'Reply-Message'} = "Denied access by rlm_perl function";
+	my $pbkdf2 = Crypt::PBKDF2->new(
+		hash_class => 'HMACSHA2',
+		hash_args => {
+			sha_size => 512,
+		},
+	    iterations => 10000,
+	    salt_len => 10,
+	);
+	if (!exists $RAD_CHECK{'Cleartext-Password'}) {
+		$RAD_REPLY{'Reply-Message'} = "rlm_perl: unsupported password hashing function";
 		return RLM_MODULE_REJECT;
-	} else {
-		# Accept user and set some attribute
-		if (&radiusd::xlat("%{client:group}") eq 'UltraAllInclusive') {
-			# User called from NAS with unlim plan set, set higher limits
-			$RAD_REPLY{'h323-credit-amount'} = "1000000";
-		} else {
-			$RAD_REPLY{'h323-credit-amount'} = "100";
-		}
+	}
+	my $hash = $RAD_CHECK{'Cleartext-Password'};
+	if ($pbkdf2->validate($hash, $RAD_REQUEST{'User-Password'})) {
 		return RLM_MODULE_OK;
+	} else {
+		$RAD_REPLY{'Reply-Message'} = "rlm_perl: access Denied, wrong username or password";
+		return RLM_MODULE_REJECT;
 	}
+
+
 }
 
 # Function to handle preacct
@@ -226,5 +234,7 @@
 	for (keys %RAD_REQUEST) {
 		&radiusd::radlog(L_DBG, "RAD_REQUEST: $_ = $RAD_REQUEST{$_}");
 	}
+	for (keys %RAD_CHECK) {
+		&radiusd::radlog(L_DBG, "RAD_CHECK: $_ = $RAD_CHECK{$_}");
+	}
 }
-
```


```
--- perl.original	2017-07-28 00:41:57.000000000 -0600
+++ perl	2017-12-17 15:03:16.509710549 -0700
@@ -11,7 +11,7 @@
 	#  'rlm_exec' module, but it is persistent, and therefore
 	#  faster.
 	#
-	filename = ${modconfdir}/${.:instance}/example.pl
+	filename = ${modconfdir}/${.:instance}/auth.pl
 
 	#
 	#  The following hashes are given to the module and
```
-------
Some explanation on custom perl script for authentication. 

freeradius first reads the `authorize` section in `/etc/freeradius/sites-available/default`, when freeradius find the statement `perl`, it checks `/etc/freeradius/mods-available/perl`, which points it to `/etc/freeradius/mods-config/perl/auth.pl`. freeradius will call the `authorize` function in `auth.pl`, which does nothing but returning `OK`.

Then back in the file `default`, freeradius finds the `ulang` block 
```
	if (ok || updated) {
	    update control {
		Auth-Type := Perl
	    }
	}
```
which sets the `Auth-Type` attribute to "Perl". By setting the `Auth-Type` attribute, perl module claims the responsibility of authenticating users. The following `sql` module will find a matching row in the `radcheck` table and add an AVP(Attribute-Value Pair) like `Cleartext-Password: hashed_password`, which is the "known good password" to be used for authentication. The `pap` usually comes last in the `authorize` section, it sets the `Auth-Type` attribute only if no other modules have set it before. 

The `authenticate` section lists the modules for authentication. Becasue `Auth-Type` has been set to "Perl", the following block will match
```
	Auth-Type Perl {
	    perl
	}
```
And the `authenticate` function in `auth.pl` will be called. The `authenticate` function will get the encrypted password from `$RAD_CHECK{'Cleartext-Password'}` and get plaintext password from `$RAD_REQUEST{'User-Password'}` and verify whether them match. 

It would be more intuitive if we can use Attribute-Value Pair like `PBKDF2-Password: hashed_password`. Unfortunately, the sql module only recognize attributes like `Crypt-Password`, `MD5-Password`, etc., so we must reuse one of the existing attributes for the `attribute` field of `radcheck` table. "Cleartext-Password" is chosen because otherwise freeradius will preprocess the value. This custom authentication perl script only supports PBKDF2.
