// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IpayHolders {
    // payAllHolders
    // pushes ERC20 tokens to all holders of a specific token ID a share of the total payment amount.
    function payAllHolders(
        uint256 id,
        uint256 amount,
        address paymentTokenContract
    )  external returns (bool success);
    // dropToAllHolders
    // pushes ERC1155 tokens to all holders of a specific token ID a share of the total payment amount.
    function dropToAllHolders(
        uint256 id,
        uint256 dropTokenId,
        address dropTokenContract
    ) external returns (bool success);
    function recordAllHolders(
        uint256 id, 
        uint256 amount, 
        address paymentToken
    ) external returns(bool success);
    function withdraw(uint256 id) external returns(bool success);
}