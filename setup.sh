#!/bin/bash

# This script aims to make creation of Virtual Hosts within Apache automatic
# The user that executes the file need sudo access
#
# Run the following instruction to make it works
# chmod +x setup.sh
# ./setup.sh
# 
# @author aduh95
# @github https://github.com/aduh95/Apache-Virtual-Hosts-Creator/edit/master/README.md
#
# You can personalize the folder if the following lines

# Folder where virtual host configuration files are stored
apacheConfDir="/etc/apache2/sites-available"
# Web files will be if $wwwDir/$user/www
wwwDir="/home"
# Folder where the logs should be saved
logDir="/var/log/web"
# Folder where the PHP errors and notices are written (you have to set it in php.ini)
phpLog="$logDir/php_errors.log"

#
# Begining of script
# ════════════════════

if [ $(id -u) != "0" ]; then
	clear
	echo "╔═══════════════════════════════════════════════════════════════════════╗"
	echo "║ Welcome in the installation of the Virtual Hosts creator for Apache 2 ║"
	echo "╚═══════════════════════════════════════════════════════════════════════╝"
	echo
	echo "Here are the paths that this script will follow to configure your system:"
	echo "------------------------------------------------------------------------"
	echo "Apache conf files:              $apacheConfDir"
	echo "DocumentRoot:                   $wwwDir/[user]/www"
	echo "Log files:                      $logDir/[host]/*.log"
	echo "PHP log file:                   $phpLog"
	echo "------------------------------------------------------------------------"
	echo
	echo "If your are not happy with those settings, feel free to change it - if you know what you are doing"
	echo

	read -p "Press enter to continue (in sudo mode)..."
	sudo $0 "$USER" "$HOME" noDirectRootExecution || exit -1
	source "$HOME/.bashrc"
	rm -- $0
	exit $?
