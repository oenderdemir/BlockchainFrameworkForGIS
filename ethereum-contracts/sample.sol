pragma solidity >=0.7.0 <0.9.0;
contract sample {
     address public creator;
       address[] addresses;
    constructor()
    {
        creator=msg.sender;
    }

     function creatorName() public view
            returns (address creatorName_)
    {
        creatorName_ = creator;
    }


function getAddresses(uint256 i ) public view
            returns (address addressI)
    {
        addressI = addresses[i];
    }
   
  

    function addAddresses(address newAddress) public returns (address addressNew){
        addresses.push(newAddress); 
        addressNew=newAddress;
    }
}