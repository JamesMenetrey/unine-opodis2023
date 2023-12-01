# case 1 or 2?
runcase=$1

if [ $runcase -eq 1 ]
then
    echo "Starting clients for case 1"
    ./case_1/case_1 > results/latency.csv &
    case_pid=$!
fi
if [ $runcase -eq 2 ]
then
    echo "Starting clients for case 2 (message rate scaling)"
    ./case_2/message_rate_scaling &
    case_pid=$!
fi
if [ $runcase -eq 3 ]
then
    echo "Starting clients for case 3 (subscriber scaling)"
    ./case_2/subscriber_scaling &
    case_pid=$!
fi
if [ $runcase -eq 4 ]
then
    echo "Starting clients for case 2 (publisher scaling)"
    ./case_2/publisher_scaling &
    case_pid=$!
fi

# wait for the kill signal, then send the kill signal to the case
trap "echo 'Killing case'; kill -SIGINT $case_pid; exit;" SIGINT

wait $case_pid

exit 0