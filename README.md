#kaldin Installer script

======

This installs Kaldin1.8 and dependencies (Tomcat7, Oracle-Java7, MySQL 5.5) on Debian/Ubuntu, I have tested this on Debain7.0.0_x64, So Ubuntu12.04/12.10 should also work fine for this script.

This script also installs all latest and stable: Postfix MTA, PHPMyAdmin (I need this to edit certain settings, namely email_settings), Apache2 (Automatically configured for proxy)
#(1) Requirements:

(1.1) Debain7.0.0_x64 (I have used netinst for faster installation).

(1.2) Internet Connection.

(1.3) I assume that the server is set up freshly with netinst/minimal OS.

(1.4) Don't run this if you have a setup already, you will lose the data.

#(2) Steps: Run as root and folow the onscreen instructions.

(2.1) Download the installer code and save it.

cd /tmp/

curl --output /tmp/kaldin_debv3.sh https://raw.github.com/girishkg/kaldin/master/kaldin_deb.sh

(2.2) Make it executable:

chmod +x /tmp/kaldin_debv3.sh

(2.3) Run the install script: 

./kaldin_debv3.sh

(2.4) Folow the on-screen instructions to complete the installation.

(2.5) Open up the web browser and visit http://server_ip/kaldin/ to complete the installation.

# (3) What it gonna do!

(3.1) Installs all stable requirements MySQL, Apache2, Tomcat7, Kaldin_2.1, PHP5, PHPMyAdmin, Oracle_JRE_1.7

(3.2) Sets Apache2 as proxy for Tomcat7.

(3.3) Sets required permissions on Kaldin.war.

#Cheers....!
