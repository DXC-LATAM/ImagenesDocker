set -e

source /opt/mqm/bin/setmqenv -s
dspmqver
echo "Checking filesystem..."
amqmfsck /var/mqm
