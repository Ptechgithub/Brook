#!/bin/bash

#colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

# Check for root user
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Detect the Linux distribution
detect_distribution() {
    local supported_distributions=("ubuntu" "debian" "centos" "fedora")
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "${ID}" = "ubuntu" || "${ID}" = "debian" || "${ID}" = "centos" || "${ID}" = "fedora" ]]; then
            p_m="apt-get"
            [ "${ID}" = "centos" ] && p_m="yum"
            [ "${ID}" = "fedora" ] && p_m="dnf"
        else
            echo "Unsupported distribution!"
            exit 1
        fi
    else
        echo "Unsupported distribution!"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    detect_distribution
    sudo "${p_m}" -y update && sudo "${p_m}" -y upgrade
    local dependencies=("curl" "socat" "openssl")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo -e "${yellow}${dep} is not installed. Installing...${rest}"
            sudo "${p_m}" install "${dep}" -y
        fi
    done
}

# Install nami
install_nami() {
    if ! command -v nami &> /dev/null; then
        os=""
		arch=""
		
		if [ $(uname -s) = "Darwin" ]; then
		    os="darwin"
		fi
		if [ $(uname -s) = "Linux" ]; then
		    os="linux"
		    if [ `cat /etc/*elease 2>/dev/null | grep 'CentOS Linux 7' | wc -l` -eq 1 ]; then
		        echo "Requires CentOS version >= 8"
		        exit;
		    fi
		fi
		if [ $(uname -s | grep "MINGW" | wc -l) -eq 1 ]; then
		    os="windows"
		fi
		
		if [ $(uname -m) = "x86_64" ]; then
		    arch="amd64"
		fi
		if [ $(uname -m) = "arm64" ]; then
		    arch="arm64"
		fi
		if [ $(uname -m) = "aarch64" ]; then
		    arch="arm64"
		fi
		
		if [ "$os" = "" -o "$arch" = "" ]; then
		    echo "Nami does not support your OS/ARCH yet. Please submit issue or PR to https://github.com/txthinking/nami"
		    exit
		fi
		
		
		curl -L -o /usr/local/bin/nami "https://github.com/txthinking/nami/releases/latest/download/nami_${os}_${arch}"
		chmod +x /usr/local/bin/nami
		nami
    else
        echo -e "${cyan}________________${rest}"
        echo -e "${green}nami already installed${rest}"
    fi
}

# Get ssl certificate
install_acme(){

    if [[ $ID == "centos" ]]; then
        "${p_m}" install cronie
        systemctl start crond
        systemctl enable crond
    else
        "${p_m}" install cron
        systemctl start cron
        systemctl enable cron
    fi
    
    mkdir /root/brook
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    echo -e "${purple}*****************${rest}"
    echo -en "${green}Please enter your registration email (e.g., admin@gmail.com, or Press Enter to generate a  random Gmail): ${rest}"
    read -r email
	if [[ -z $email ]]; then
	    mail=$(date +%s%N | md5sum | cut -c 1-16)
	    email=$mail@gmail.com
	    echo -e "${green}Gmail set to: ${yellow}$email${rest}"
	    echo -e "${purple}*****************${rest}"
	    sleep 1
	fi
    ~/.acme.sh/acme.sh --register-account -m $email
    ~/.acme.sh/acme.sh --issue -d $domain --standalone
    ~/.acme.sh/acme.sh --installcert -d $domain --key-file /root/brook/private.key --fullchain-file /root/brook/cert.crt
    echo "0 0 * * * root bash /root/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /etc/crontab
}

start_brook_service() {
    cat <<EOF | sudo tee /etc/systemd/system/brook.service >/dev/null
[Unit]
Description=Brook Websocket Server
After=network.target

[Service]
ExecStart=/root/.nami/bin/brook wssserver --domainaddress $domain:$port --password $passwd --cert /root/brook/cert.crt --certkey /root/brook/private.key --blockGeoIP="IR"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to apply the changes
    sudo systemctl daemon-reload

    # Start and enable the brook service
    sudo systemctl start brook
    sudo systemctl enable brook
    
    if systemctl is-active --quiet brook.service; then
        echo -e "${yellow}_________________________________________${rest}"
        echo -e "${green}Service Installed Successfully and activated.${rest}"
        echo -e "${yellow}_________________________________________${rest}"
        printf "+-------------------+-----------+\n"
		printf "| %-20s | %-12s |\n" "server" "password"
		printf "| %-22s | %-13s |\n" "👇" "👇"
		printf "| %-20s | %-12s |\n" "wss://$domain:$port" "$passwd"
		printf "+-------------------+-----------+\n"
    else
        echo -e "${yellow}____________________________${rest}"
        echo -e "${red}Service is not active.${rest}"
        echo -e "${yellow}____________________________${rest}"
    fi
}

#Check status
check() {
    if systemctl is-active --quiet brook.service; then
        echo -e "${cyan} [Brook is Active]${rest}"
    else
        echo -e "${yellow}[Brook Not Active]${rest}"
    fi
}

