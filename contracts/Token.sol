// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC1155plus is ERC1155, Ownable, Pausable, ERC1155Burnable {

    // Mapping from owner to array of token IDs owned 
    mapping(address => uint256[]) private _ownedTokens;
    // Mapping from token ID to array of owners
    mapping(uint256 => address[]) private _tokenOwners;
    // Mapping from token ID to total tokens minted
    mapping(uint256 => uint256) private _totalTokens;

    constructor() ERC1155("") {}
/*
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        // How should the check here be like?
    }
*/
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
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
        whenNotPaused
        override
    {
        uint256 idsLength = ids.length;
        uint256 amountsLength =amounts.length;
        require (idsLength > 0);
        require (idsLength == amountsLength);
        for (i = 0; i < idsLength; i++) {
        // if the from address is zero, minting
            if (from == address(0)) {
                if (_totalTokens[id] == 0) {
                    _ownedTokens[to].push(ids[i]);
                    _tokenOwners[id].push(to);
                }
                _totalTokens[id] += amounts[i];
            }
            // burning
            if (to == address(0)) {
                _totalTokens[id] -= amounts[i];
                for (j=0;j<_ownedTokens[to].length;j++){
                    _;
                }
            }
            // transferring

        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);   
    }

    function payAllHolders(uint256 id, uint256 amount, address paymentTokenContract) public onlyOwner
    {
        ERC20 payToken = ERC20(paymentTokenContract);
        uint256 i;
        address to;
        address[] memory payees = _tokenOwners[id];
        uint256 end = payees.length;
        require (paymentTokenContract != address(0));
        require (payToken.balanceOf(msg.sender) > amount, "Must have enough of payment token");
        uint256 total=0;
        uint256 ownership;
        uint256 share;
        for (i=0;i<end;i++) {
            to = payees[i];
            ownership = balanceOf(to, id);
            share = ((amount * ownership) / _totalTokens[id]);
            payToken.transferFrom(msg.sender, to, share);
            total += share;
        }
        require (total <= _totalTokens[id]);
    }

    function getTotalTokens(uint256 id) public view returns (uint256) {
        return _totalTokens[id];
    }
    // @dev 
    // @params owner 
    // @return returns array of token ids owned by this address
    function getTokensOwned(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
    // @dev
    // @params tokenid
    // @return returns array of owner addresses of this tokenid
    function getOwnersOfToken(uint256 tokenId) public view returns (address[] memory) {
        return _tokenOwners[tokenId];
    }

}
