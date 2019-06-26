#!/bin/bash
# verification si presence d'une ip dans liste noire

# Inspire du script https://gist.github.com/agarzon/5554490

# Pour plus d'informations sur les resultats voir : https://www.projecthoneypot.org/httpbl_api.php

# Listes noires recuperees sur https://www.dnsbl.info/dnsbl-list.php et affinees

# Antoine Bussiere

#set -x

BLISTS="
bl.spamcop.net
dnsbl.sorbs.net
dul.dnsbl.sorbs.net
http.dnsbl.sorbs.net
misc.dnsbl.sorbs.net
pbl.spamhaus.org
zen.spamhaus.org
sbl.spamhaus.org
xbl.spamhaus.org
smtp.dnsbl.sorbs.net
socks.dnsbl.sorbs.net
spam.dnsbl.sorbs.net
spamsources.fabel.dk
"


# Saisie de l'ip

#echo "Balance ton ip : "

#read ip

#rm *.csv

# Recuperation des ip de type outxx.mail.ovh.net

for i in {1..100}

			do

				host out$i.mail.ovh.net | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> ipmailout_temp.txt
				host mo$i.mail-out.ovh.net | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> ipmailout_temp.txt

			done

# Recuperation des ip de type xx.moxx.mail-out.ovh.net

for j in {1..15}

	do

		for i in {1..60}

			do

				host $i.mo$j.mail-out.ovh.net  | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> ipmailout_temp.txt

			done

	done

# Suppression des doublons

cat ipmailout_temp.txt | sort | uniq >> ips.txt  && rm ipmailout_temp.txt



while IFS= read -r ip

	do


		# Mise en place du reverse à partir de l'ip

		reverse=$(echo $ip | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")


		REVERSE_DNS=$(dig +short -x $ip)


		echo IP $ip NAME ${REVERSE_DNS:----}


		# Verification des ip dans les lites noires

		for BL in ${BLISTS} ; do

			# affichage du reverse et nom de la liste noire

			printf "%-60s" " ${reverse}.${BL}."

			# utilisation du dig pour interroger la liste noire

			LISTED="$(dig +short -t a ${reverse}.${BL}.)"

			# Si la variable est vide => en vert , si non vide => rouge // pas encore implemente , en cours de test

			if [ -z "$LISTED" ]; then

				echo ${LISTED:----}

			else

				echo ${LISTED:----}

				echo "${REVERSE_DNS},$ip,${BL},${LISTED}" >> listemailout_spam.csv

			fi

		done

	done < ips.txt


#Création de l'entête du fichier

sed -i 1i"Mail Out,IP,Nom Blacklist,Code Retour" listemailout_spam.csv

rm *.txt
