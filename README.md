# Extensions to ERC-1155
Real-world assets require some extensions to ERC-1155 
Real-world problems:
1) Time-delay between agreement and the paperwork being completed
2) Changes in RWA asset value is a step function with possibility of data leakage
3) Lost keys / hacked accounts

This project implements an extension to ERC-1155 
  1) distributing ERC-20 payments to holders of ERC-1155 tokens (as a percentage of holdings)
  2) dropping different ERC-1155 tokens to holder of ERC-1155 tokens
  3) pause token by ID - due to the slow nature real world asset transactions, prevents actors from taking advantage of advance knowledge of RWA value change
  4) blacklist address - after an address has been compromised, removed and able to remint to be able to make users whole
  5) burnable
  6) URI by ID
     
  The payment function distributes ERC20 token:
    by ERC-1155 token id
    split by percentage holding of all holders
    has a push function (gas paid by contract)
    has a pull function (must be claimed ("gas paid" by the receiver)
    

```shell
yarn
yarn hardhat test
```
