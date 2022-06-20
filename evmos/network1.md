### Network 1 stats

- Home dir: ~/.evmosd-v-evmos_9006-1-node*
- Node 0 (1st/genesis validator)

    + Expose almost it's port to the world

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 1317 | REST API | Open | 0.0.0.0 | - |
| 26657 | Tendermint RPC | Open | 0.0.0.0 | - |
| 8545 | Json RPC | Open | 0.0.0.0 | - |
| 9090 | gRPC | Open | 0.0.0.0 | - |
| 26656 | Peer | Open | 0.0.0.0 | - |
| 26658 | Proxy App | Close | localhost | - |
| 6060 | pprof_laddr | Open | localhost | - |

    + Service file `/etc/systemd/system/evmosd-c1-n0.service`

- Node 1 (2nd validator)

    + Will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 26767 | Tendermint RPC | Open | localhost | 26657 |
| 26766 | Peer | Open | localhost | 26656 |
| 1427 | REST API | Close | localhost | 1317 |
| 8655 | Json RPC | Close | localhost | 8545 |
| 8656 | Websocket Json RPC | Close | localhost | 8546 |
| 9200 | gRPC | Close | localhost | 9090 |
| 9201 | Web gRPC | Close | localhost | 9091 |
| 26768 | Proxy App | Close | localhost | 26658 |
| 6170 | pprof_laddr | Open | localhost | 6060 |

    + Service file `/etc/systemd/system/evmosd-c1-n1.service`

- The node 2 (3rd validator)
    + Same as node 1, this node will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by defaultthe following ports

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 26777 | Tendermint RPC | Open | localhost | 26657 |
| 26776 | Peer | Open | localhost | 26656 |
| 1437 | REST API | Close | localhost | 1317 |
| 8665 | Json RPC | Close | localhost | 8545 |
| 8666 | Websocket Json RPC | Close | localhost | 8546 |
| 9210 | gRPC | Close | localhost | 9090 |
| 9211 | Web gRPC | Close | localhost | 9091 |
| 26778 | Proxy App | Close | localhost | 26658 |
| 6180 | pprof_laddr | Open | localhost | 6060 |

    + Service file `/etc/systemd/system/evmosd-c1-n2.service`