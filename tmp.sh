work_trf=41.4

k=0
for i in $(cat ./data/nodes.high |awk -F, '{print $2}')
do
if [ $(echo "$i < $work_trf"|bc) -eq 1 ] && [ $(echo "$i > $k"|bc) -eq 1 ] 
then
k=$i
fi
done
echo $k
grep $k ./data/nodes.high|head -1

