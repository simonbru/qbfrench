#!/bin/bash
# Script d'installtion des extensions de moteur de recherche franophone pour qBittorent


# Déclaration des variables
destination="$HOME/.local/share/data/qBittorrent/nova/engines"
destination_py3="$HOME/.local/share/data/qBittorrent/nova3/engines"
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
		for dest in "${destination}" "${destination_py3}"; do
			mkdir -p "$dest"
			"print_$1" > "$dest/$1.py"
		done
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
			for dest in "${destination}" "${destination_py3}"; do
				mkdir -p "$dest"
				print_t411 | sed -e "s/Your_User/$login/" -e "s/Your_Pass/$password/" > "${dest}/t411.py"
			done
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


### cpasbien

print_cpasbien() {
cat <<\EOF_2389742934
# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHOR: Davy39 <davy39@hmamail.com>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft


from __future__ import print_function

import re
try:
    # python2
    from HTMLParser import HTMLParser
except ImportError:
    # python3
    from html.parser import HTMLParser

from helpers import download_file, retrieve_url
from novaprinter import prettyPrinter


class cpasbien(object):
    url = "http://www.cpasbien.cm"
    name = "Cpasbien (french)"
    supported_categories = {
        "all": [""],
        "books": ["ebook/"],
        "movies": ["films/"],
        "tv": ["series/"],
        "music": ["musique/"],
        "software": ["logiciels/"],
        "games": ["jeux-pc/", "jeux-consoles/"]
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleHTMLParser(self.results, self.url)

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results, url, *args):
            HTMLParser.__init__(self)
            self.url = url
            self.div_counter = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'div'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            if params.get('href', '').startswith(self.url + '/dl-torrent/'):
                self.current_item = {}
                self.div_counter = 0
                self.current_item["desc_link"] = params["href"]
                fname = params["href"].split('/')[-1]
                fname = re.sub(r'\.html$', '.torrent', fname, flags=re.IGNORECASE)
                self.current_item["link"] = self.url + '/telechargement/' + fname

        def start_div(self, attr):
            if self.div_counter is not None:
                self.div_counter += 1
                # Abort if div class does not match
                div_classes = {1: 'poid', 2: 'up', 3: 'down'}
                attr = dict(attr)
                if div_classes[self.div_counter] not in attr.get('class', ''):
                    self.div_counter = None
                    self.current_item = None

        def handle_data(self, data):
            data = data.strip()
            if data:
                if self.div_counter == 0:
                    self.current_item['name'] = data
                elif self.div_counter == 1:
                    self.current_item['size'] = unit_fr2en(data)
                elif self.div_counter == 2:
                    self.current_item['seeds'] = data
                elif self.div_counter == 3:
                    self.current_item['leech'] = data
            # End of current_item, final validation:
            if self.div_counter == 3:
                required_keys = ('name', 'size')
                if any(key in self.current_item for key in required_keys):
                    self.current_item['engine_url'] = self.url
                    prettyPrinter(self.current_item)
                    self.results.append("a")
                else:
                    pass
                self.current_item = None
                self.div_counter = None

    def search(self, what, cat="all"):
        for page in range(35):
            results = []
            parser = self.SimpleHTMLParser(results, self.url)
            for subcat in self.supported_categories[cat]:
                data = retrieve_url(
                    '{}/recherche/{}{}/page-{},trie-seeds-d'
                    .format(self.url, subcat, what, page)
                )
                parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break


def unit_fr2en(size):
    """Convert french size unit to english"""
    return re.sub(
        r'([KMGTP])o',
        lambda match: match.group(1) + 'B',
        size, flags=re.IGNORECASE
    )

EOF_2389742934
}


### smartorrent

