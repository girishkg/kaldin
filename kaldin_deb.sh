#!/bin/bash
#########   	Installing Kaldin Online Exam Management Solution #############
#########		On Debian_7.0.0_x64 with Tomcat-7,Oracle-java7, MySQL5, Apache2, PHP5 and Webmin
#########			Kaldin installation will fail if no JDK installation found
#####
## VAR

KALDIN_VER=1.8 					## Version of Latest Kaldin
KALDIN_WAR=http://superb-dca3.dl.sourceforge.net/project/kaldin/Kaldin-1.8/kaldin.war    ## Direct download Link for Kaldin WAR file
KALDIN_PROXY=/etc/apache2/conf.d/kaldin.conf
SOURCES_APT=/etc/apt/sources.list
APACHE_CONF=/etc/apache2/apache2.conf
JAVA_VER=oracle-java7
JAVAPATH=/usr/lib/jvm/
SERVER_FQDN=kaldiin.com			## Change this as per your server name

##
#####		Function to prompt for user attention
function pause(){
   read -p "$*"
}

#### Installing Oracle-JAVA7
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80/ --recv-keys EEA14886
apt-get update
apt-get -y install oracle-java7-installer


#####
if dpkg --get-selections | grep $JAVA_VER; then
		echo "Found Oracle JAVA $JAVA_VER, Kaldin can be installed on this system"
	else 
		echo "Oracle JAVA $JAVA_VER wasn't found in $JAVAPATH, please check the installation and/or path $JAVAPATH"
		echo "Please correct the JAVA installation and then run the Kaldin installer script. Kaldin installer is exiting now"
	exit 1;
fi
 
#### 		Update the system
apt-get update
apt-get -y install sudo vim mysql-server apache2 tomcat7 php5 phpmyadmin postfix

pause 'Press [Enter] if everything went fine, else open another SSH session and correct the same, come over here and then press [Enter] to continue'

###### 		Installing webmin
echo "Creating webmin sources for apt"
cat >> $SOURCES_APT << EOF
##[Webmin]
deb http://download.webmin.com/download/repository sarge contrib
deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
EOF

cd /root
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
apt-get update
apt-get -y install webmin

#####		Installing Kaldin
## Check the permissions for tomcat directories
chown -R tomcat7:tomcat7 /usr/share/tomcat7
chown -R tomcat7:tomcat7 /var/lib/tomcat7
cd /var/lib/tomcat7/webapps/

echo "downloading kaldin.war from $KALDIN_WAR"
wget $KALDIN_WAR
pause 'Press [Enter] if kaldin.war has been downloaded successfully, else open another SSH session and correct the same, come over here and then press [Enter] to continue'

##### Setting up apache2 with "ServerName $SERVER_FQDN:80"
echo "ServerName $SERVER_FQDN:80" >> $APACHE_CONF
##### 		Setting up apache2 proxy for Tomcat7
cat >> $APACHE_CONF << EOF
LoadModule proxy_module /usr/lib/apache2/modules/mod_proxy.so
LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
EOF

#####
cat >> $KALDIN_PROXY << EOF
# mod_proxy setup.
ProxyRequests Off
ProxyPass /kaldin http://localhost:8080/kaldin/
ProxyPassReverse /kaldin/ http://localhost:8080/kaldin/

<Location "/kaldin">
  # Configurations specific to this location. Add what you need.
  # For instance, you can add mod_proxy_html directives to fix
  # links in the HTML code. See link at end of this page about using
  # mod_proxy_html.
  # Allow access to this proxied URL location for everyone.
  Order allow,deny
  Allow from all
</Location>
EOF


service tomcat7 restart
service apache2 restart

