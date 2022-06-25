I use Ubuntu machine for development purpose so I will provide some command lines that helps you install tools required by scripts within this repo

- Go
    > cd /tmp

    > wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz

    > sudo tar -zxvf go1.18.3.linux-amd64.tar.gz -C /usr/local/

    > mkdir ~/go

    > echo -e "\nexport GOPATH=\$HOME/go\nexport PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> ~/.bashrc

