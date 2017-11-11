echo "***************************"
echo " "
echo "Hello $USER"
echo " "
echo "***************************"
sudo timedatectl set-timezone Europe/Helsinki
setxkbmap fi
sudo apt update
sudo apt install -y git tree puppet

git clone https://github.com/marrkus/ssh-for-puppet.git

cd ssh-for-puppet/Puppet/modules
sudo cp -r ssh/ /etc/puppet/modules/
cd /etc/puppet/

sudo puppet apply --modulepath modules/ -e 'class {"ssh":}'

cd

echo "***************************"
echo " "
echo "Ready to use"
echo " "
echo "***************************"
