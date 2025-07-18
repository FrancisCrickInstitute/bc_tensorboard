# wait for the Tensorboard server to start
echo "$(date): waiting for Tensorboard server to open port ${app_port}..."

if wait_until_port_used "127.0.0.1:${port}" 300; then
    echo "$(date): discovered Tensorboard server listening on port ${app_port}!"

    # wait for the authenticating proxy to start
    echo "$(date): waiting for authrevproxy server to open port ${proxy_port}..."

    if wait_until_port_used "${node}:${proxy_port}" 60; then
        echo "$(date): discovered authrevproxy server listening on port ${proxy_port}!"
    fi

else
  echo "$(date): timed out waiting for Tensorboard server to open port ${app_port}!"
  echo "- wait ended at: $(date)"
  pkill -P ${SCRIPT_PID}
  clean_up 1
fi

APPPORT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:${app_port})
TIME=0

while [[ "$APPPORT_RESPONSE" -ge 400  ||  "$APPPORT_RESPONSE" -le 99 ]]
do 
 sleep 1
 let TIME+=1
 APPPORT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:${app_port})
 if [ $TIME -gt 180 ]
 then
   echo "Tensorboard session timed out"
   break
 fi

done
