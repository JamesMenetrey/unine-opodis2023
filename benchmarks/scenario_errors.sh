# replace {{HOST}} in mosquitto.conf with hostname
cp mosquitto.conf.template.errors mosquitto.conf
sed -i "s/{{HOST}}/$(hostname)/g" mosquitto.conf
# run broker
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto -c mosquitto.conf &
broker_pid=$!

# wait for broker to start
sleep 5

echo -e "\e[32mClient with expired certificate tries to connect\e[0m"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/ca.crt --cert certs/client_expired.crt --key certs/client_expired.key -t test -h $(hostname)
sleep 2

echo -e "\e[32mClient with invalid certificate tries to connect\e[0m"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/other_ca.crt --cert certs/client_other_ca.crt --key certs/client_other_ca.key -t test -h $(hostname)
sleep 2

echo -e "\e[32mClient rejects expired server cert (client runs in debug mode to see the error)\e[0m"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8884 --cafile certs/ca.crt -t test -d
sleep 2

echo -e "\e[32mClient reject server cert of unknown ca (client runs in debug mode to see the error)\e[0m"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8883 --cafile certs/other_ca.crt -t test -h $(hostname) -d
sleep 2

echo -e "\e[32mClient reject server cert due to failing hostname validation (client runs in debug mode to see the error)\e[0m"
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. mosquitto_sub -p 8885 --cafile certs/ca.crt -t test -h $(hostname) -d
sleep 2


echo "Kill broker"
kill $broker_pid > /dev/null

rm mosquitto.conf