print_smartorrent() {
cat <<\EOF_2389742934
# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHOR: Davy39 <davy39@hmamail.com>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft

from __future__ import print_function

try:
    # python2
    from HTMLParser import HTMLParser
except ImportError:
    # python3
    from html.parser import HTMLParser

from helpers import download_file, retrieve_url
from novaprinter import prettyPrinter


class smartorrent(object):
    url = "http://smartorrent.com"
    name = "Smartorrent (french)"
    supported_categories = {"all": "0"}
    # TODO: Filter general results for specific categories

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results):
            HTMLParser.__init__(self)
            self.td_counter = None
            self.next_title = False
            self.next_param = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'small', 'td'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            url_prefix = smartorrent.url + '/torrents/'
            if (not params.get('data-toggle', None)
                    and params.get('href', '').startswith(url_prefix)):
                self.current_item = {}
                self.td_counter = 0
                self.current_item['desc_link'] = params['href'].strip()
                torrent_id = params['href'].split(url_prefix)[1]
                self.current_item['link'] = smartorrent.url + '/download/' + torrent_id

        def start_small(self, attr):
            if self.current_item and self.td_counter == 0:
                self.next_title = True

        def handle_data(self, data):
            if self.next_title:
                self.next_title = False
                self.current_item['name'] = data.strip()
            elif self.td_counter == 1:
                if 'size' not in self.current_item:
                    self.current_item['size'] = data.strip()
            elif self.td_counter == 3:
                if 'seeds' not in self.current_item:
                    self.current_item['seeds'] = data.strip()
            elif self.td_counter == 4:
                if 'leech' not in self.current_item:
                    self.current_item['leech'] = data.strip()

        def start_td(self, attr):
            if isinstance(self.td_counter, int):
                self.td_counter += 1
                if self.td_counter > 5:
                    self.td_counter = None
                    if self.current_item:
                        self.current_item["engine_url"] = smartorrent.url
                        prettyPrinter(self.current_item)
                        self.results.append("a")

    def search(self, what, cat="all"):
        for page in range(1, 35):
            results = []
            parser = self.SimpleHTMLParser(results)
            data = retrieve_url(
                self.url + '/search?page={}&search={}'.format(page, what)
            )
            parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break

EOF_2389742934
}


### t411

print_t411() {
cat <<\EOF_2389742934
# -*- coding: utf-8 -*-
#VERSION: 1.2
#AUTHORS: Davy39 <davy39@hmamail.com>, Danfossi <danfossi@itfor.it>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft

from __future__ import print_function

import os
import tempfile
import webbrowser
try:
    # python2
    import urllib2 as request
    from cookielib import CookieJar
    from HTMLParser import HTMLParser
    from urllib import urlencode
except ImportError:
    # python3
    from urllib import request
    from http.cookiejar import CookieJar
    from html.parser import HTMLParser
    from urllib.parse import urlencode

from helpers import retrieve_url
from novaprinter import prettyPrinter


class t411(object):

###########  !!!!!  CHANGE ME  !!!!!! #############
                                                ###
    # your identifiant on t411.ch:              ###
    username = 'Your_User'                      ###
    # and your password:                        ###
    password = 'Your_Pass'                      ###
                                                ###
###################################################

    domain = 'www.t411.ch'
    url = 'http://{}'.format(domain)
    name = 'T411 (french - need login)'
    supported_categories = {
        'all': [''],
        'anime': ['cat=210&subcat=455', 'cat=210&subcat=637'],
        'games': ['cat=624', 'cat=340'],
        'movies': ['cat=210&subcat=631'],
        'tv': ['cat=210&subcat=433'],
        'music': ['cat=395&subcat=623'],
        'software': ['cat=233'],
        'books': ['cat=404']
    }
    cookie_values = {
        'login': username, 'password': password,
        'remember': '1', 'url': '/'
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleHTMLParser(self.results, self.url)

    def _sign_in(self):
        cj = CookieJar()
        self.opener = request.build_opener(request.HTTPCookieProcessor(cj))
        post_params = urlencode(self.cookie_values).encode('utf8')
        url_cookie = self.opener.open(self.url + '/users/login/', post_params)

    def download_torrent(self, url):
        self._sign_in()
        opener = self.opener
        # Open browser if login fail
        try:
            response = opener.open(url)
        except request.URLError as e:
            webbrowser.open(url, new=2, autoraise=True)
            return
        if response.geturl() == url:
            dat = response.read()
            file, path = tempfile.mkstemp(".torrent")
            file = os.fdopen(file, "wb")
            file.write(dat)
            file.close()
            print(path, url)
        else:
            webbrowser.open(url, new=2, autoraise=True)
            return

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results, url, *args):
            HTMLParser.__init__(self)
            self.url = url
            self.td_counter = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            if tag == 'a':
                self.start_a(attr)
            elif tag == 'td':
                self.start_td(attr)

        def start_a(self, attr):
            params = dict(attr)
            if 'href' in params and params['href'].startswith("//{}/torrents".format(t411.domain)):
                self.current_item = {}
                self.td_counter = 0
                self.current_item['desc_link'] = 'http:' + params['href'].strip()
                self.current_item['name'] = params['title'].strip()
            if 'href' in params and params['href'].startswith("/torrents/nfo/"):
                torrent_path = params['href'].strip().replace('/torrents/nfo/', '/torrents/download/')
                self.current_item['link'] = self.url + torrent_path

        def handle_data(self, data):
            if self.td_counter == 4:
                if 'size' not in self.current_item:
                    self.current_item['size'] = ''
                self.current_item['size'] += data.strip()
            elif self.td_counter == 6:
                if 'seeds' not in self.current_item:
                    self.current_item['seeds'] = ''
                self.current_item['seeds'] += data.strip()
            elif self.td_counter == 7:
                if 'leech' not in self.current_item:
                    self.current_item['leech'] = ''
                self.current_item['leech'] += data.strip()

        def start_td(self, attr):
            if isinstance(self.td_counter, int):
                self.td_counter += 1
                if self.td_counter > 7:
                    self.td_counter = None
                    if self.current_item:
                        self.current_item['engine_url'] = self.url
                        if not self.current_item['seeds'].isdigit():
                            self.current_item['seeds'] = 0
                        if not self.current_item['leech'].isdigit():
                            self.current_item['leech'] = 0
                        prettyPrinter(self.current_item)
                        self.results.append('a')

    def search(self, what, cat='all'):
        for page in range(100):
            results = []
            parser = self.SimpleHTMLParser(results, self.url)
            data = ''
            for t411_cat in self.supported_categories[cat]:
                path = ('/torrents/search/?{}&search={}&order=seeders&type=desc&page={}'
                        .format(t411_cat, what, page))
                data += retrieve_url(self.url + path)
            parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break

EOF_2389742934
}


