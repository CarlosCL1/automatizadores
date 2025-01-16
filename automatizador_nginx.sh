#!/bin/bash




if ! command -v toilet &> /dev/null;then
    sudo apt install toilet -y > /dev/null 2>&1
fi

#Colores
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
script_terminated_colour='\033[4;44m'
endColour='\033[0m'

#Menu de ayuda
mostrar_ayuda(){
    clear
    toilet -f mono12 -F border:metal Ayuda
    echo -e "${Red}Uso $0 ${endColour} ${Blue}-d 'Nombre del dominio' ${endColour}"
    exit 1
}



dominio=""



#opt recorre getops "-d -s -c van separados porque necesitan argumentos"
#$OPTARG es lo que viene después de -d Ej -d teclado.local  ENTONCES $OPTARG=teclado.local
while getopts "d:e:" opt
do
    case $opt in
        d) dominio=$OPTARG;;

        *) mostrar_ayuda ;;
    esac
done


if [ -z "$dominio" ];then
    clear
    mostrar_ayuda
    exit 1
fi




#Creamos el archivo de configuración con los datos obtenidos

echo "
##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
	listen 80;
	listen [::]:80;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	root /var/www/${dominio};

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name ${dominio};

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files \$uri \$uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	#location ~ \.php$ {
	#	include snippets/fastcgi-php.conf;
	#
	#	# With php-fpm (or other unix sockets):
	#	fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
	#	# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}


# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
#server {
#	listen 8080;
#	listen [::]:80;
#
#	server_name example.com;
#
#	root /var/www/example.com;
#	index index.html;
#
#	location / {
#		try_files $uri $uri/ =404;
#	}
#}


" > /etc/nginx/sites-available/${dominio}.conf



#Creamos el directorio en el que se almacenará el sitio
mkdir -p /var/www/${dominio}
chown -R www-data:www-data /var/www/${dominio}
chmod -R 755 /var/www/${dominio}



#Metemos datos de prueba en el sitio
echo "<h1>El sitio ${dominio} funciona!</h1>" > /var/www/${dominio}/index.html



#Creamos el enlace símbolico de sites-enabled a sites-available para que aparte de ser un sitio disponible también esté habilitado
cd /etc/nginx/sites-enabled && ln -s /etc/nginx/sites-available/${dominio}.conf


#Metemos el sitio en /etc/hosts
echo "127.0.0.1	 ${dominio}" >> /etc/hosts



service nginx restart





