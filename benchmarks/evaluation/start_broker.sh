# first start the broker depending on the input paramter
# 0 = native
# 1 = wasm
# 2 = sgx

brokerType=$1

broker_pid=$(lsof -i TCP:8883 | grep LISTEN | awk '{print $2}')

if [ ! -z $broker_pid ]
then
    echo "Broker already running, PID: $broker_pid, Killing"
    kill $broker_pid
fi

if [ $brokerType -eq 0 ]
then
    echo "Starting native broker"
    ./mosquitto-native -c mosquitto.conf & 
    broker_pid=$!
fi
if [ $brokerType -eq 1 ]
then
    echo "Starting wasm broker"
    ./iwasm --heap-size=100000000 --stack-size=36777216 --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto-wasm.aot -c mosquitto.conf & 
    broker_pid=$!
fi
if [ $brokerType -eq 2 ]
then
    echo "Starting sgx broker"
    /opt/wasm-micro-runtime/product-mini/platforms/linux-sgx/enclave-sample/iwasm --heap-size=100000000 --stack-size=36777216 --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 mosquitto-sgx.aot & 
    broker_pid=$!
fi

trap "kill -SIGINT $broker_pid; exit;" SIGINT

wait $broker_pid