### torrent9

print_torrent9() {
cat <<\EOF_2389742934
# -*- coding: utf-8 -*-
#VERSION: 1.2
#AUTHOR: Davy39 <davy39@hmamail.com>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft

from __future__ import print_function

import re
try:
    # python2
    from HTMLParser import HTMLParser
except ImportError:
    # python3
    from html.parser import HTMLParser

from helpers import download_file, retrieve_url
from novaprinter import prettyPrinter


class torrent9(object):
    url = "http://www.torrent9.tv"
    name = "Torrent9 (french)"
    supported_categories = {
        "all": [""],
        "books": ["ebook/"],
        "movies": ["films/"],
        "tv": ["series/"],
        "music": ["musique/"],
        "software": ["logiciels/"],
        "games": ["jeux-pc/", "jeux-consoles/"]
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleHTMLParser(self.results)

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results):
            HTMLParser.__init__(self)
            self.td_counter = None
            self.current_item = None
            self.collect_seeds = False
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'span', 'td'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            if params.get('href', '').startswith('/torrent/') and 'title' in params:
                self.current_item = {}
                self.td_counter = 0
                self.current_item['engine_url'] = torrent9.url
                desc_path = params['href'].strip()
                self.current_item['desc_link'] = torrent9.url + desc_path
                self.current_item['link'] = (
                    torrent9.url
                    + desc_path.replace('/torrent/', '/get_torrent/')
                    + '.torrent'
                )
                self.current_item['name'] = ''

        def start_span(self, data):
            if self.current_item and self.td_counter == 2:
                self.collect_seeds = True

        def start_td(self, data):
            if self.current_item:
                self.td_counter += 1

        def handle_data(self, data):
            if self.current_item and isinstance(self.td_counter, int):
                if self.td_counter == 0 and data:
                    self.current_item['name'] += data
                elif self.td_counter == 1 and 'size' not in self.current_item:
                    self.current_item['size'] = unit_fr2en(data.strip())
                elif self.collect_seeds:
                    self.collect_seeds = False
                    self.current_item['seeds'] = data.strip()
                elif self.td_counter == 3 and 'leech' not in self.current_item:
                    self.current_item["leech"] = data.strip()

        def handle_endtag(self, tag):
            if self.current_item and tag == 'tr':
                self.current_item['name'] = self.current_item.get('name', '').strip()
                prettyPrinter(self.current_item)
                self.results.append('a')
                self.current_item = None

    def search(self, what, cat="all"):
        for page in range(35):
            results = []
            parser = self.SimpleHTMLParser(results)
            for subcat in self.supported_categories[cat]:
                data = retrieve_url(
                    '{}/search_torrent/{}{}/page-{},trie-seeds-d'
                    .format(self.url, subcat, what, page)
                )
                parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break


def unit_fr2en(size):
    """Convert french size unit to english"""
    return re.sub(
        r'([KMGTP])o',
        lambda match: match.group(1) + 'B',
        size, flags=re.IGNORECASE
    )

EOF_2389742934
}



##### Lancement du script !

intro
