#!/bin/bash

current_time=$(date "+%Y%m%d%H%M%S")
formatted_time=$(echo $current_time | sed 's/\(....\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/')

echo "Time：$formatted_time" > /root/ruijie/log.txt


sh /root/ruijie/ruijie_jmu.sh campus 202020200123 12345678 >> /root/ruijie/log.txt
# sh /root/ruijie/ruijie_jmu.sh chinanet 202020200123 12345678 >> /root/ruijie/log.txt
# sh /root/ruijie/ruijie_jmu.sh chinamobile 202020200123 12345678 >> /root/ruijie/log.txt
# sh /root/ruijie/ruijie_jmu.sh chinaunicom 202020200123 12345678 >> /root/ruijie/log.txt