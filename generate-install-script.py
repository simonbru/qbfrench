#!/usr/bin/env python

"""Inline tracker plugins into the install script"""

import os

TRACKERS = ['cpasbien', 'smartorrent', 't411', 'torrent9']

function_template = """
### %s

print_%s() {
cat <<\EOF_2389742934
%s
EOF_2389742934
}

"""


def main():
    os.chdir(os.path.dirname(__file__))
    with open('qbfrench-install.sh.template') as f:
        script_template = f.read()

    inline_content = ''
    for tracker in TRACKERS:
        with open(tracker + '.py') as f:
            tracker_content = f.read()
        inline_content += function_template % (tracker, tracker, tracker_content)

    script = script_template.replace('{{INLINE_SCRIPTS}}', inline_content)
    with open('qbfrench-install.sh', 'w') as f:
        f.write(script)



if __name__ == '__main__':
    main()
