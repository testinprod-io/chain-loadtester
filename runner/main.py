from eth_account import Account
import web3
import os
import sys
import json
import multiprocessing


rpc_endpoint = 'http://localhost:9545'
key = sys.argv[1]
account = Account.from_key(key)

provider = web3.HTTPProvider(endpoint_uri=rpc_endpoint)
w3 = web3.Web3(provider)

with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../contracts/artifacts/contracts.json'), 'r') as f:
    addrs = json.load(f)
    router_addr = w3.to_checksum_address(addrs['swapRouter'])

data = ('0x1218dcb4'
        f'000000000000000000000000{addrs["currency0"][2:]}'
        f'000000000000000000000000{addrs["currency1"][2:]}'
        '0000000000000000000000000000000000000000000000000000000000000bb8'
        '000000000000000000000000000000000000000000000000000000000000003c'
        '0000000000000000000000000000000000000000000000000000000000000000'
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')


def generate_payloads(queue, account):
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

    producer = multiprocessing.Process(target=generate_payloads, args=(queue, account))
    producer.start()

    while True:
        tx = queue.get()
        tx_hash = w3.eth.send_raw_transaction(tx.rawTransaction)
