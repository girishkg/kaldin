#!/bin/bash
#########               Installing Kaldin On-line Exam Management Solution #############
#########               On Debian_7.0.0_x64 with Tomcat-7,Oracle-java7, MySQL5, Apache2, PHP5 and Webmin
#########                       Kaldin installation will fail if no JDK installation found
#####                   Kaldin is a java/tomcat based on-line assessment software to help instructors to create on-line assessments
#####                   visit this page for more details: http://www.kaldin.com/

KALDIN_VER=3.0;                                         ## Version of Latest Kaldin
KALDIN_SOURCE=http://liquidtelecom.dl.sourceforge.net/project/kaldin/Kaldin-3.0/Kaldin-3.0.zip;    ## Direct download Link for Kaldin WAR file
KALDIN_PROXY=/etc/apache2/conf-enabled/kaldin.conf;
SOURCES_APT=/etc/apt/sources.list;
APACHE_CONF=/etc/apache2/apache2.conf;
JDK_VER="oracle-java7-jdk";
JDKPATH="/usr/lib/jvm/";
SERVER_FQDN=$( hostname -f );
SCRIPT=$0;
##
#####           Function to prompt for user attention
echo "*********************************************";
echo "This script is to install 'Kaldin' - Online Assessment Software";
echo "Kaldin is writen in JAVA and needs supporting packages..";
echo "This script will try to install $JDK_VER from Oracle VIA PPA";
echo "Script will exit If JDK install fails anywhere.";
echo "If JDK install fails, please install it manually and then try this script";
echo "*********************************************";
echo "Press 'y' to continue
Press 'n' to abort the script";
echo "*********************************************";
read item;
case "$item" in
 n|N)
        echo "Aborting the '$SCRIPT' script......";
                exit 1;;
 y|Y)
        echo "Continuing the '$SCRIPT' script";
        for i in {1..4};
                do
                   echo -n "-->";
                   sleep 1;
                done;;
 *)
        echo "Not an answer";;
esac;

#### Getting HTTP_PROXY details
if set | grep -i proxy >/dev/null; 
	then 
		echo "Proxy is already configured"; 
	else 
		echo "Proxy is not configured";
		echo "If there is any internet proxy, please provide the details..!";
		echo "Press 'y' to continue entering the proxy details
		Press 'n' if you have configured it already or if you don't have proxy";
		echo "*********************************************";
		read item;
		case "$item" in
		 n|N)
				echo "Continuing the '$SCRIPT' script without any change in proxy settings......";;
						
		 y|Y)
				echo "Please type the proxy details as 'USERNAME:PASSWORD@http://proxy.foo.com:PORT/'";
				echo "Note that you can leave the USERNAME and PASSWORD fields if you don't need";
				read -p 'HTTP_PROXY:' HTPROXY
				read -p 'HTTPS_PROXY:' HTSPROXY
				for i in {1..4};
						do
						   echo "Exporting the PROXY Config..";
						   echo -n "-->";
						   sleep 1;
						done;
				export http_proxy=$HTPROXY;
				export https_proxy=$HTSPROXY;;
		 *)
				echo "Not an answer";;
		esac;		
fi;

#### Installing Oracle-JAVA7
##  The following command will fix the add-apt-repository command:
sudo apt-get -y update;
sudo apt-get -y dist-upgrade;
sudo apt-get -y upgrade;
sudo apt-get -y install python-software-properties;
sudo add-apt-repository ppa:webupd8team/java;
sudo apt-get update && sudo apt-get -y install oracle-jdk7-installer;

#####
if grep --quiet $JDK_VER /var/lib/dpkg/status;
        then
                echo "Exit code was $?";
                echo "Found $JDK_VER, Kaldin can be installed on this system";
        else
                echo "Exit code was $?";
                echo "$JDK_VER wasn't found in $JDKPATH, please check the installation and/or path $JDKPATH";
                echo "Correct the JDK installation and then run the Kaldin installer script. Exiting now.....";
        exit 1;
fi;

####            Install main packages
sudo apt-get -y install sudo vim zip unzip mysql-server apache2 tomcat7 php5 phpmyadmin postfix;

echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/default/tomcat7;

######          Installing webmin
echo "Creating webmin sources for apt";
sudo cat >> $SOURCES_APT << EOF
##[Webmin]
deb http://download.webmin.com/download/repository sarge contrib
deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
EOF

cd /root;
wget http://www.webmin.com/jcameron-key.asc;
sudo apt-key add jcameron-key.asc;
sudo apt-get update;
sudo apt-get -y install webmin;

#cd /var/lib/tomcat7/webapps/
cd /tmp/;

echo "Downloading KALDIN-$KALDIN_VER from $KALDIN_SOURCE";
wget $KALDIN_SOURCE;
echo "Extracting KALDIN-$KALDIN_VER.zip";
sudo unzip Kaldin-$KALDIN_VER.zip;
sudo cp -r Kaldin-$KALDIN_VER/kaldin/webapps/kaldin /var/lib/tomcat7/webapps;

#####           Installing Kaldin
## Check the permissions for tomcat directories
sudo chown -R tomcat7:tomcat7 /usr/share/tomcat7;
sudo chown -R tomcat7:tomcat7 /var/lib/tomcat7;

##### Setting up apache2 with "ServerName $SERVER_FQDN:80"
echo "I am assuming $SERVER_FQDN as the default FQDN, this is required to update the file apache.conf";
echo "Type 'y' if you want to change the $SERVER_FQDN to your own";
echo "Type 'n' to continue with $SERVER_FQDN";

read item;
case "$item" in
     y|Y) echo "Please type the Server FQDN in the form of foo.domain.com";
          read inputline;
          SERVERFQDN=$inputline;;
     n|N) echo "Continuing with $SERVER_FQDN";
                SERVERFQDN=$SERVER_FQDN;;
     *) echo "Not an answer";;
esac;
echo "ServerName $SERVERFQDN:80" >> $APACHE_CONF;
#####           Setting up apache2 proxy for Tomcat7
sudo cat >> $APACHE_CONF << EOF
LoadModule proxy_module /usr/lib/apache2/modules/mod_proxy.so
LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
EOF

#####
sudo cat >> $KALDIN_PROXY << EOF
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

##### Setting FQDN on /etc/hosts
ifconfig | grep Bcast > /tmp/ip1;
cat /tmp/ip1 | awk '{ print $2 }' > /tmp/ip2;
sed -i 's/addr://' /tmp/ip2;
IPADDRESS=$(cat /tmp/ip2);
SERVERNAME=$( hostname -f );
echo "$SERVERFQDN IP address is: $IPADDRESS";
echo "$IPADDRESS        $SERVERNAME     $SERVERFQDN" >> /etc/hosts;

##### Finally restart all the web services
sudo service tomcat7 restart
sudo service apache2 restart
