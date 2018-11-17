set -e

if [ ${MQ_QMGR_CMDLEVEL+x} ]; then
  # Enables the specified command level, then stops the queue manager
  strmqm -e CMDLEVEL=${MQ_QMGR_CMDLEVEL} || true
fi

strmqm ${MQ_QMGR_NAME}
