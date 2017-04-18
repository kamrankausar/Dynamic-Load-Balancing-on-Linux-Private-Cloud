clear
echo
echo
echo " __________________________________________________________________________________________________________________"
echo "|******************************************************************************************************************|"
echo "|***********************************_______________________********************************************************|"
echo "|##################################|    INSTALLER FOR      |#######################################################|" 
echo "|##################################| DYNAMIC LOAD BLANCING |#######################################################|"
echo "|##################################|        ON             |#######################################################|"
echo "|##################################| LINUX PRIVATE CLOUD   |#######################################################|"
echo "|***********************************-----------------------********************************************************|"
echo "|******************************************************************************************************************|"
echo "|------------------------------------------------------------------------------------------------------------------|"
echo
echo "	Here are the Pre-Requisites to implement this Project"
echo -e "\nThese are\n 
	1. Machine support virtualization features i.e one of the CPU flag is VMX or SVM 
	2. Installation of KVM. 
	3. Installation of QEMU.
	4. Passwordless SSH configured between  Server and Client node.   
	5. Libvirtd TCP remote URI 16501 
	6. All nodes have configured Shared storage by NFS." 
echo    "Are Your Pre-Requisites configured Correctly? Enter Y/N"
read a
if [ "$a" == "y" ] || [ "$a" == "Y" ]
then 
echo 	"Enter the number node in your  Cluster on which this has to be implement"
read node_total
echo 	"Enter the name of the node One by One"
c=0
cat /dev/null>./data/nodeinfo
while [ $c -lt $node_total ]
do 
read nodename
echo -e $nodename >>./data/nodeinfo
c=`expr $c + 1`
done
echo
echo "Node names are  successfuly Enter"
echo
else 
cat /dev/null>./data/nodeinfo
echo 	"Quitting!!! " System is not configured Correctly""
echo
fi
