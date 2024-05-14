# Uniswap Loadtester

```bash
# Example private keys are pre-funded dev accounts

# in optimism monorepo
make devnet-up
cast send --rpc-url=http://localhost:8545 --private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --value=10000ether 0x9A676e781A523b5d0C0e43731313A708CB607508
cast send --rpc-url=http://localhost:8545 --private-key=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --value=10000ether 0x9A676e781A523b5d0C0e43731313A708CB607508

# in this repo
cd contracts
forge script script/Setup.s.sol --private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url=http://localhost:9545 --broadcast
forge script script/Fund.s.sol --private-key=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --rpc-url=http://localhost:9545 --broadcast
cd ../runner
python main.py 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
python main.py 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```
