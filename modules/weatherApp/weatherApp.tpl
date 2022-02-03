#!/bin/bash
cd /opt
sudo mkdir fhb
cd fhb
sudo chmod 777 /opt/fhb/

sudo yum update -y
#install java 11
sudo yum install java-11 -y
#install git
sudo yum install git -y
#install software for cerbot
sudo amazon-linux-extras install epel -y
sudo yum-config-manager --enable epel -y
sudo yum install certbot -y

#get github cli
curl -sSL https://github.com/cli/cli/releases/download/v2.5.0/gh_2.5.0_linux_amd64.tar.gz -o gh_2.5.0_linux_amd64.tar.gz
tar xvf gh_2.5.0_linux_amd64.tar.gz
sudo cp gh_2.5.0_linux_amd64/bin/gh /usr/local/bin/
#login at github cli
echo ${GITHUB_API_TOKEN} | gh auth login --with-token

#get fsuweatherapi build from github
gh run download -n Package -R 2110781006/fsuWeatherRestApi

#start fsuWeatherRestApi application
java -jar openapi-spring-1.0.0.jar ${WEATHERSTACK_API_TOKEN} temp1 temp2 temp3 temp4 temp5 > log.txt &

#wait for elb
sleep 120

#get public ip address
export PUBLIC_IPV4_ADDRESS=$(ping -q -c1 -t1 ${PUBLIC_DNS_ADDRESS} | grep -Eo "([0-9]+\.+[0-9]+\.?){2}")
echo $PUBLIC_IPV4_ADDRESS > publicIp.txt

#create self cert certificates
sudo certbot certonly --standalone --preferred-challenges http -d $PUBLIC_IPV4_ADDRESS.nip.io --staging --noninteractive --agree-tos --email m.s.jun@aon.at >> /opt/fhb/letencryptLog.txt

mkdir -p /tmp/oauth2-proxy
sudo mkdir -p /opt/oauth2-proxy
cd /tmp/oauth2-proxy

#download oauth
curl -sfL https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.1.3/oauth2-proxy-v7.1.3.linux-amd64.tar.gz | tar -xzvf -

sudo mv oauth2-proxy-v7.1.3.linux-amd64/oauth2-proxy /opt/oauth2-proxy/

export COOKIE_SECRET=$(python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())')

export GITHUB_USER=${GITHUB_USER}
export GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
export GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
export PUBLIC_URL=$PUBLIC_IPV4_ADDRESS.nip.io

export PUBLIC_FULL_URL=https://$PUBLIC_URL/swagger-ui.html

cd /opt/fhb/
echo $PUBLIC_FULL_URL > PUBLIC_FULL_URL.txt
# post new url on github
#gh repo clone 2110781006/fsuWeatherRestApi fsuWeatherRestApi
#cd fsuWeatherRestApi
#gh issue create -b "aaaaaaa" -t "newUrl1"

#gh issue create -b bbb -t newUrl2 -R 2110781006/fsuWeatherRestApi
gh issue create -b $PUBLIC_FULL_URL -t newUrl -R 2110781006/fsuWeatherRestApi
touch after.txt
#start oauth
sudo /opt/oauth2-proxy/oauth2-proxy --github-user=$GITHUB_USER  --cookie-secret=$COOKIE_SECRET --client-id=$GITHUB_CLIENT_ID --client-secret=$GITHUB_CLIENT_SECRET --email-domain="*" --upstream=http://127.0.0.1:8080 --provider github --cookie-secure false --redirect-url=https://$PUBLIC_URL/oauth2/callback --https-address=":443" --force-https --tls-cert-file=/etc/letsencrypt/live/$PUBLIC_URL/fullchain.pem --tls-key-file=/etc/letsencrypt/live/$PUBLIC_URL/privkey.pem > /opt/fhb/oauthLog.txt