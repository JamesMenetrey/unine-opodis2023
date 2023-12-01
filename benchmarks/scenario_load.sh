rm -r logs
mkdir logs

nb_subscribers_per_topic=${1:-5}
nb_messages_per_topic=${2:-5}

echo -e "\e[32mNumber of subscribers per topic $nb_subscribers_per_topic\e[0m"
echo -e "\e[32mNumber of messages per topic $nb_messages_per_topic\e[0m"

# replace {{HOST}} in mosquitto.conf with hostname
cp mosquitto.conf.template.load mosquitto.conf
sed -i "s/{{HOST}}/$(hostname)/g" mosquitto.conf

# run broker
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto -c mosquitto.conf &
broker_pid=$!
pids=()

# wait for broker to start
sleep 5

echo -e "\e[32mCreate $nb_subscribers_per_topic subscribers for general topic 'test'.\e[0m"
for i in $(seq 1 $nb_subscribers_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/# -h $(hostname) > logs/log_out_general_$i.txt &
    pid=$!
    pids+=($pid)
done

sleep 5

echo -e "\e[32mCreate $nb_subscribers_per_topic subscribers for topic 'test/a'.\e[0m"
for i in $(seq 1 $nb_subscribers_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/a -h $(hostname) > logs/log_out_a_$i.txt &
    pid=$!
    pids+=($pid)
done

sleep 5

echo -e "\e[32mCreate $nb_subscribers_per_topic subscribers for topic 'test/b'.\e[0m"
for i in $(seq 1 $nb_subscribers_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/b -h $(hostname) > logs/log_out_b_$i.txt &
    pid=$!
    pids+=($pid)
done

sleep 5

echo -e "\e[32mPublish to 'test/c'.\e[0m"
for i in $(seq 1 $nb_messages_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/c -h $(hostname) -m "test message $i to test/c"
done

sleep 5

echo -e "\e[32mPublish to 'test/a'.\e[0m"
for i in $(seq 1 $nb_messages_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/a -h $(hostname) -m "test message $i to test/a"
done

sleep 5

echo -e "\e[32mPublish to 'test/b'.\e[0m"
for i in $(seq 1 $nb_messages_per_topic)
do
    ./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8883 --cafile certs/ca.crt --key certs/sub_client.key --cert certs/sub_client.crt -t test/b -h $(hostname) -m "test message $i to test/b"
done

sleep 20

for pid in ${pids[@]}
do
    kill $pid > /dev/null
done

echo "Kill broker"
kill $broker_pid > /dev/null

rm mosquitto.conf