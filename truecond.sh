#! /bin/sh

utime=`echo ICT-7 > /etc/TZ`
sleep 10

trueusername='username'
truepassword='password'

logout() {
    curl --user-agent "Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0" --cookie /tmp/cookiejar.txt --cookie-jar /tmp/cookiejar.txt --insecure "https://portal.trueinternet.co.th/wifiauthen/logout_result.php"
}

logout_para() {
    curl --user-agent "Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0" --cookie /tmp/cookiejar.txt --cookie-jar /tmp/cookiejar.txt --connect-timeout 5 --location --insecure --data "param=$parameter" 'https://portal.trueinternet.co.th/wifiauthen/web/wifi-logout-success.php?param=$parameter'
}

login() {
    param=$(curl -iI www.google.com |grep login |sed -e 's/.*login.do?//')
    parameter=$(curl --user-agent "Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0" --location --cookie /tmp/cookiejar.txt --cookie-jar /tmp/cookiejar.txt --insecure "https://portal.trueinternet.co.th/wifiauthen/login.do?$param" | grep param= | sed -e 's/.*param=//' -e 's/\".*>//')
    curl --user-agent "Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0" --location --cookie /tmp/cookiejar.txt --cookie-jar /tmp/cookiejar.txt  --insecure "https://portal.trueinternet.co.th/wifiauthen/web/wifi-login.php?param=$parameter"
    curl --user-agent "Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0" --referer "https://portal.trueinternet.co.th/wifiauthen/login.php" --cookie /tmp/cookiejar.txt --cookie-jar /tmp/cookiejar.txt --data "username=$trueusername&password=$truepassword&param=$parameter" --insecure "https://portal.trueinternet.co.th/wifiauthen/login_result.php"
}

logout
login
sleep 5
while [ 1 ]; do
    #check web external site
    up=`curl 'www.google.com/search?q=ip' | grep 'Client IP address:'`
    if [ "$up" ]; then
        # synctime to avoid crontab time missing
        sync=`ntpdate ntp.ubuntu.com`
        # delay for 175 minute which is default truewifi disconnect every 180 minute
        sleep 10500
        logout
        logout_para
        login
    else
        logout
        logout_para
        login
    fi
    sleep 2
    rm /tmp/cookiejar.txt
    rm /tmp/ip.txt
done
