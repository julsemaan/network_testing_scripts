

radload -t 30 -l /dev/shm/xload.log -m 10 -x /root/mock_data.csv -type http -w 4 -- 172.20.20.109/captive-portal

radload -t 30 -l /dev/shm/xload.log -m 10 -x /root/mock_data.csv -type acct -w 5 -- --server=172.20.20.109 --secret=radius

radload -t 30 -l /dev/shm/xload.log -m 10 -x /root/mock_data.csv -type dhcp -w 5

