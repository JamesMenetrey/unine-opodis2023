# create random data for publishers
mkdir -p random
cd random
for i in {0..64}
do
    cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-16384} | head -n 23500 > random-$i.txt &
    pid=$!
    wait $pid
done
