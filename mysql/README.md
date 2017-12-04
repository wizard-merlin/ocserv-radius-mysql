setup.sql and schema.sql are copied from /etc/raddb/mods-config/sql/main/mysql/. The `00-` and `01-` prefix are added because they are executed in alphbetic sequence.
 
modification to schema.sql
```
--- schema.sql	2017-12-03 22:45:00.471067573 -0700
+++ initdb/01-schema.sql	2017-12-03 17:38:12.848826000 -0700
@@ -1,5 +1,7 @@
+CREATE DATABASE radius;
+USE radius;
 ###########################################################################
-# $Id$                 #
+# $Id: ca5ac77aa03dbb86ef714d1a1af647f7e63fda00 $                 #
 #                                                                         #
 #  schema.sql                       rlm_sql - FreeRADIUS SQL Module       #
 #                                                                         #
@@ -60,7 +62,7 @@
   id int(11) unsigned NOT NULL auto_increment,
   username varchar(64) NOT NULL default '',
   attribute varchar(64)  NOT NULL default '',
-  op char(2) NOT NULL DEFAULT '==',
+  op char(2) NOT NULL DEFAULT ':=',
   value varchar(253) NOT NULL default '',
   PRIMARY KEY  (id),
   KEY username (username(32))
```

modification to setup.sql
```
--- setup.sql	2017-12-03 22:44:45.520953233 -0700
+++ initdb/00-setup.sql	2017-12-02 17:11:28.562919000 -0700
@@ -6,19 +6,19 @@
 ##		 to something else.  Also update raddb/sql.conf
 ##		 with the new RADIUS password.
 ##
-##	$Id$
+##	$Id: aff0505a473c67b65cfc19fae079454a36d4e119 $
 
 #
 #  Create default administrator for RADIUS
 #
-CREATE USER 'radius'@'localhost';
-SET PASSWORD FOR 'radius'@'localhost' = PASSWORD('radpass');
+CREATE USER 'radius'@'%';
+SET PASSWORD FOR 'radius'@'%' = PASSWORD('radpass');
 
 # The server can read any table in SQL
-GRANT SELECT ON radius.* TO 'radius'@'localhost';
+GRANT SELECT ON radius.* TO 'radius'@'%';
 
 # The server can write to the accounting and post-auth logging table.
 #
 #  i.e.
-GRANT ALL on radius.radacct TO 'radius'@'localhost';
-GRANT ALL on radius.radpostauth TO 'radius'@'localhost';
+GRANT ALL on radius.radacct TO 'radius'@'%';
+GRANT ALL on radius.radpostauth TO 'radius'@'%';
```

