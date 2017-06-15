# firewall

# First activate the reset firewall 

add into crontab 

#*/5 * * * * /root/resetfw.sh >/dev/null 2>&1

# Lauch firewall

exit server and try to reconnect. If not then setting are not good. wait 5 minutes and reconnect and update firewall setting
If all is ok then comment script into crontab
