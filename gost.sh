#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/gost.sh | bash

export green='\033[0;32m'
export plain='\033[0m'

export URL="https://raw.githubusercontent.com/mixool/script/source/gost"
export NAME="gost"
export DO="-L=http+kcp://:11000"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo "Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "Generate /etc/init.d/$NAME.sh"
cat <<EOF > /etc/init.d/$NAME.sh
#!/bin/sh

### BEGIN INIT INFO
# Provides: $NAME
# Required-Start: $network
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop $NAME
# Description: $NAME
### END INIT INFO

nohup /root/$NAME $DO >/dev/null 2>&1 &
EOF

chmod +x /etc/init.d/$NAME.sh
cd /etc/init.d
update-rc.d $NAME.sh defaults 97
