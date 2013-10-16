#!/bin/bash
######### 		Installing Kaldin Online Exam Management Solution #############
#########		On Debian_7.0.0_x64 with Tomcat-7,Oracle-java7, MySQL5, Apache2, PHP5 and Webmin
#########			Kaldin installation will fail if no JDK installation found
#####			Kaldin is a java/tomcat based online assessment software to help instructors to create online assessments
#####			visit this page for more details: http://www.kaldin.com/
## VAR

KALDIN_VER=2.1 					## Version of Latest Kaldin
KALDIN_SOURCE=http://hivelocity.dl.sourceforge.net/project/kaldin/Kaldin-2.1/Kaldin-2.1.zip    ## Direct download Link for Kaldin WAR file
KALDIN_PROXY=/etc/apache2/conf.d/kaldin.conf
SOURCES_APT=/etc/apt/sources.list
APACHE_CONF=/etc/apache2/apache2.conf
JDK_VER=oracle-java7
JDKPATH=/usr/lib/jvm/
SERVER_FQDN=kaldiin.com			## Change this as per your server name

##
#####		Function to prompt for user attention
function pause(){
   read -p "$*"
}

#### Installing Oracle-JAVA7
##  The following command will fix the add-apt-repository command:
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y upgrade
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update && sudo apt-get -y install oracle-jdk7-installer
#echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
#echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80/ --recv-keys EEA14886
#apt-get update
#apt-get -y install oracle-java7-installer


#####
if dpkg --get-selections | grep $JDK_VER; then
		echo "Found Oracle JDK $JDK_VER, Kaldin can be installed on this system"
	else 
		echo "Oracle JDK $JDK_VER wasn't found in $JDKPATH, please check the installation and/or path $JDKPATH"
		echo "Please correct the JDK installation and then run the Kaldin installer script. Kaldin installer is exiting now"
	exit 1;
fi
 
#### 		Update the system
apt-get update
apt-get -y install sudo vim unzip mysql-server apache2 tomcat7 php5 phpmyadmin postfix

echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/default/tomcat7

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

#cd /var/lib/tomcat7/webapps/
cd /tmp/

echo "downloading kaldin2.1 from $KALDIN_SOURCE"
wget $KALDIN_SOURCE
echo "Extracting Kaldin-2.1.zip"
sudo unzip Kaldin-2.1.zip
sudo cp Kaldin-2.1/kaldin/webapps/kaldin.war /var/lib/tomcat7/webapps

#####		Installing Kaldin
## Check the permissions for tomcat directories
chown -R tomcat7:tomcat7 /usr/share/tomcat7
chown -R tomcat7:tomcat7 /var/lib/tomcat7

#pause 'Press [Enter] if kaldin.war has been downloaded successfully, else open another SSH session, download kaldin.war to /var/lib/tomcat7/webapps/, come over here and then press [Enter] to continue'

##### Setting up apache2 with "ServerName $SERVER_FQDN:80"
echo "I am assuming $SERVER_FQDN as the default FQDN, this is required to update in the file apache.conf file"
echo "Type 'y' if you want to change the $SERVER_FQDN to your own"
echo "Type 'n' to continue with $SERVER_FQDN"

read item
case "$item" in
 y|Y) echo "Please type the Server FQDN in the form of foo.domain.com"
		read inputline
		SERVERFQDN=$inputline ;;
 n|N) echo "Continuing with $SERVER_FQDN"
		SERVERFQDN=$SERVER_FQDN;;
 *) echo "Not an answer";;
esac
echo "ServerName $SERVERFQDN:80" >> $APACHE_CONF
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
