# Notes on Mysql

## CLI commands
`SHOW TABLE INFO;`
`SHOW TABLE STATUS;`
`SHOW TABLES;`
`SHOW VARIABLES LIKE 'max_allowed_packet';`

## Create a database 
`create database hondb;
use hondb;
grant all on hondb to 'hondb'@'localhost'`

## Create a user 
CREATE USER 'sonar'@'localhost' IDENTIFIED WITH mysql_native_password;
set password for 'sonar'@'localhost' = PASSWORD('sonar');
grant all on sonar to 'sonar'@'localhost';

## copy section
CREATE DATABASE sample_db;
CREATE USER hybris_dbu IDENTIFIED BY 'hybris';
GRANT ALL ON sample_db.* TO hybris_dbu@'localhost' IDENTIFIED BY 'hybris';
FLUSH PRIVILEGES;
COMMIT;

## delete a user
SELECT User FROM mysql.user;
drop user 'sonar'@'localhost';

## change passwort to geheim
mysql> alter user 'root'@'localhost' identified by 'geheim';

## execute sql script by cli.
mysql --host=localhost --user=root --password=geheim  -e "filename.sql"

## start mysql server
sudo /usr/local/mysql/support-files/mysql.server start



