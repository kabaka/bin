cd ~/downloads/sitemirrors/$1/

wget -w 10 --random-wait -nv -nc -np -U "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.9) Gecko/20100908 Firefox/3.6.9" -A $1 -r $2

echo $2 && alert

