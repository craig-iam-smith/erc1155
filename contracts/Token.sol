// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./extensions/ERC1155PausableID.sol";
import "./extensions/Blacklistable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155MetadataURI.sol";
//import "hardhat/console.sol";

contract ERC1155plus is ERC1155, Ownable, ERC1155Burnable, ERC1155PausableID, Blacklistable, ERC1155URIStorage {

    // Mapping from owner to array of token IDs owned 
    mapping(address => uint256[]) private _ownedTokens;
    // Mapping from token ID to array of owners
    mapping(uint256 => address[]) private _tokenOwners; 
    mapping(uint256 => mapping(address => uint256)) private _idTokenOwnerIndex;
    // Mapping from token ID to total tokens minted
    mapping(uint256 => uint256) public _totalTokens;
    mapping (uint256 => mapping (address => uint256)) _payments;

    constructor() ERC1155("") {}
/*
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        // How should the check here be like?
    }
*/
    function uri(uint id) override (ERC1155, ERC1155URIStorage)  public view returns (string memory) {
        return super.uri(id);   
    }
    function setURI(uint id, string memory newuri) 
        public
        onlyOwner
        {
        _setURI(id, newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override (ERC1155, ERC1155PausableID) 
    {
        
        uint256 idsLength = ids.length;
        uint256 amountsLength =amounts.length;
        require (idsLength > 0);
        require (idsLength == amountsLength);
        uint256 id;
        uint256 amount;

        require (!isBlacklisted(from));
        require (!isBlacklisted(to));
        
        for (uint256 i = 0; i < idsLength;) {
            id = ids[i];
            amount = amounts[i];
            // minting
            if (from == address(0)) {
                _totalTokens[id] += amount;
                addToTracking(id, to);
            }
            // burning 
            else if (to == address(0)) {
                _totalTokens[id] -= amount;
                if ((balanceOf(from, id) == amount) && (amount > 0)) {
                    removeFromTracking(id, from);
                }
            }
            // transferring
            else {             
                if ((balanceOf(from, id) == amount) && (amount > 0)) {
                    removeFromTracking(id, from);
                }               
            // if 'to' does not have a _idTokenOwnerIndex (has no tokens)
                if ((_idTokenOwnerIndex[id][to] == 0) && (amount > 0)) {
                    addToTracking(id, to);
                }
            }
            unchecked {
                i++;}
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);   
    }

    function removeFromTracking(uint256 id, address account) private {
        uint256 ownersLength = _tokenOwners[id].length-1;
        uint256 tokensLength = _ownedTokens[account].length-1;
        uint256 index = _idTokenOwnerIndex[id][account];  
        // if balanceOf(account, id) == amount delete from arrays
        if (index != ownersLength) {
            _tokenOwners[id][index] = _tokenOwners[id][ownersLength];
        }
        uint256 i;
        for (i=0;i<tokensLength;) {
            if (_ownedTokens[account][i] == id) {
                _ownedTokens[account][i] = _ownedTokens[account][tokensLength];
                break;
            }
            unchecked {
                i++;}
        }
        _ownedTokens[account].pop();
        _tokenOwners[id].pop();
        _idTokenOwnerIndex[id][account] = 0;
    }
    function addToTracking (uint256 id, address account) private {
        _ownedTokens[account].push(id); 
        _tokenOwners[id].push(account);     
        _idTokenOwnerIndex[id][account] = _tokenOwners[id].length-1; // keep track of index 
    }


    function getTotalTokens(uint256 id) public view returns (uint256) {
        return _totalTokens[id];
    }
    // @dev 
    // @params owner 
    // @return returns array of token ids owned by this address
    function getTokensOwned(address account) public view returns (uint256[] memory) {
        require (account != address(0));
        return _ownedTokens[account];
    }
    
    // @dev
    // @params tokenid
    // @return returns array of owner addresses of this tokenid
    function getOwnersOfToken(uint256 tokenId) public view returns (address[] memory) {
        return _tokenOwners[tokenId];
    }
      
    function payAllHolders(uint256 id, uint256 amount, address paymentTokenContract) public onlyOwner returns(bool success)
    {
        IERC20 payToken = IERC20(paymentTokenContract);
        uint256 i;
        address to;
        uint256 totalTokens = _totalTokens[id];
        address[] memory payees = _tokenOwners[id];
        uint256 end = payees.length;
        require (paymentTokenContract != address(0));
        require (payToken.balanceOf(msg.sender) > amount, "Must have enough of payment token");
        uint256 total=0;
        uint256 ownership;
        uint256 share;
        if (end > 50) {
            success = false ;
            return success;
        }
        for (i=0;i<end;) {
            to = payees[i];
            ownership = balanceOf(to, id);
            share = ((amount * ownership) / totalTokens);
            success = payToken.transferFrom(msg.sender, to, share);
            require (success, "Transfer failed");
            total = total + share;
            unchecked {
                i++;}
        }
        success = true;
        require (total <= amount, "Total paid is more than amount");
    }

    function dropToAllHolders(uint256 id, uint256 amount, address paymentTokenContract) public onlyOwner returns(bool success)
    {
        ERC1155 payToken = ERC1155(paymentTokenContract);
        uint256 i;
        address to;
        address[] memory payees = _tokenOwners[id];
        uint256 end = payees.length;
        require (paymentTokenContract != address(0));
        require (payToken.balanceOf(msg.sender, id) > amount, "Must have enough of payment ERC1155 token");
        for (i=0;i<end;) {
            to = payees[i];
            payToken.safeTransferFrom(msg.sender, to, id, 1, bytes (""));
            require (success, "Transfer failed");
            unchecked {
                i++;}
        }
        success = true;
    }
    function getTokenOwners(uint256 id) public view returns (address[] memory) {
        return _tokenOwners[id];
    }
}