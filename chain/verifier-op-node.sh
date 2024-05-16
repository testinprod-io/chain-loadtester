#!/bin/sh
set -exu

L1_ENDPOINT=${L1_ENDPOINT:-ws://localhost:8546}
L2_ENDPOINT=${L2_ENDPOINT:-http://localhost:38551}

SEQUENCER_OP_NODE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"opp2p_self","params":[],"id":1}' http://localhost:28545 | jq -r '.result.addresses[1]')
echo $SEQUENCER_OP_NODE

./op-node \
  --l1="$L1_ENDPOINT" \
  --l2="$L2_ENDPOINT" \
  --l2.jwt-secret=./verifier-jwt-secret.txt \
  --sequencer.l1-confs=0 \
  --verifier.l1-confs=0 \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=48545 \
  --p2p.listen.ip=0.0.0.0 \
  --p2p.listen.tcp=49003 \
  --p2p.listen.udp=49003 \
  --p2p.scoring.peers=light \
  --p2p.ban.peers=true \
  --snapshotlog.file=./logs/verifier-op-node-snapshot.log \
  --p2p.priv.path=./verifier-p2p-node-key.txt \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=47300 \
  --rpc.enable-admin \
  --safedb.path=./verifier-op-node-db \
  --l1.beacon.ignore \
  --p2p.static="$SEQUENCER_OP_NODE" \
  --p2p.peerstore.path=memory \
  --p2p.discovery.path=memory \
  --log.format=json