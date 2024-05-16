#!/bin/sh
set -exu

L1_ENDPOINT=${L1_ENDPOINT:-ws://localhost:8546}
L2_ENDPOINT=${L2_ENDPOINT:-http://localhost:18551}

./op-node \
  --l1="$L1_ENDPOINT" \
  --l2="$L2_ENDPOINT" \
  --l2.jwt-secret=./sequencer-jwt-secret.txt \
  --sequencer.enabled \
  --sequencer.l1-confs=0 \
  --verifier.l1-confs=0 \
  --p2p.sequencer.key=8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=28545 \
  --p2p.listen.ip=0.0.0.0 \
  --p2p.listen.tcp=29003 \
  --p2p.listen.udp=29003 \
  --p2p.scoring.peers=light \
  --p2p.ban.peers=true \
  --snapshotlog.file=./logs/sequencer-op-node-snapshot.log \
  --p2p.priv.path=./sequencer-p2p-node-key.txt \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=27300 \
  --rpc.enable-admin \
  --safedb.path=./sequencer-op-node-db \
  --l1.beacon.ignore \
  --log.format=json