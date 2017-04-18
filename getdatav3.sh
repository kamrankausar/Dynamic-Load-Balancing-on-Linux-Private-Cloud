c=0

for k in `cat ./data/nodeinfo`
do 
cat /dev/null > ./data/$k.vm
ssh root@$k top -c -bn 1 |grep /usr/bin/kvm |grep -v "grep" |awk '{print $1,",",$9}' > ./data/tmp_pid
ssh root@$k ps -ef|grep /usr/bin/kvm |grep -v "grep" |awk '{print $2,",",$18}' > ./data/tmp_vm

for i in `cat ./data/tmp_pid| awk '{print $1}'`
do
cpu=$(grep $i ./data/tmp_pid|awk -F, '{print $2}')
vm=$(grep $i ./data/tmp_vm|awk -F, '{print $2}')
echo $cpu, $vm >>./data/$k.vm
done

done
