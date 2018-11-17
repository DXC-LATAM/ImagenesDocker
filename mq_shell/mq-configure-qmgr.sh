# Turn off script failing here because of listeners failing the script
set +e

for MQSC_FILE in $(ls -v /etc/mqm/*.mqsc); do
  runmqsc ${MQ_QMGR_NAME} < ${MQSC_FILE}
done

# Turn back on script failing here
set -e
