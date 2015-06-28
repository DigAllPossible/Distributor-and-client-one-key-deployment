#!/bin/bash
#
# All of the machine shoud have the same root password,if it is not,you should change the scripts ,create a ip:root password file,use awk to get each useful var,and sshdport .by mr.zhou www.z-dig.com
#
. /etc/init.d/functions
# Define clientip "distributed client ip address,like:ip,ip,ip"

clientip=172.16.1.101,172.16.1.10,172.16.1.20,172.16.1.110,172.16.1.200

# Define username "distribute user (a normal user)"

username=distribute

# Define userpassword "distribute user's password"

userpassword=123456

# Define all machine 's root password (all root should have the same password)

rootpassword=localroot

# Define sshd port

sshdport=22

# Define expect timeout 

timeout=1

# Define distribute_sskeygen.exp and distribute_client.exp file path
sshkeygen_file=/server/scripts/distribute/distribute_sshkeygen.exp
client_file=/server/scripts/distribute/distribute_client.exp

# Create sudo script for distribute client
/bin/echo -e "#!/bin/bash\n/bin/echo \"$username ALL=(ALL) NOPASSWD:/bin/cp\">>/etc/sudoers" >/tmp/sudo.sh&&\

# Add local user
/usr/bin/id $username &>/dev/null
if [[ "$?" == "0" ]]
 then
  echo "local user $username already exists!"
  exit 1
fi
/usr/bin/which expect &>/dev/null
if [[ "$?" != "0" ]]
 then
  echo 'expect not installed ! you can use "yum -y install expect" to install expect.'
  exit 1
fi
/usr/sbin/useradd $username&&\
/bin/echo $userpassword|/usr/bin/passwd --stdin $username &>/dev/null &&\
/usr/bin/expect $sshkeygen_file $username $timeout &>/dev/null
for ip in `echo $clientip|tr "," "\n"`
 do
  /usr/bin/expect $client_file $ip $rootpassword $username $userpassword $timeout $sshdport &>/dev/null

/bin/ls -1v /tmp|/bin/grep distribute_check|/bin/awk -F "_" '{print $NF}'>/tmp/successip.txt&&\
/bin/grep -e "\b$ip\b" /tmp/successip.txt&>/dev/null
 if [[ "$?" == "0" ]]
   then
    action "$ip  initialization succeed !" /bin/true
   else
    action "$ip  initialization failed ! " /bin/false
 fi
done
rm -f /tmp/distribute_check*
rm -f /tmp/sudo.sh
rm -f /tmp/successip.txt
echo "Dig All Possible www.z-dig.com by mr.zhou"
