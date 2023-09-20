// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC1155e { 
        function uri(uint id) view external returns (string memory);
        function setURI(uint id, string memory newuri) external;
        function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
        function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
        function balanceOf(address account, uint256 id) external view returns (uint256);
        function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external view returns (uint256[] memory);
        function setApprovalForAll(address operator, bool approved) external;
        function isApprovedForAll(address account, address operator) external view returns (bool);
        function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
        function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
        function getTotalTokens(uint256 id) external view returns (uint256);
        function getTokenOwners(uint256 id) external view returns (address[] memory);
        event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
        event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
        event ApprovalForAll(address indexed account, address indexed operator, bool approved);
        event URI(string value, uint256 indexed id);


}