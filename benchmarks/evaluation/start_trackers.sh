tracker_pids=()

# start the tracker for nb of received and sent messages
./case_2/subscriber bytes_received 0 \$SYS/broker/load/bytes/received/1min &
tracker_pids+=($!)
./case_2/subscriber bytes_sent 0 \$SYS/broker/load/bytes/sent/1min &
tracker_pids+=($!)
./case_2/subscriber messages_received 0 \$SYS/broker/load/messages/received/1min &
tracker_pids+=($!)
./case_2/subscriber messages_sent 0 \$SYS/broker/load/messages/sent/1min &
tracker_pids+=($!)
./case_2/subscriber publish_dropped 0 \$SYS/broker/load/publish/dropped/1min &
tracker_pids+=($!)
./case_2/subscriber publish_received 0 \$SYS/broker/load/publish/received/1min &
tracker_pids+=($!)
./case_2/subscriber publish_sent 0 \$SYS/broker/load/publish/sent/1min &
tracker_pids+=($!)
./case_2/subscriber heap_max 0 \$SYS/broker/heap/maximum &
tracker_pids+=($!)
./case_2/subscriber heap_current 0 \$SYS/broker/heap/current &
tracker_pids+=($!)

exit 0