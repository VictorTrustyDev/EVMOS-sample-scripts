### Network 1 stats

- Home dir: ~/.evmosd-v-evmos_9006-1-node*
- Node 0 (1st/genesis validator) will public the following ports to 0.0.0.0 network interface:
| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 1317 | REST API | Open | 0.0.0.0 | - |
| 26657 | Tendermint RPC | Open | 0.0.0.0 | - |
| 8545 | Json RPC | Open | 0.0.0.0 | - |
| 9090 | gRPC | Open | 0.0.0.0 | - |
| 26656 | Peer | Open | 0.0.0.0 | - |
| 6060 | pprof_laddr | Open | localhost | - |
- Node 1 (2nd validator) will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default. Only open the following ports
    + Tendermint RPC
    + Peer discovery
    + pprof_laddr
- Same as node 1, the node 2 (3rd validator) will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default. Only open the following ports
    + Tendermint RPC
    + Peer discovery
    + pprof_laddr