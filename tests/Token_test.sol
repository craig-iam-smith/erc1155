// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "../contracts/Token.sol";

contract MyTokenTest {

    Tokens;
    function beforeAll () public {
        s = new Token();
    }

    function testSetURI () public {
        string memory uri = "https://testuri.io/token";
        s.setURI(uri);
        Assert.equal(s.uri(1), uri, "uri did not match");
    }
}