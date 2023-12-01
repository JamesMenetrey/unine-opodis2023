rm -r results
mkdir results

evaluation_case=$1
evaluation_case_name=$2

if [ -z $evaluation_case ] || [ $evaluation_case -lt 1 ] || [ $evaluation_case -gt 4 ]
then
    echo "Invalid evaluation case"
    exit 1
fi

if [ -z "$evaluation_case_name" ]
then
    echo "No evaluation case name defined"
    exit 1
fi

tracker_pid=0
if [ $evaluation_case -gt 1 ]
then
    ./start_trackers.sh &
    tracker_pid=$!
    echo ">>> Tracker Started, PID: $tracker_pid"
fi

sleep 2

./start_clients.sh $1 &
clients_pid=$!
echo ">>> Clients Started, PID: $clients_pid"

# declare function called "sig_handler"
sig_handler() {
    kill -SIGINT $clients_pid
    pkill -f case_2* --signal 2
}
# wait for the kill signal, then send the kill signal to the case
trap "sig_handler ;" SIGINT

wait $clients_pid
pkill -f case_2* --signal 2
sleep 15
cp -r results results_${evaluation_case_name}