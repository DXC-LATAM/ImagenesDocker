set -e
mq-license-check.sh
echo "----------------------------------------"
source mq-parameter-check.sh
echo "----------------------------------------"
setup-var-mqm.sh
echo "----------------------------------------"
which strmqweb && source setup-mqm-web.sh
echo "----------------------------------------"
mq-pre-create-setup.sh
echo "----------------------------------------"
source mq-create-qmgr.sh
echo "----------------------------------------"
source mq-start-qmgr.sh
echo "----------------------------------------"
source mq-configure-qmgr.sh
echo "----------------------------------------"
exec mq-monitor-qmgr.sh ${MQ_QMGR_NAME}
