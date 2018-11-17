MQ_QMGR_NAME=$1

state()
{
  dspmq -n -m ${MQ_QMGR_NAME} | awk -F '[()]' '{ print $4 }'
}

trap "source mq-stop-container.sh" SIGTERM SIGINT

echo "Monitoring Queue Manager ${MQ_QMGR_NAME}"

# Loop until "dspmq" says the queue manager is running
until [ "`state`" == "RUNNING" ]; do
  sleep 1
done
dspmq

echo "IBM MQ Queue Manager ${MQ_QMGR_NAME} is now fully running"

# Loop until "dspmq" says the queue manager is not running any more
until [ "`state`" != "RUNNING" ]; do
  sleep 5
done

# Check that dspmq did actually work in case something has gone seriously wrong.
dspmq > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: dspmq finished with a non-zero return code"
  exit 1
fi

# Wait until queue manager has ended before exiting
while true; do
  STATE=`state`
  case "$STATE" in
    ENDED*) break;;
    *) ;;
  esac
  sleep 1
done
dspmq
