#Housekeeping
#clear
echo "Start time :"; date

echo "####### Cleaning up last run data ########"
echo "done!"

cat /dev/null>./data/engine.log
cat /dev/null>./data/node_cpu.log
c=0;thrs=0;max=0;min=100;diff=0;

./getdatav3.sh &


echo "######## Retrieving Private Cloud Performance Data (Hosts and their VMs) #########"

##Getting Host Performance Data

for i in `cat ./data/nodeinfo`
do
cpu=$(ssh root@$i mpstat 1 10|tail -1 |awk -F" " '{print 100 - $11}')
echo $i,$cpu >>./data/node_cpu.log
thrs=`echo $thrs + $cpu | bc -l`
c=`echo $c + 1|bc`
if [ $(echo "$max < $cpu"|bc) -eq 1 ]; then max=$cpu; fi
if [ $(echo "$cpu < $min"|bc) -eq 1 ]; then min=$cpu;fi
done


thrs=`echo "scale=2; $thrs / $c"|bc`
mean=`echo "scale=2;($max + $min)/2"|bc`
if [ $(echo "$thrs > $mean"|bc) -eq 1 ]; then diff=$(echo "scale=2;$thrs - $mean"|bc); else diff=$(echo "scale=2;$mean - $thrs"|bc);fi
if [ $(echo "$diff < 10"|bc) -eq 1 ];then diff=10;fi
if [ $(echo "$thrs < $diff"|bc) -eq 1 ]; then thrs_low=0;else thrs_low=$(echo "scale=2;$thrs - $diff"|bc); fi
thrs_high=$(echo "scale=2;$thrs + $diff"|bc );
cat ./data/node_cpu.log >>./data/engine.log
echo thrs,mean,diff,min,max >> ./data/engine.log
echo $thrs,$mean,$diff,$min,$max >>./data/engine.log
echo -e "Middle Band \n" >>./data/engine.log
echo $thrs_low, $thrs_high >> ./data/engine.log
cat /dev/null > ./data/nodestatus
echo "done!"


echo "####### Separating Hosts based on load into High/Medium/Low groups #######" 
while read line
do
node=`echo $line|awk -F, '{print $1}'`
cpu=`echo $line|awk -F, '{print $2}'`
if [ $(echo "$cpu <= $thrs_low"|bc) -eq 1 ]; then echo $node,lowband >>./data/nodestatus;fi
if [ $(echo "$cpu <= $thrs_high"|bc) -eq 1 ] && [ $(echo "$cpu > $thrs_low"|bc) -eq 1 ]; then echo $node,midband >>./data/nodestatus;fi
if [ $(echo "$cpu > $thrs_high"|bc) -eq 1 ]; then echo $node,highband>>./data/nodestatus;fi
done < ./data/node_cpu.log
echo "done!!!"

grep low ./data/nodestatus >/dev/null
chk1=$(echo $?)
grep high ./data/nodestatus >/dev/null
chk2=$(echo $?)
if [ $chk1 -ne 0 ] || [ $chk2 -ne 0 ]
then
echo "No High/Low Host Present. Quitting !"
exit
fi

cat /dev/null >./data/nodes.low
cat /dev/null >./data/nodes.high
c=100
grep low ./data/nodestatus |awk -F, '{print $1}'>./data/nodes.low
for i in $(cat ./data/nodes.low)
do
use=$(grep $i ./data/node_cpu.log|awk -F, '{print $2}')
#echo $i,$use
if [ $(echo "$use < $c"|bc) -eq 1 ]
then
c=$use
fi
done
node_free=$(grep $c ./data/node_cpu.log|awk -F"," '{print $1}'|head -1)
work_trf=$(echo $thrs - $c + 10 |bc )
echo work_trf=$work_trf >>./data/engine.log
#### most free node selected
### now mixing all vms from high nodes
for hnodes in $(grep high ./data/nodestatus |awk -F, '{print $1}')
do
while read line
do
echo $hnodes,$line >>./data/nodes.high
done < ./data/$hnodes.vm
done
##done mixing highnodes/vmnamees and vmcpu

echo $node_free,$c


k=0
for i in $(cat ./data/nodes.high |awk -F, '{print $2}')
do
if [ $(echo "$i < $work_trf"|bc) -eq 1 ] && [ $(echo "$i > $k"|bc) -eq 1 ] 
then
k=$i
fi
done
if [ $(echo "$k != 0"|bc) -eq 1 ]
then
vm_mov=$(grep $k ./data/nodes.high|head -1 |awk -F"," '{print $3}')
node_mov=$(grep $k ./data/nodes.high|head -1 |awk -F"," '{print $1}')
else
echo "No VM suitable for migration. Quitting !"
exit
fi
echo "VM = $vm_mov will be migrated from $node_mov to $node_free"

echo "VM running on Source Host : " $node_mov
ssh $node_mov virsh list
echo "VMs running on Destination Host : " $node_free
ssh $node_free virsh list
ssh $node_mov virsh migrate $vm_mov qemu+tcp://root@$node_free/system
if [ $? -eq 0 ]
then 
echo "Migration Successful"
echo "VMs running on Source Host :" $node_mov
ssh $node_mov virsh list
echo "VMs running on Destination Host : " $node_free
ssh $node_free virsh list
fi
                                                                                                         
