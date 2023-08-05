using Nethereum.HdWallet;
using Nethereum.Web3;
using Account = Nethereum.Web3.Accounts.Account;

namespace NethereumSample;

public class CallSmartContract
{

	public static string contractByteCode = "0x608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550610371806100606000396000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c806302d05d3f146100515780631f6f90bd1461006f57806390085b191461008d578063ec4788cd146100bd575b600080fd5b6100596100ed565b6040516100669190610230565b60405180910390f35b610077610111565b6040516100849190610230565b60405180910390f35b6100a760048036038101906100a2919061027c565b61013a565b6040516100b49190610230565b60405180910390f35b6100d760048036038101906100d291906102df565b6101a7565b6040516100e49190610230565b60405180910390f35b60008054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b60006001829080600181540180825580915050600190039060005260206000200160009091909190916101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550819050919050565b6000600182815481106101bd576101bc61030c565b5b9060005260206000200160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b600061021a826101ef565b9050919050565b61022a8161020f565b82525050565b60006020820190506102456000830184610221565b92915050565b600080fd5b6102598161020f565b811461026457600080fd5b50565b60008135905061027681610250565b92915050565b6000602082840312156102925761029161024b565b5b60006102a084828501610267565b91505092915050565b6000819050919050565b6102bc816102a9565b81146102c757600080fd5b50565b6000813590506102d9816102b3565b92915050565b6000602082840312156102f5576102f461024b565b5b6000610303848285016102ca565b91505092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fdfea2646970667358221220f010d07cf841323adb17cad3fce25dd1a8be00bc882cdeb9e7fc8f6f56c9959a64736f6c63430008120033";
	public static string abi = @"[
	{
		'inputs': [],
		'stateMutability': 'nonpayable',
		'type': 'constructor'
	},
	{
		'inputs': [
			{
				'internalType': 'address',
				'name': 'newAddress',
				'type': 'address'
			}
		],
		'name': 'addAddresses',
		'outputs': [
			{
				'internalType': 'address',
				'name': 'addressNew',
				'type': 'address'
			}
		],
		'stateMutability': 'nonpayable',
		'type': 'function'
	},
	{
		'inputs': [],
		'name': 'creator',
		'outputs': [
			{
				'internalType': 'address',
				'name': '',
				'type': 'address'
			}
		],
		'stateMutability': 'view',
		'type': 'function'
	},
	{
		'inputs': [],
		'name': 'creatorName',
		'outputs': [
			{
				'internalType': 'address',
				'name': 'creatorName_',
				'type': 'address'
			}
		],
		'stateMutability': 'view',
		'type': 'function'
	},
	{
		'inputs': [
			{
				'internalType': 'uint256',
				'name': 'i',
				'type': 'uint256'
			}
		],
		'name': 'getAddresses',
		'outputs': [
			{
				'internalType': 'address',
				'name': 'addressI',
				'type': 'address'
			}
		],
		'stateMutability': 'view',
		'type': 'function'
	}
]";
	public static async Task<string> DeployTestContract()
	{
        Account account = new Account("0x7ad76f74bc3627b6f3f24175b9e85e20cde55c6dc1491dbc88ecc436fabda224", 6660001);
        var web3 = new Web3(account, "http://localhost:8545");
		web3.TransactionManager.UseLegacyAsDefault = true;

		// Load the contract's ABI


		//var v = web3.Personal.UnlockAccount.SendRequestAsync("0x3590aca93338b0721966a8d0c96ebf2c4c87c544", "0x7ad76f74bc3627b6f3f24175b9e85e20cde55c6dc1491dbc88ecc436fabda224", 15000);

		var estimateGas = await web3.Eth.DeployContract.EstimateGasAsync(abi, contractByteCode, account.Address);

		var receipt = await web3.Eth.DeployContract.SendRequestAndWaitForReceiptAsync(abi,
			contractByteCode, account.Address, estimateGas, null);
		Console.WriteLine("Contract deployed at address: " + receipt.ContractAddress);


		// Create an instance of the contract
		return receipt.ContractAddress;

	}


	public static async Task TestContract(string contractAddress=null)
	{

        Account account = new Account("0x7ad76f74bc3627b6f3f24175b9e85e20cde55c6dc1491dbc88ecc436fabda224", 6660001);
        var web3 = new Web3(account, "http://localhost:8545");
        web3.TransactionManager.UseLegacyAsDefault = true;

        if (contractAddress == null)
		{
			contractAddress = await DeployTestContract();
		}



		
		var contract = web3.Eth.GetContract(abi, contractAddress);
		// Call a method on the contract
		var function = contract.GetFunction("creatorName");
		var result = await function.CallAsync<string>();
		Console.WriteLine(result);
		var functionAddAddress = contract.GetFunction("addAddresses");

        var gas = await functionAddAddress.EstimateGasAsync(account.Address,null,null, "0xAF7C5c09E663A81c1c579C9871DE4197C2cD3538");

        var resultAddAddresses = await functionAddAddress.SendTransactionAndWaitForReceiptAsync(account.Address,gas,null,null,"0xAF7C5c09E663A81c1c579C9871DE4197C2cD3538");
		Console.WriteLine(resultAddAddresses);
	}
}