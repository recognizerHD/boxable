##MySQL
It looks like www-data will need to have the group of all users hosting files.

After a user is added to mysql, update the plugin for the user record to include:  
*unix_socket*
 

Then run **flush privileges** needs to be run.
Update any code to point the host to **localhost:/var/lib/mysql/mysql.sock** or whatever **netstat -ln | grep "unix.\*mysql"** returns

https://easyengine.io/tutorials/
https://github.com/WordOps/WordOps

Implement this:
https://docs.python.org/3/library/unittest.html#module-unittest