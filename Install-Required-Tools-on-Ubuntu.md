I use `Ubuntu 22.04 LTS` machine for development purpose so I will provide some command lines that helps you install tools required by scripts within this repo

Update system first `sudo apt-get update -y`

- Go 1.20.2
    > cd /tmp

    > wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz

    > sudo tar -zxvf go1.20.2.linux-amd64.tar.gz -C /usr/local/

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

- docker-compose
    > mkdir -p ~/.docker/cli-plugins/
    
    > curl -SL https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

    > chmod +x ~/.docker/cli-plugins/docker-compose

    > sudo ln -s ~/.docker/cli-plugins/docker-compose /usr/bin/docker-compose

- Rust
    > curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

- psql (PostgreSQL client)
    > sudo apt install postgresql-client -y

- NodeJS
    > curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh

    > sudo bash /tmp/nodesource_setup.sh

    > sudo apt-get install -y nodejs

- Yarn
    > curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

    > echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

    > sudo apt update -y && sudo apt-get install -y yarn

- hasura-cli
    > curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash

#### Remember to relog to all new PATH update takes effect
