
using NBitcoin;
using Nethereum.HdWallet;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.KeyStore.Model;
using Nethereum.RPC.TransactionManagers;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using NethereumSample;
using Newtonsoft.Json;
using Rijndael256;
using static System.Console;

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");
//await TestProj();
bool exit = false;
while(!exit)
{
    Console.WriteLine("To deploy a testContract Press 1");
    Console.WriteLine("To test an existing contract Press 2");
    Console.WriteLine("To quit  Press q");
    var keyPressed=Console.ReadLine();
    switch(keyPressed)
    {
        case "q":
            exit=true; break;
        case "1":
            await CallSmartContract.DeployTestContract();
            break;
        case "2":
            Console.WriteLine("Enter Contract Address");
            var contractAddress = Console.ReadLine();
            await CallSmartContract.TestContract(contractAddress);
            break;
    }
    
}


Console.WriteLine("Hello, World!");


 static Wallet CreateWallet(string password, string pathfile)
{
    // TODO: Create brand-new wallet and get all the Words that were used.

    Wallet wallet = new Wallet(Wordlist.English, WordCount.Twelve);
    string words = string.Join(" ", wallet.Words);
    string fileName = string.Empty;

    try
    {

        // TODO: Save the Wallet in the desired Directory.
        fileName = SaveWalletToJsonFile(wallet, password, pathfile);
    }
    catch (Exception e)
    {
        Console.WriteLine($"ERROR! The file can`t be saved! {e}");
        throw e;
    }

    Console.WriteLine("New Wallet was created successfully!");
    Console.WriteLine("Write down the following mnemonic words and keep them in the save place.");
    // TODO: Display the Words here.
    Console.WriteLine(words);
    Console.WriteLine("Seed: ");
    // TODO: Display the Seed here.
    Console.WriteLine(wallet.Seed);
    Console.WriteLine();
    // TODO: Implement and use PrintAddressesAndKeys to print all the Addresses and Keys.
    PrintAddressesAndKeys(wallet);

    return wallet;
}
static string SaveWalletToJsonFile(Wallet wallet, string password, string pathfile)
{
    //TODO: Encrypt and Save the Wallet to JSON.
    string words = string.Join(" ", wallet.Words);
    var encryptedWords = Rijndael.Encrypt(words, password, KeySize.Aes256);
    string date = DateTime.Now.ToString();
    var walletJsonData = new { encryptedWords = encryptedWords, date = date };
    string json = JsonConvert.SerializeObject(walletJsonData);
    Random random = new Random();
    var fileName =
        "EthereumWallet_"
        + DateTime.Now.Year + "-"
        + DateTime.Now.Month + "-"
        + DateTime.Now.Day + "-"
        + DateTime.Now.Hour + "-"
        + DateTime.Now.Minute + "-"
        + DateTime.Now.Second + "-"
        + random.Next(0, 1000) + ".json";
    var r = Path.Combine(pathfile, fileName);
    if(!Directory.Exists(pathfile))
    {
        Directory.CreateDirectory(pathfile);
    }
    File.WriteAllText(Path.Combine(pathfile, fileName), json);
    Console.WriteLine($"Wallet saved in file: {fileName}");
    return fileName;
}
static void PrintAddressesAndKeys(Wallet wallet)
{
    // TODO: Print all the Addresses and the coresponding Private Keys.
    Console.WriteLine("Addresses: ");
    for (int i = 0; i < 20; i++)
    {
        Console.WriteLine(wallet.GetAccount(i).Address);
    }

    Console.WriteLine();
    Console.WriteLine("Private Keys: ");
    for (int i = 0; i < 20; i++)
    {
        Console.WriteLine(wallet.GetAccount(i).PrivateKey);
    }

    Console.WriteLine();
}


static Wallet LoadWalletFromJsonFile(string nameOfWalletFile, string path, string pass)
{
    //TODO: Implement the logic that is needed to Load and Wallet from JSON.
    string pathToFile = Path.Combine(path, nameOfWalletFile);
    string words = string.Empty;
    Console.WriteLine($"Read from {pathToFile}");
    try
    {
        string line = File.ReadAllText(pathToFile);
        dynamic results = JsonConvert.DeserializeObject<dynamic>(line);
        string encryptedWords = results.encryptedWords;
        words = Rijndael.Decrypt(encryptedWords, pass, KeySize.Aes256);
        string dataAndTime = results.date;
    }
    catch (Exception e)
    {
        Console.WriteLine("ERROR!" + e);
    }

    return Recover(words);
}
static async Task Send(Wallet wallet, string fromAddress, string toAddress, double amountOfCoins)
{

    var network = "http://localhost:8545";
    // TODO: Generate and Send a transaction.
    Account accountFrom = wallet.GetAccount(fromAddress,20, 6660001);
    string privateKeyFrom = accountFrom.PrivateKey;
    if (privateKeyFrom == string.Empty)
    {
        WriteLine("Address sending coins is not from current wallet!");
        throw new Exception("Address sending coins is not from current wallet!");
    }

    var web3 = new Web3(accountFrom, network);
    var wei = Web3.Convert.ToWei(amountOfCoins);
    try
    {
        web3.TransactionManager.UseLegacyAsDefault = true;
        var transaction = await web3.TransactionManager.SendTransactionAsync(
            accountFrom.Address,
            toAddress,
            new Nethereum.Hex.HexTypes.HexBigInteger(wei)
        );
        WriteLine("Transaction has been sent successfully!");
    }
    catch (Exception e)
    {
        WriteLine($"ERROR! The transaction can't be completed! {e}");
        throw e;
    }
}
static Wallet Recover(string words)
{
    // TODO: Recover a Wallet from existing mnemonic phrase (words).
    Wallet wallet = new Wallet(words, null);
    Console.WriteLine("Wallet was successfully recovered.");
    Console.WriteLine("Words: " + string.Join(" ", wallet.Words));
    Console.WriteLine("Seed: " + string.Join(" ", wallet.Seed));
    Console.WriteLine();
    PrintAddressesAndKeys(wallet);
    return wallet;
}
static async Task TestProj()
{
 
   // Wallet wallet = CreateWallet("test","wallets");
   
    Wallet w = LoadWalletFromJsonFile("EthereumWallet_2023-3-23-1-7-8-867.json", "wallets", "test");
    Account account = w.GetAccount(0, 6660001);
    var web3 = new Web3(account, "http://localhost:8545");

    var v=web3.Personal.UnlockAccount.SendRequestAsync("0x3590aca93338b0721966a8d0c96ebf2c4c87c544", "", 15000);
    var balance = await web3.Eth.GetBalance.SendRequestAsync(account.Address);
    
    var etherAmount = Web3.Convert.FromWeiToBigDecimal(balance.Value);
    var vatandas = "0xe3Cf801281B6E2ed98D874E120918882bd83D366";
    await Send(w, account.Address, vatandas, 1);

    balance = await web3.Eth.GetBalance.SendRequestAsync(vatandas);
    web3.Personal.UnlockAccount.SendRequestAsync("0x3590aca93338b0721966a8d0c96ebf2c4c87c544", "", 15000);
    int a = 0;


}


 