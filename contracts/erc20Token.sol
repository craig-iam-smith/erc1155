// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//--------------------------------------
// Craig: ERC20 Token contract
//
// Symbol      : CRAIG
// Name        : Craig
// Total supply: 1000
// Decimals    : 18
//--------------------------------------
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Craig is ERC20{
  constructor() ERC20("Craig", "CRAIG") {
    _mint(msg.sender, 1000 * 10 ** uint256 (decimals()));
  }
}
