// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IERC1155e.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.17;

contract payHolders is Ownable {
    IERC1155e public _tokenContract;
    IERC20 public _payToken;
    mapping(uint256 => mapping(address => uint256[])) payments;

    constructor(IERC1155e tokenContract_, IERC20 payToken_) {
        _tokenContract = IERC1155e(tokenContract_);
        _payToken = IERC20(payToken_);
    }

    // function payAllHolders
    /// @notice Pays all holders of a specific token ID a share of the total payment amount.
    /// @dev If there are more than maxPayout holders, the function will fail to prevent gas limit issues.
    /// @dev To prevent this, use payAllHoldersInBatches instead.
    /// @param id The ID of the token to pay holders for.
    /// @param amount The total payment amount to distribute.
    /// @param paymentTokenContract The address of the payment token contract to distribute.
    /// @return success Returns true if successful.
    /// @dev TODO implement payAllHoldersInBatches

    function payAllHolders(
        uint256 id,
        uint256 amount,
        address paymentTokenContract
    ) public onlyOwner returns (bool success) {
        IERC20 payToken = IERC20(paymentTokenContract);
        uint256 i;
        address to;
        uint256 totalTokens = _tokenContract.getTotalTokens(id);
        address[] memory payees = _tokenContract.getTokenOwners(id);
        uint256 end = payees.length;

        require(paymentTokenContract != address(0));
        require(
            payToken.balanceOf(msg.sender) > amount,
            "Must have enough of payment token"
        );
        uint256 total;
        uint256 ownership;
        uint256 share;
        // @dev - todo check if active, add visibility
        // require(_status[id] == Status.Active, "Token is not active");
        if (end > _tokenContract.maxPayout()) {
            success = false;
            return success;
        }
        for (i = 0; i < end; ) {
            to = payees[i];
            ownership = _tokenContract.balanceOf(to, id);
            share = ((amount * ownership) / totalTokens);
            success = payToken.transferFrom(msg.sender, to, share);
            require(success, "Transfer failed");
            total = total + share;
            unchecked {
                i++;
            }
        }
        success = true;
        require(total <= amount, "Total paid is more than amount");
    }

    // payment function dropToAllHolders
    /// @dev Drops an ERC1155 token to all holders of a specific token ID.
    /// @param id The ID of the token held.
    /// @param dropTokenId The ID of the token to drop.
    /// @param dropTokenContract The address of the drop token contract.
    /// 

    function dropToAllHolders(
        uint256 id,
        uint256 dropTokenId,
        address dropTokenContract
        ) public onlyOwner returns (bool success) {
        success = false;
        IERC1155e dropToken = IERC1155e(dropTokenContract);
        uint256 i;
        address to;
        address[] memory payees = _tokenContract.getTokenOwners(id);
        uint256 end = payees.length;
        require(dropTokenContract != address(0));
        require(
            dropToken.balanceOf(msg.sender, dropTokenId) >= end,
            "Must have enough of payment ERC1155 token"
        );
        for (i = 0; i < end; ) {
            to = payees[i];
            dropToken.safeTransferFrom(
                msg.sender,
                to,
                dropTokenId,
                1,
                bytes("")
            );
            unchecked {
                i++;
            }
        }
        success = true;
    }

// payment function recordAllHolders
/// @notice Records payments to all holders to a mapping from token id to array of holders and amounts
/// @notice payees can then withdraw their share of the payment
/// @param id - token id of the token held
/// @param amount - amount of payment token to record
/// @param paymentToken - address of the payment token contract
    function recordAllHolders(
        uint256 id,
        uint256 amount,
        address paymentToken
    ) public onlyOwner returns (bool success) {
        // record payments to all holders to a mapping from token id to array of holders and amounts
        // this is to be used to pay all holders later

        IERC20 payToken = IERC20(paymentToken);
        uint256 i;
        address to;
        uint256 totalTokens = _tokenContract.getTotalTokens(id);
        address[] memory payees = _tokenContract.getTokenOwners(id);
        uint256 end = payees.length;
        require(paymentToken != address(0));
        require(
            payToken.balanceOf(msg.sender) > amount,
            "Must have enough of payment token"
        );
        //
        uint256 total = 0;
        uint256 ownership;
        uint256 share;
        for (i = 0; i < end; ) {
            to = payees[i];
            ownership = _tokenContract.balanceOf(to, id);
            share = ((amount * ownership) / totalTokens);
            payments[id][to].push(share);
            total = total + share;
            unchecked {
                i++;
            }
        }
        success = payToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        require(total <= amount, "Total paid is more than amount");
    }
    // payment function - withdraw
    /// @notice allows payees to withdraw their share payments
    /// @param id - token id of the token held

    function withdraw(uint256 id) external {
        require(msg.sender != address(0));
        uint256[] memory amounts = payments[id][msg.sender];
        uint256 i;
        uint256 end = amounts.length;
        uint256 total = 0;

        for (i = 0; i < end; ) {
            total = total + amounts[i];
            unchecked {
                i++;
            }
        }

        require(total > 0, "No payments to withdraw");
        require(
            _payToken.balanceOf(address(this)) >= total,
            "Not enough funds to withdraw"
        );
        bool success = _payToken.transfer(msg.sender, total);
        require(success, "Transfer failed");
    }
}