else
	if [ $# -ne 3 ] || [ "$3" != "noDirectRootExecution" ]; then
		echo "You should NOT launch this script directly from ROOT user! Aborted."
		exit 1
	fi
fi

confVars="apacheConfDir=\"$apacheConfDir\"
wwwDir=\"$wwwDir\"
logDir=\"$logDir\"
phpLog=\"\$logDir/php_errors.log\""

echo "sudo OK"
echo "Checking Apache 2 installation..."
 if [ "dpkg-query -W apache2 | awk {'print $1'} = """ ]; then
	echo "Installed!"
else
	echo "Trying to install Apache 2!"
	apt-get update && apt-get install apache2 || exit -1
fi

# Creation of the folders
mkdir -p /var/log/web
mkdir -p /etc/apache2/sites-available/VirtualHosts


# Creation of the bash file to create a virtual host
touch /root/newVirtualHost.sh
touch /root/deleteVirtualHost.sh

# Color seter
color='red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
bold=`tput bold`
reset=`tput sgr0`'

# Creation script newApacheVirtualHost.sh
echo "#!/bin/bash

# ==>directories are not expected to end with a /<==
$confVars

$color

if [ \$# -eq 1 ]; then
	hostName=\$1
else
	read -p \"Name of the Virtual Host (domain: \${green}exemple.com\${reset}) to create : \" hostName
	read -p \"The following URL will be set : \${yellow}\$hostName\${reset} and \${yellow}www.\$hostName\${reset} (Enter to continue, ^C to abort)\" tmp
fi
read -p \"Set a username to create for the new virtual host (a new user, such as \${green}exemple_com\${reset}) : \" userName
if [[ ! \$userName =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
	echo
	echo
	echo \"\${red}The username you have set does not fit the standard way, and it may cause you \${bold}problems in the future.\${reset}\"
	echo
	read -p \"Are you sure you want to create this user ? (only if you know what you are doing) (y/n):\" -n 1 -r
	echo
	if [[ ! \$REPLY =~ ^[Yy]$ ]]
	then
		echo \"Installation aborted!\"
		exit 0
	fi
fi

file=\"\$apacheConfDir/\$hostName.conf\"

if [ -f \$file ]
then
	echo \"This virtual host already exist! Aborted.\"
else
	# Create the new host
	addgroup \$userName
	adduser --ingroup \$userName \$userName
	adduser www-data \$userName

	# Creation of the folders
	# mkdir \"\$wwwDir/\$userName\" -- already created
	mkdir \"\$wwwDir/\$userName/www\"
	touch \"\$wwwDir/\$userName/www/index.html\"
	echo \"<html><head><title>\$hostName works!</title></head><body><p>Welcome on the new Apache Virtual Host!<br/>Set with <a href='https://github.com/aduh95/Apache-Virtual-Hosts-Creator'>Apache-Virtual-Hosts-Creator</a></p></body></html>\" > \"\$wwwDir/\$userName/www/index.html\"
	chown \$userName:\$userName \"\$wwwDir/\$userName/www\"
	chown \$userName:\$userName \"\$wwwDir/\$userName/www/index.html\"
	chmod 774 \"\$wwwDir/\$userName/www\"
	mkdir \"\$logDir/\$hostName\"
	# Création d'un lien vers les logs
	ln -s \"\$logDir/\$hostName/\" \"\$wwwDir/\$userName/logs\"
	ln -s \$phpLog \"\$logDir/\$hostName/php_errors.log\"

	# Creation of the configuration file
	echo \"# WARNING: You can break your website if you change something! Know your shit ;)
<VirtualHost *:80>
	ServerAdmin webmaster@\$hostName
	ServerName \$hostName
	ServerAlias www.\$hostName

	# You really should not change those lines
	DocumentRoot \$wwwDir/\$userName/www/
	ErrorLog \$logDir/\$hostName/error.log
	CustomLog \$logDir/\$hostName/access.log combined

	<Directory \$wwwDir/\$userName/www/>
			Options Indexes FollowSymLinks
			
			# .htaccess files will be ignored
			AllowOverRide None
			
			# Disable directory listing
			IndexIgnore * 
			
			Require all granted
			Order Allow,Deny
			Allow from all
	</Directory>
</VirtualHost>
\" >> \$file
	echo \$hostName >> \$apacheConfDir/VirtualHosts/\$userName.vh
	chown \$userName \$file
	ln -s \$file \$wwwDir/\$userName/virtualHost.conf

	# Activation of the host
	a2ensite \"\$hostName\" && read -p \"Apache is going to restart. Press enter to restart the apache2 service...\" __var
	service apache2 reload
	
	echo
	echo \"Your virtual host is now installed!\"
	echo \"You can run the command '\${green}su\${reset} \${yellow}\$userName\${reset}' to configure it and go to '\${yellow}http://\$hostName/\${reset}' to check out the result.\"
fi
" > /root/createApacheVirtualHost.sh


# Delete script deleteApacheVirtualHost.sh
echo "#!/bin/bash

$confVars

$color

if [ \$# -eq 1 ]; then
	userName=\$1
else
	read -p \"Name of the \${green}username\${reset} set to the Virtual Host \${red}to delete\${reset} : \" userName
fi
if [ -d \"\$wwwDir/\$userName\" ] && [ -f \"\$apacheConfDir/VirtualHosts/\$userName.vh\" ]; then
	hostName=\`cat \$apacheConfDir/VirtualHosts/\$userName.vh\`
else
	echo \"Cannot find user's virtual host! Aborted\"
	exit 1
fi
read -p \"\${red}\${bold}You are about to delete the Virtual Host for \${yellow}\$hostName\${reset}. To abort, press ^C; to continue, press Enter...\" __var
file=\"\$apacheConfDir/\$hostName.conf\"

if [ -f \$file ]
then
	# Check if the www dir is empty
	if find \"\$wwwDir/\$userName/www\" -mindepth 1 -print -quit | grep -q .; then
		echo \"The www (\$wwwDir/\$userName) directory should be empty! Aborted\"
		exit 2
	else
		#Deleting the vh
		read -p \"All the process from the user are \${bold}about to end\${reset}. Press enter to continue...\" __var
		pkill -u \$userName
		read -p \"The logs are about \${red}to be removed\${reset}! Press entrer to continue...\" __var
		rm -r \"\$logDir/\$hostName\"
		a2dissite \$hostName
		rm -r \"\$wwwDir/\$userName\"
		rm \$file
		rm \$apacheConfDir/VirtualHosts/\$userName.vh
		
		deluser www-data \$userName
		
		read -p \"Do you want \${red}to delete\${reset} the user '\$userName'? (y/n):\" -n 1 -r
		echo
		if [[ \$REPLY =~ ^[Yy]$ ]]; then
			deluser \$userName && delgroup --only-if-empty \$userName && echo \"\${green}Deleted\${reset}\"
		fi
	fi

	read -p \"Apache is going to restart. Press enter to restart the apache2 service...\" __var
	service apache2 reload

	echo
	echo \"The virtual host has been deleted!\"

else
	echo \"This virtual host \${yellow}\$hostName\${reset} does not exist! Aborted\"
fi
" > /root/deleteApacheVirtualHost.sh

chmod +x /root/*ApacheVirtualHost.sh


# Creation of the aliases
read -p "Do you want to create the aliases? (If you don't know what that mean, you should) (y/n):" -n 1 -r
echo	# (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	echo "Installation completed"
	exit 0
fi

touch "$2/.bash_aliases"
echo "alias newApacheVH='sudo /root/createApacheVirtualHost.sh'
alias delApacheVH='sudo /root/deleteApacheVirtualHost.sh'
" >> "$2/.bash_aliases"

chown $1 "$2/.bash_aliases"




# End of the installation
echo "Installation completed"
echo "To create a new Virtual Host, you can run the 'newApacheVH' alias, and 'delApacheVH' to delete one."

