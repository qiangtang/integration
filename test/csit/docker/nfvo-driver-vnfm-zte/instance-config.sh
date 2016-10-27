# Configure MSB IP address
MSB_IP=`echo $MSB_ADDR | cut -d: -f 1`
MSB_PORT=`echo $MSB_ADDR | cut -d: -f 2`
sed -i "s|MSB_SERVICE_IP.*|MSB_SERVICE_IP = '$MSB_IP'|" nfvo/drivers/vnfm/svnfm/zte/vmanager/driver/pub/config/config.py
sed -i "s|MSB_SERVICE_PORT.*|MSB_SERVICE_PORT = '$MSB_PORT'|" nfvo/drivers/vnfm/svnfm/zte/vmanager/driver/pub/config/config.py
sed -i "s|\"ip\": \".*\"|\"ip\": \"$SERVICE_IP\"|" nfvo/drivers/vnfm/svnfm/zte/vmanager/driver/pub/config/config.py
cat nfvo/drivers/vnfm/svnfm/zte/vmanager/driver/pub/config/config.py

sed -i "s|127\.0\.0\.1|$SERVICE_IP|" nfvo/drivers/vnfm/svnfm/zte/vmanager/run.sh
sed -i "s|127\.0\.0\.1|$SERVICE_IP|" nfvo/drivers/vnfm/svnfm/zte/vmanager/stop.sh
