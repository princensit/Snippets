Snippets
========


Small snippets that can be used occassionally !

#### tatkal_status.sh: 
This shell script can be used to know the Indian Railway Tatkal Status.

Prior requirements:
* Install apache2 `sudo apt-get install apache2-mpm-worker` to have dynamic contents with CGI scripts.

Additional apache2 configurations:
* _/etc/apache2/apache2.conf_: Add `ServerName localhost` to conf file.
* _/etc/apache2/ports.conf_: Update `Listen <port>` as required.

Put this shell script in path: _/usr/lib/cgi-bin/_. Change mode to 777.
