// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IERC1155e.sol";
import "hardhat/console.sol";


pragma solidity ^0.8.17;
contract payHolders is Ownable {
    IERC1155e public immutable _tokenContract;
    IERC20 public immutable _payToken;
    mapping(uint256 =>  mapping (address => uint256[])) payments;
constructor (IERC1155e tokenContract_, IERC20 payToken_){
    _tokenContract = IERC1155e(tokenContract_);
    _payToken = IERC20(payToken_);
}
function recordAllHolders(uint256 id, uint256 amount, address paymentToken) public onlyOwner returns(bool success)
    {
        // record payments to all holders to a mapping from token id to array of holders and amounts
        // this is to be used to pay all holders later
        
        IERC20 payToken = IERC20(paymentToken);
        uint256 i;
        address to;
        uint256 totalTokens = _tokenContract.getTotalTokens(id);
        address[] memory payees = _tokenContract.getTokenOwners(id);
        uint256 end = payees.length;
        require (paymentToken != address(0));
        require (payToken.balanceOf(msg.sender) > amount, "Must have enough of payment token");
        // 
        uint256 total=0;
        uint256 ownership;
        uint256 share;
        for (i=0;i<end;) {
            to = payees[i];
            ownership = _tokenContract.balanceOf(to, id);
            share = ((amount * ownership) / totalTokens);
            payments[id][to].push(share);
            total = total + share;
            unchecked {
                i++;}
        }
        success = payToken.transferFrom(msg.sender, address(this), amount);
        require (success, "Transfer failed");

        require (total <= amount, "Total paid is more than amount");
    }
    function withdraw(uint256 id) external {
        require (msg.sender != address(0));
        uint256[] memory amounts = payments[id][msg.sender];
        uint256 i;
        uint256 end = amounts.length;
        uint256 total = 0;
        
        for (i=0;i<end;) {
            total = total + amounts[i];
            unchecked {
                i++;}
        }

        require (total > 0, "No payments to withdraw");
        require (_payToken.balanceOf(address(this)) >= total, "Not enough funds to withdraw");
        bool success =_payToken.transfer(msg.sender, total);
        require (success, "Transfer failed");
    }
}