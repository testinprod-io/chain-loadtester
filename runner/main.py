from eth_account import Account
import web3
import os
import json
import multiprocessing


rpc_endpoint = 'http://localhost:9545'
# pre-funded wallet
key = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
account = Account.from_key(key)

provider = web3.HTTPProvider(endpoint_uri=rpc_endpoint)
w3 = web3.Web3(provider)

with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../contracts/artifacts/contracts.json'), 'r') as f:
    addrs = json.load(f)
    router_addr = w3.to_checksum_address(addrs['swapRouter'])

data ='0x1218dcb40000000000000000000000002279b7a0a67db372996a5fab50d91eaa73d2ebe6000000000000000000000000dc64a140aa3e981100a9beca4e685f962f0cf6c90000000000000000000000000000000000000000000000000000000000000bb8000000000000000000000000000000000000000000000000000000000000003c0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'

def generate_payloads(queue):
    nonce = w3.eth.get_transaction_count(account.address)
    while True:
        tx = {
            "to": router_addr,
            "value": 0,
            "gas": 100000,
            "gasPrice": 100,
            "nonce": nonce,
            "chainId": 901,
            "data": data,
        }
        signed_tx = account.sign_transaction(tx)
        queue.put(signed_tx)
        nonce += 1


if __name__ == '__main__':
    queue = multiprocessing.Queue()

    producer = multiprocessing.Process(target=generate_payloads, args=(queue,))
    producer.start()

    while True:
        tx = queue.get()
        tx_hash = w3.eth.send_raw_transaction(tx.rawTransaction)
        print(tx_hash.hex())