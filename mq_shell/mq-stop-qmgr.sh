set -e

endmqm ${MQ_QMGR_NAME}
which endmqweb && su -c "endmqweb" -l mqm
