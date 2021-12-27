from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv
import web3

load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    print(simple_storage_file)

# compile solidity
install_solc("0.8.11")
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.8.11",
)
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# connect to ganache
# w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
# chain_id = 1337
# my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
## add 0x to private key
# private_key = os.getenv("PRIVATE_KEY")


# connect to infura
w3 = Web3(
    Web3.HTTPProvider("https://rinkeby.infura.io/v3/ea1a8090419e4b46908ec93adcda4845")
)
chain_id = 4
my_address = "0x98E2CC96dfB1A8D1651872b42E96a69714f99fed"
private_key = os.getenv("PRIVATE_KEY_INFURIA")

# get contract
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)

# get nonce from latest transaction
nonce = w3.eth.getTransactionCount(my_address)

# 1. Build a transaction
# 2. Sign a transaction
# 3. Send a transaction
# 4. Wait for receipt
build_dic = {
    "chainId": chain_id,
    "from": my_address,
    "nonce": nonce + 1,
    "gasPrice": w3.eth.gas_price,
}
# 1.
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
        "gasPrice": w3.eth.gas_price,
    }
)
print("deploying contract")
# 2.
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
# 3
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
# 4
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("deployed")

# Working with the contract we always need
# Contract Address
# Contract ABI
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
print("getting ABI and address")
# when interacting with the blockchain we can interact with:
#  Call: Simulate making the call and getting a return value. They don't make a state change. This is similar to view
# Transaction: This makes a state chage

# 1. Build a transaction
store_transaction = simple_storage.functions.store(15).buildTransaction(build_dic)
print("updating contract...")
# 2. Sign a transaction
sign_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)

# 3. Send a transaction
send_store_tx = w3.eth.send_raw_transaction(sign_store_txn.rawTransaction)

# 4. Wait for receipt
tx_receipt = w3.eth.wait_for_transaction_receipt(send_store_tx)
print("Updated")
print(simple_storage.functions.retrieve().call())
