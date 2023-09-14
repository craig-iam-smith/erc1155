// SPDX-License-Identifier: MIT
// Author: Craig Smith (./extensions/ERC1155PausableID.sol)

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades when there is a pending RWA transaction
 * reduces ability to take advantage of a step function in the value of the asset
 *
*/
abstract contract ERC1155PausableID is ERC1155, Ownable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    mapping(uint256 => bool) private _pausedID;
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        uint idsLength = ids.length;
        uint i;
        for (i = 0; i < idsLength; ++i) {
            require(!_pausedID[ids[i]], "ERC1155Pausable: token transfer while paused");
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
/// @dev Pauses all token transfers of this ID
    function pauseToken(uint id) public onlyOwner {
        _pausedID[id] = true;
    }
/// @dev Pauses all token transfers of this ID
    function unPauseToken(uint id) public onlyOwner {
        _pausedID[id] = false;
    }

}