# Install Brook
install() {
    if sudo systemctl is-active --quiet brook; then
        echo -e "${cyan}________________${rest}"
        echo -e "${green}Brook service is already Actived.${rest}"
        echo -e "${cyan}________________${rest}"
    else
	    check_dependencies
	    install_nami
	    
	    if ! command -v brook &> /dev/null; then
	        nami install brook
	    else
	        echo -e "${green}Brook already installed ${installed}"
	        echo -e "${cyan}________________${rest}"
	        echo ""
	    fi
	    
	    echo -e "${purple}*****************${rest}"
	    echo -en "${green}Enter Your domain:${rest} "
	    read -r domain
	    if [[ -z $domain ]]; then
	        echo "Domain cannot be empty."
	        exit 1
	    fi
	    echo -e "${cyan}Domain set to:${rest} ${yellow}$domain${rest}"
	    echo -e "${purple}*****************${rest}"
	    echo -en "${green}Enter Https Port [Default :443]:${rest} " 
	    read -r port
	    port="${port:-443}"
	    echo -e "${cyan}Port set to:${rest} ${yellow}$port${rest}"
	    echo -e "${purple}*****************${rest}"
	    echo -en "${green}Enter a password (or press Enter for a random password):${rest} "
	    read -r passwd
	    if [ -z "$passwd" ]; then
	        passwd=$(date +%s | sha256sum | base64 | head -c 6)
	    fi
	    echo -e "${cyan}Password set to:${rest} ${yellow}$passwd${rest}"
	    echo -e "${purple}*****************${rest}"
	    sleep 1
	    
	    install_acme
	    start_brook_service
    fi
}

# Change Port
change_port() {
    if sudo systemctl is-active --quiet brook; then
	    old_port=$(awk -F ':| ' '/--domainaddress/ {print $5}' /etc/systemd/system/brook.service)
	    echo -e "${purple}*****************${rest}"
	    echo -e "${cyan}Your Port is: ${old_port}${rest}"
	    echo -en "${green}Enter Https Port [Default :443]:${rest} " 
	    read -r new_port
	    new_port="${new_port:-443}"
	    
	    echo -e "${cyan}Port changed to:${rest} ${yellow}$new_port${rest}"
	    echo -e "${purple}*****************${rest}"
	    
	    sed -i "s/:${old_port}/:${new_port}/" /etc/systemd/system/brook.service
	    
	    sudo systemctl daemon-reload
	    sudo systemctl restart brook.service
	else
	    echo -e "${purple}*****************${rest}"
	    echo -e "${yellow}Service is not installed. please Install first${rest}"
	    echo -e "${purple}*****************${rest}"
	fi
}

# Change Password
change_password() {
    if sudo systemctl is-active --quiet brook; then
	    password=$(grep -oP '(?<=--password\s)[^\s]+' /etc/systemd/system/brook.service)
	    echo -e "${purple}*****************${rest}"
	    echo -e "${cyan}Your Password is: ${password}${rest}"
	    echo -en "${green}Enter New Password:${rest} " 
	    read -r new_password
	    
	    echo -e "${cyan}Password changed to:${rest} ${yellow}$new_password${rest}"
	    echo -e "${purple}*****************${rest}"
	    
	    sed -i "s/--password [^ ]*/--password $new_password/" /etc/systemd/system/brook.service
	    
	    sudo systemctl daemon-reload
	    sudo systemctl restart brook.service
	else
	    echo -e "${purple}*****************${rest}"
	    echo -e "${yellow}Service is not installed. please Install first${rest}"
	    echo -e "${purple}*****************${rest}"
	fi
}

# Uninstall
uninstall() {
    if sudo systemctl status brook &>/dev/null || [ -f /etc/systemd/system/brook.service ]; then
        sudo systemctl stop brook
        sudo systemctl disable brook 2>/dev/null
        sudo rm -f /etc/systemd/system/brook.service
        sudo systemctl daemon-reload
        nami remove brook 2>/dev/null
        rm /usr/local/bin/nami 2>/dev/null
        
	    # Check if acme.sh is installed
	    if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
	        ~/.acme.sh/acme.sh --uninstall >/dev/null 2>&1
	        sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
	        rm -rf ~/.acme.sh
	        rm -rf brook
	        echo -e "${purple}*****************${rest}"
	        echo -e "${green}Acme.sh has been uninstalled.${rest}"
	    else
	        echo -e "${purple}*****************${rest}"
	        echo -e "${yellow}Acme.sh is not installed.${rest}"
	    fi
        echo -e "${green}Brook service has been uninstalled.${rest}"
    else
        echo -e "${purple}*****************${rest}"
        echo -e "${yellow}Brook service is not installed.${rest}"
        echo -e "${purple}*****************${rest}"
    fi
}

clear
echo -e "${cyan}By --> Peyman * Github.com/Ptechgithub * ${rest}"
echo ""
check
echo -e "${purple}********************${rest}"
echo -e "${purple}*    ${green}BROOK VPN${purple}     *${rest}"
echo -e "${purple}********************${rest}"
echo -e "${yellow}1) ${green}Install${rest}         ${purple}*${rest}"
echo -e "${purple}                   * ${rest}"
echo -e "${yellow}2) ${green}Uninstall${rest}       ${purple}*${rest}"
echo -e "${purple}                   * ${rest}"
echo -e "${yellow}3) ${green}Change Port${rest}     ${purple}*${rest}"
echo -e "${purple}                   * ${rest}"
echo -e "${yellow}4) ${green}Change Password${purple} *${rest}"
echo -e "${purple}********************${rest}"

read -p "Enter your choice: " choice
case "$choice" in
    1)
        install
        ;;
    2)
        uninstall
        ;;
    3) 
        change_port 
        ;;
    4)
        change_password 
        ;;
    0)
        echo -e "${cyan}By 🖐${rest}"
        exit
        ;;
    *)
        echo -e "${purple}*****************${rest}"
        echo "Invalid choice. Please select a valid option."
        echo -e "${purple}*****************${rest}"
        ;;
esac