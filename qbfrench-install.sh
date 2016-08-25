#!/bin/bash
# Script d'installtion des extensions de moteur de recherche franophone pour qBittorent


# Déclaration des variables
destination="$HOME/.local/share/data/qBittorrent/nova3/engines"
fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
trap "rm -f $fichtemp" 0 1 2 5 15

export DIALOGOPTS="\
	--backtitle \"Installation de moteurs de recherche français pour qBittorrent\" \
	--ok-label Valider  --cancel-label Quitter \
"


### Introduction
function intro()
{
	dialog \
		--title "Introduction" \
		--no-label "Annuler" --yes-label "Continuer" \
		--colors --yesno "
Bienvenue dans l'installateur \Zb\Z1qbfrench\Zn.

Ce script installera des moteurs de recherche français pour \Zb\Z1qBittorent\Zn.

Souhaitez-vous poursuivre l'installation ?" 12 60

	if [ $? = 0 ]
	then
		choix
	else
		exit
	fi
}

## Choix des trackers
function choix()
{
	dialog \
		--title "Sélection des extensions à installer" --clear \
		--colors --checklist "\n- Appuyer sur \Zb\Z1Espace\Zn pour sélectionner les extensions \n\n- Appuyer sur \Zb\Z1Entrée\Zn pour valider votre choix\n\n" 17 60 5 \
			"smartorrent" "" off\
			"cpasbien" "" off\
			"torrent9" "" off\
			"t411" "(privé)" off 2> $fichtemp

	if [ $? = 0 ]
	then

		if [ ! -s $fichtemp ]
			then
			dialog --title "Aucune extension sélectionnée !" \
				--no-label "Annuler" --yes-label "Recommencer" \
				--colors --yesno "Vous n'avez sélectionné aucune extension pour l'installation.
- Déplacez-vous dans la liste avec les flèches \Zb\Z1HAUT\Zn et \Zb\Z1BAS\Zn.
- Sélectionnez une extension avec la barre d'\Zb\Z1ESPACE\Zn.
- Déplacez vous entre \"Valider\" et \"Quitter\" avec les flèches \Zb\Z1GAUCHE\Zn et \Zb\Z1DROITE\Zn
- Validez votre choix avec \Zb\Z1ENTREE\Zn
" 12 65
					if [ $? = 0 ]
					then
						choix
					else
						exit
					fi

		fi
		for choix in `cat $fichtemp`
		do
			instal $choix
		done
		end
	else
		exit
	fi
}

#### Installation des extensions
function instal()
{

	if [ $1 = 't411' ]
	then
		define_login
	else
		# "print_$1" > "$destination/$1.py"
		"print_$1"
	fi
}

##### Definition du login de T411
function define_login()
{
	dialog --title "Configuration du compte T411" --inputbox "\
T411 est un tracker privé, c'est à dire qu'il faut vous créer un compte (gratuit) sur leur site pour avoir accès aux téléchargements.
Pour que le moteur de recherche de qBittorent puisse ajouter les torrents à votre liste de téléchargements, il est nécessaire de le connecter à votre session.

Entrez votre nom d'utilisateur de T411 :" 14 60 user 2> $fichtemp

	if [ $? = 0 ]
	then
		login=`cat $fichtemp`
		pass
	else
		exit
	fi
}

### Definition du mot de passe de T441
function pass()
{
	dialog \
		--title "Configuration du compte T411" \
		--insecure --passwordbox "
Pour finaliser l'installation, veuillez renseigner
votre mot de passe de connexion à T411.

Entrez votre mot de passe :" 14 60 2> $fichtemp

	if [ $? = 0 ]
	then
		password=`cat $fichtemp`
		wget --quiet --post-data="login=$login&password=$password&remember=1" \
			--save-cookies=cookies.txt --keep-session-cookies \
			"http://www.t411.ch/users/login/" -O /dev/null
		test=`cat cookies.txt | grep "pass"`
		if [ "$test" = '' ]
		then
			reconf
		else
			echo "$t411" | sed "s/Your_User/$login/" | sed "s/Your_Pass/$password/" > "${destination}/t411.py"
			end
		fi

	else
		exit
	fi

}

##### Propose la reconfiguration lors de l'erreur de la configuration d'un tracker privé
function reconf()
{
	dialog --title "Problème d'authentification sur T411" \
		--yes-label "Reconfigurer" --no-label "Terminer" \
		--yesno "
Ooops... La connexion à T411 a échoué.

Souhaitez-vous reconfigurer vos identifiants
ou finaliser l'installation malgré tout ?" 12 60

	if [ $? = 0 ]
	then
		define_login
	else
		end "problem"
	fi
}


##### Fonction d'information de la fin d'installation

function end()
{

	if  test -z "$1"
	then
		info_msg="
Félicitations, toutes les extensions ont été installées avec succès.
Pensez à redémarrer qBittorent pour que les changements prennent effet."
	else
		info_msg="
Tous les plugins ont été installés.

Attention : T411 semble mal configuré. Dans ce cas qBittorent vous redirigera vers votre navigateur pour télécharger le torrent.
Pensez à redémarrer qBittorent afin que les changements prennent effet."
	fi

	dialog --title "Bravo, c'est fini !" \
		--sleep 2 --infobox "${info_msg}" 10 60
	exit

}


##### Définition des plugins searchengine python

{{INLINE_SCRIPTS}}

##### Lancement du script !

intro
