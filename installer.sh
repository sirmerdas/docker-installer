#!/bin/bash

restricted_country="n"

enter_sudo_mode(){
    sudo -v
}

# Check if the system meets the requirements for installation
check_system_requirements() {
cat <<"EOF"         


 ad88888ba   88  88888888ba   88b           d88  88888888888  88888888ba   88888888ba,         db         ad88888ba   
d8"     "8b  88  88      "8b  888b         d888  88           88      "8b  88      `"8b       d88b       d8"     "8b  
Y8,          88  88      ,8P  88`8b       d8'88  88           88      ,8P  88        `8b     d8'`8b      Y8,          
`Y8aaaaa,    88  88aaaaaa8P'  88 `8b     d8' 88  88aaaaa      88aaaaaa8P'  88         88    d8'  `8b     `Y8aaaaa,    
  `"""""8b,  88  88""""88'    88  `8b   d8'  88  88"""""      88""""88'    88         88   d8YaaaaY8b      `"""""8b,  
        `8b  88  88    `8b    88   `8b d8'   88  88           88    `8b    88         8P  d8""""""""8b           `8b  
Y8a     a8P  88  88     `8b   88    `888'    88  88           88     `8b   88      .a8P  d8'        `8b  Y8a     a8P  
 "Y88888P"   88  88      `8b  88     `8'     88  88888888888  88      `8b  88888888Y"'  d8'          `8b  "Y88888P"   

 
EOF
    echo "Checking system requirements..."
    local progress=0
    local total=100
    while [ $progress -le $total ]; do
        printf "\r[%-${total}s] %d%%" "$(printf '=%.0s' $(seq 1 $progress))" "$((progress * 100 / total))"
        ((progress++))
        sleep 0.02
    done

    if command -v apt &>/dev/null || command -v apt-get &>/dev/null; then
        echo -e "\e[32m\nEverything is fine!\e[0m"
        sleep 0.5
    else
        echo -e "\e[31mThis system does not satisfy the installer requirements!\e[0m"
        exit 1
    fi
}

update_system(){
    sudo apt update -y
}

# Set custom DNS servers
set_dns(){
    sudo touch /etc/resolv.conf
    sudo cp /etc/resolv.conf /etc/resolv.conf.primary
    echo -e "nameserver $1\nnameserver $2" | sudo tee /etc/resolv.conf > /dev/null
    echo -e "\e[32mSystem DNS changed successfully!\e[0m"
}

# Restore original DNS settings
reset_dns(){
    sudo mv /etc/resolv.conf.primary /etc/resolv.conf
}

install_docker(){
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

# Change Docker registry to ArvanCloud mirror if applicable
change_docker_registry(){
    echo "Do you want to use ArvanCloud registry mirror? (y/n): "
    read -n 1 -s -r use_arvan_registry
    if [[ "$use_arvan_registry" = "y" ]] || [[ "$use_arvan_registry" = "Y" ]]
    then
sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["https://docker.arvancloud.ir"],
  "registry-mirrors": ["https://docker.arvancloud.ir"]
}
EOF'
        docker logout
        sudo systemctl restart docker
    fi
}

# Prompt user to enable restricted mode if using in blocked countries
check_restrict_mode(){
    echo "will this script be used on servers located in countries restricted by Docker (e.g., Iran, Russia, etc.)? (y/n): "
    read -n 1 -s -r is_restricted_country

    if [[ "$is_restricted_country" = "y" ]] || [[ "$is_restricted_country" = "Y" ]]
    then
        echo "Installing in restricted country mode..."
        restricted_country="y"
        sleep 0.5
        echo -e "\e[34mFor DNS server IP, you can use Shecan, Electro, etc. \e[0m"
        read -p "Enter the primary DNS server IP: " nameserver_1
        while ! [[ $nameserver_1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
            echo -e "\e[31mInvalid IP format. Please enter a valid IPv4 address.\e[0m"
            read -p "Enter the secondary DNS server IP: " nameserver_1
        done

        read -p "Enter the secondary DNS server IP: " nameserver_2
        while ! [[ $nameserver_2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
            echo -e "\e[31mInvalid IP format. Please enter a valid IPv4 address.\e[0m"
            read -p "Enter the secondary DNS server IP: " nameserver_2
        done

        set_dns $nameserver_1 $nameserver_2
    fi
}

complete_installation_message(){
    echo -e "\e[36mInstallation completed!\e[0m"
}


# Main script execution
enter_sudo_mode
check_system_requirements
check_restrict_mode
update_system
install_docker
change_docker_registry
complete_installation_message

if [[ "$restricted_country" = "y" ]] || [[ "$restricted_country" = "Y" ]]
then
    reset_dns
fi