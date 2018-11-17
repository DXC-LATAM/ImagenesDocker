set -e

# We want to do parameter checking early as then we can stop and error early before it looks
# like everything is going to be ok (when it won't)
if [ ! -z ${MQ_TLS_KEYSTORE+x} ]; then
  : ${MQ_TLS_PASSPHRASE?"Error: If you supply MQ_TLS_KEYSTORE, you must supply MQ_TLS_PASSPHRASE"}
fi

if [ -z ${MQ_QMGR_NAME+x} ]; then
  # no ${MQ_QMGR_NAME} supplied so set Queue Manager name as the hostname
  # However make sure we remove any characters that are not valid.
  echo "Hostname is: $(hostname)"
  MQ_QMGR_NAME=`echo $(hostname) | sed 's/[^a-zA-Z0-9._%/]//g'`
  echo "Setting Queue Manager name to ${MQ_QMGR_NAME}"
fi
