// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IERC1155e.sol";
// import "hardhat/console.sol";

contract ReMint {
    IERC1155e public immutable _tokenContract;

    constructor (IERC1155e tokenContract_){
        _tokenContract = IERC1155e(tokenContract_);
    }
   function redo (uint256 id, uint256 quantity, address compromised, address secured) external {
        // token contract
        // this is the id of the token
        // @dev - todo  
        // check to see if tokens are still at compromised address
        // burn tokens @ compromised address
        // if not - check transaction history to find and burn
        // blacklist compromised address
        // require new address  whitelisted
        // mint new tokens to new secured address


    }
}
