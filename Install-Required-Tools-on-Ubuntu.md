I use `Ubuntu 22.04 LTS` machine for development purpose so I will provide some command lines that helps you install tools required by scripts within this repo

- Go 1.18.3
    > cd /tmp

    > wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz

    > sudo tar -zxvf go1.18.3.linux-amd64.tar.gz -C /usr/local/

    > mkdir ~/go

    > echo -e "\nexport GOPATH=\\$HOME/go\nexport PATH=\\$PATH:/usr/local/go/bin:\\$GOPATH/bin" >> ~/.bashrc

- jq
    > sudo apt-get install jq -y

- yq & tomlq
    > sudo apt update -y && sudo apt install python3-pip -y && pip3 install yq

- docker
    > sudo apt-get update -y

    > sudo apt-get install ca-certificates curl gnupg lsb-release -y

    > sudo mkdir -p /etc/apt/keyrings
 
    > curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    > echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    > sudo apt-get update -y

    > sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

    > sudo groupadd docker

    > sudo usermod -aG docker $USER