kaldin
======

kaldin Installer script

======

#This installs Kaldin1.8 and dependencies (Tomcat7, Oracle-Java7, MySQL 5.5) on Debian/Ubuntu, I have tested this on Debain7.0.0_x64, So Ubuntu12.04/12.10 should also work fine for this script.

#This script also installs all latest and stable: Postfix MTA, PHPMyAdmin (I need this to edit certain settings, namely email_settings), Apache2 (Automatically configured for proxy)
#(1) Requirements:
#(1.1) Debain7.0.0_x64 (I have used netinst for faster installation)
#(1.2) Internet Connection

#(2) Steps: 
#(2.1) Download the installer code and save it somewhere (ex: /tmp/kaldin_deb)
#(2.3) chmod +x /tmp/kaldin_deb
#(2.4) Go to tmp directory and run the the install script: ./kaldin_deb
#(2.5) Folow the on-screen instructions to complete the install
#(2.6) Open up web browser and visit http://server_ip/kaldin/ to complete the installation

#Cheers....!
