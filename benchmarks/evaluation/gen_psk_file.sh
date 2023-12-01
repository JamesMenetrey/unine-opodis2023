cd certs/

rm psk_file.txt
for i in {0..30000}
do
    prefix="AAAAAAAAAAAAAAABCDEF"
    psk="${prefix}${i}"
    psk="${psk: -20}"
    echo "client_$i:$psk" >> psk_file.txt
done