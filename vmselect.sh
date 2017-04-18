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
echo "Free'st node is :"  $node_free
#### most free node selected
### now mixing all vms from high nodes
for hnodes in $(grep high ./data/nodestatus |awk -F, '{print $1}')
do
while read line
do
echo $hnodes,$line
done < ./data/$hnodes.vm
done
##done mixing highnodes/vmnamees and vmcpu

