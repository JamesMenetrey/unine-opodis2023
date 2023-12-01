# replace {{HOST}} in mosquitto.conf with hostname
cp mosquitto.conf.template.ok mosquitto.conf
sed -i "s/{{HOST}}/$(hostname)/g" mosquitto.conf

# run broker
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto -c mosquitto.conf &
broker_pid=$!

# wait for broker to start
sleep 5

echo -e "\e[32mCreate some valid subscribers.\e[0m"
echo -e "\e[32mNumber of sent messages since broker start will be logged every 5 seconds!.\e[0m"
# run mosquitto_sub on unsecured port on system topic
./iwasm --allow-resolve=*  --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 1888 -t \$SYS/broker/messages/sent &
sub_sys_pid=$!

# run mosquitto sub on test topic with TLS without client certificate on localhost
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8884 --cafile certs/ca.crt -t test & 
sub_without_pid=$!

# run mosquitto sub on test topic with TLS with client certificate on hostname
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/ca.crt -t test --cert certs/sub_client.crt --key certs/sub_client.key -h $(hostname) &
sub_with_pid=$!

sleep 2
echo -e "\e[32mStarting a few publishers...\e[0m"
sleep 2
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8883 --cafile certs/ca.crt --key certs/pub_client.key --cert certs/pub_client.crt -t test -m "Message to test topic with client cert and on localhost"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8883 --cafile certs/ca.crt --key certs/pub_client.key --cert certs/pub_client.crt -t test -m "Message to test topic with client cert and on $(hostname)" -h $(hostname)

sleep 2
echo -e "\e[32mStarting a few publishers without client cert...\e[0m"
sleep 2

./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8884 --cafile certs/ca.crt -t test -m "Message to test topic without client cert and on localhost"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_pub -p 8884 --cafile certs/ca.crt -t test -m "Message to test topic without client cert and on $(hostname)" -h $(hostname)

sleep 2
echo -e "\e[32mNumber of messages sent since broker start: \e[0m"

sleep 5

echo "Kill subscribers"
kill $sub_without_pid > /dev/null
kill $sub_sys_pid > /dev/null
kill $sub_with_pid > /dev/null

echo "Kill broker"
kill $broker_pid > /dev/null

rm mosquitto.conf