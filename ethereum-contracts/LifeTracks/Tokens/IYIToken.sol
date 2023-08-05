pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract IYIToken is ERC721URIStorage  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor () ERC721 ("IYI Vatandas Token", "IYI") {
        
    }


   function awardBadge(address citizen, string memory tokenURI)
        public
        returns (uint256)
    {
        uint256 newBadgeId = _tokenIds.current();
        _mint(citizen, newBadgeId);
        _setTokenURI(newBadgeId, tokenURI);

        _tokenIds.increment();
        return newBadgeId;
    }
}

