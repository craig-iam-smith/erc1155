// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/// @dev - Author: Craig Smith (2023)
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Blacklistable Token
 * @dev addresses to be blacklisted by a "blacklister" role
 */
contract Blacklistable is Ownable {
    address private blacklister;
    mapping(address => bool) private blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @dev reverts if called by any account other than the blacklister
     */
    modifier onlyBlacklister() {
        require(msg.sender == blacklister, "Only blacklister");
        _;
    }

    /**
     * @dev Checks if account is blacklisted
     * @param _account The address to check
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }

    /**
     * @dev Adds account to blacklist
     * @param _account The address to blacklist
     */
    function blacklist(address _account) public onlyBlacklister {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    /**
     * @dev Removes account from blacklist
     * @param _account The address to remove from the blacklist
     */
    function unBlacklist(address _account) public onlyBlacklister {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    /**
     * @dev Changes the blacklister role
     * @param _newBlacklister The address of the new blacklister
     */
    function changeBlacklister(address _newBlacklister) public onlyOwner {
        require(
            _newBlacklister != address(0),
            "Blacklister can not be zero address"
        );
        blacklister = _newBlacklister;
        emit BlacklisterChanged(blacklister);
    }
}