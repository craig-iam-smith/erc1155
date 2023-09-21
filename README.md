# Extensions to ERC-1155

This project implements an extension to ERC-1155 
  1) distributing payments to holders of ERC-1155 tokens
  2) pause token by ID - due to the slow nature real world asset transactions, keeps actors from taking advantage of advance knowledge of RWA value change
  3) blacklist address - after an address has been compromised, removed and able to remint to be able to make users whole
  4) burnable
  5) URI by ID
     
  The payment function distributes ERC20 token:
    by ERC-1155 token id
    split by percentage holding of all holders
    has a push function (gas paid by contract)
    has a pull function (must be claimed ("gas paid" by the receiver)
    

```shell
yarn
yarn hardhat test
```
