// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import ".././interfaces/IERC1155e.sol";



pragma solidity ^0.8.17;
contract payHolders is Ownable {
function recordAllHolders(uint256 id, uint256 amount, address paymentToken) public onlyOwner returns(bool success)
    {
        // record payments to all holders to a mapping from token id to array of holders and amounts
        // this is to be used to pay all holders later
        
        IERC20 payToken = IERC20(paymentToken);
        uint256 i;
        address to;
        uint256 totalTokens = _totalTokens[id];
        address[] memory payees = _tokenOwners[id];
        uint256 end = payees.length;
        require (paymentToken != address(0));
        require (payToken.balanceOf(msg.sender) > amount, "Must have enough of payment token");
        // 
        uint256 total=0;
        uint256 ownership;
        uint256 share;
        for (i=0;i<end;) {
            to = payees[i];
            ownership = balanceOf(to, id);
            share = ((amount * ownership) / totalTokens);
            _payments[id][to] += share;            
            total = total + share;
            unchecked {
                i++;}
        }
        success = true;
        require (total <= amount, "Total paid is more than amount");
    }
}