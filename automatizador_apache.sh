#!/bin/bash
#Realizado por: Carlos Cerezo López
#---------------------------------
#NO RESUELVE EL WWW:DOMINIO.ES####
#--------------------------------

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
	echo -e "${Red}Uso $0 ${endColour} ${Blue}-d 'Nombre del dominio' ${endColour} ${Green}-s 'Alias del servidor'${endColour} ${Yellow}-c 'Contacto' ${endColour}"
	exit 1
}



dominio=""
server_alias=""
contacto_admin=""

#opt recorre getops "-d -s -c van separados porque necesitan argumentos"
#$OPTARG es lo que viene después de -d Ej -d teclado.local  ENTONCES $OPTARG=teclado.local
while getopts "d:s:c:" opt
do
	case $opt in
		d)
		   dominio=$OPTARG
		;;
		
		s)
		   server_alias=$OPTARG
		;;

		c)
	           contacto_admin=$OPTARG
		;;

		*)
		   mostrar_ayuda
		;;
	esac
done


if [ -z "$dominio" ] || [ -z "$server_alias" ] || [ -z "$contacto_admin" ];then
	clear
	mostrar_ayuda
	exit 1
fi


#Creamos el directorio con el fichero html
mkdir -p "/var/www/$dominio/public_html/"
echo "<h1>$dominio funciona</h1>" >> /var/www/$dominio/public_html/index.html


#Creamos el certificado
a2enmod ssl
systemctl reload apache2
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/${dominio}-selfsigned.key -out /etc/ssl/certs/${dominio}-selfsigned.crt

#Datos del VirtualHost
echo "
<VirtualHost *:80>

	ServerName $dominio
	Redirect permanent / https://${dominio}

</VirtualHost>


<VirtualHost *:443>
	DocumentRoot "/var/www/$dominio/public_html"
	ServerName $dominio
	ServerAdmin $contacto_admin
	ServerAlias $server_alias

	SSLEngine on
	SSLCertificateFile /etc/ssl/certs/${dominio}-selfsigned.crt
	SSLCertificateKeyFile /etc/ssl/private/${dominio}-selfsigned.key
	
	ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
" >> /etc/apache2/sites-available/$dominio.conf


echo "127.0.0.1    $dominio $server_alias" >> /etc/hosts

a2ensite "${dominio}.conf"
systemctl reload apache2.service
clear

echo -e "${script_terminated_colour} Sitio Creado! :D ${endColour}"
sleep 1
clear
