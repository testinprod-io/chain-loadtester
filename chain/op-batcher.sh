export OP_BATCHER_L1_ETH_RPC=http://localhost:8545
export OP_BATCHER_L2_ETH_RPC=http://localhost:18545
export OP_BATCHER_ROLLUP_RPC=http://localhost:28545
export OP_BATCHER_MAX_CHANNEL_DURATION=1
export OP_BATCHER_SUB_SAFETY_MARGIN=4 # SWS is 15, ChannelTimeout is 40
export OP_BATCHER_POLL_INTERVAL=1s
export OP_BATCHER_NUM_CONFIRMATIONS=1
export OP_BATCHER_MNEMONIC="test test test test test test test test test test test junk"
export OP_BATCHER_SEQUENCER_HD_PATH="m/44'/60'/0'/0/2"
export OP_BATCHER_PPROF_ENABLED="true"
export OP_BATCHER_METRICS_ENABLED="true"
export OP_BATCHER_RPC_ENABLE_ADMIN="true"
export OP_BATCHER_BATCH_TYPE=0

./op-batcher --metrics.enabled=false --pprof.enabled=false --rpc.port=7545