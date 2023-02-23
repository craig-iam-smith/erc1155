const { expect } = require("chai");
const { parseUnits } = require("ethers/lib/utils");
const { ethers, network } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");
require('dotenv').config();

describe("Token", function () {

    beforeEach(async function () {
        this.signers = await ethers.getSigners();
        this.owner = this.signers[0];
        this.bob = this.signers[1];
        this.carol = this.signers[2];
        this.dev = this.signers[3];
        this.minter = this.signers[4];
        this.burner = this.signers[5];
        this.alice = this.signers[6];
        const Token = await ethers.getContractFactory("ERC1155plus");
        this.token = await Token.deploy();
        await this.token.deployed();
    });
    

  
    describe("Deploy", function () {  
      it("Should set the right owner", async function () {
        await this.token.setURI("the URI we use");
        console.log("URI: ", await this.token.uri(0));

        expect(await this.token.owner()).to.equal(this.owner.address);
      });
  
    });

    describe("Mint", function () {  
        beforeEach(async function () {
            let id = 3;
            let amount = 0;
            let accum = 0;
            for (let i = 0; i < 20; i++) {
                amount = amount + 100;
                accum = accum + amount;
                await this.token.mint(this.signers[i].address, id, amount, "0xdeadbeef");
                expect(await this.token.balanceOf(this.signers[i].address, 3)).to.equal(amount);
                let balance = await this.token.getTotalTokens(id);
                expect(balance).to.equal(accum);          
            }
        });

        it("Should mint the right amount", async function () {
            let id = 3;
            let amount = 0;
            let accum = 0;
            for (let i = 0; i < 20; i++) {
                amount = amount + 100;
                accum = accum + amount;
            }
            let balance = await this.token.getTotalTokens(id);
            expect(balance).to.equal(accum);          
        });

        it("Check tokens owned", async function () {
            let id = 3;
            for (let i = 0; i < 20; i++) {
                let ids = await this.token.getTokensOwned(this.signers[i].address);
                for(let j = 0; j < ids.length; j++) {
                    expect(ids[j]).to.equal(id);
                }
            }
        });
        
        it("Check owners of tokens", async function () {
            let id = 3;
            let owners = await this.token.getOwnersOfToken(id);
            for(let j = 0; j < owners.length; j++) {
                expect(owners[j]).to.equal(this.signers[j].address);
            }
        });

        it("Check token balances", async function () {
            let id = 3;
            let amount = 0;
            for (let i = 0; i < 20; i++) {
                amount = amount + 100;
                expect(await this.token.balanceOf(this.signers[i].address, 3)).to.equal(amount);
            }
        });

    });
  
    describe("Burn", function () {  
        beforeEach(async function () {
            let id = 3;
            let amount = 0;
            let accum = 0;
            for (let i = 0; i < 20; i++) {
                amount = amount + 100;
                accum = accum + amount;
                await this.token.mint(this.signers[i].address, id, amount, "0xdeadbeef");
            }
        });
    
        it("Burn tokens", async function () {   
            let id = 3;
            let amount = 100;
            await this.token.burn(this.signers[0].address, id, amount);
            expect(await this.token.balanceOf(this.signers[0].address, 3)).to.equal(0);
            await this.token.connect(this.signers[1]).burn(this.signers[1].address, id, amount);
            expect(await this.token.balanceOf(this.signers[1].address, 3)).to.equal(100);
            let owners = await this.token.getOwnersOfToken(id);
            expect(owners.length).to.equal(19);
        });
        it("Burn different tokens", async function () {   
            let id = 3;
            let amount = 500;
            await this.token.connect(this.signers[4]).burn(this.signers[4].address, id, amount);
            expect(await this.token.balanceOf(this.signers[4].address, 3)).to.equal(0);
            await this.token.connect(this.signers[5]).burn(this.signers[5].address, id, amount);
            expect(await this.token.balanceOf(this.signers[5].address, 3)).to.equal(100);
            let owners = await this.token.getOwnersOfToken(id);
            expect(owners.length).to.equal(19);
//            for (let i = 0; i < 20; i++) {
//                let balance = await this.token.balanceOf(this.signers[i].address, 3);
//                for (let j = 0; j < owners.length; j++) {
//                    if (this.signers[i].address == owners[j]) {
//                        console.log("Owners[j] : Balance: ", i, j, owners[j], balance.toString());
//                    }
//                }          
//            }
        });
    });

    describe("Mint Batch", function () {  
        beforeEach(async function () {
            let id = 3;
            let accum = 6000;
            let ids = [4,5,6];
            let amounts = [1000, 2000, 3000];
            await this.token.mintBatch(this.signers[0].address, ids, amounts, "0xdeadbeef");
            await this.token.mintBatch(this.signers[1].address, ids, amounts, "0xdeadbeef");
            await this.token.mintBatch(this.signers[2].address, ids, amounts, "0xdeadbeef");
            expect(await this.token.balanceOf(this.signers[2].address, ids[1])).to.equal(amounts[1]);
            for (let i=0; i<ids.length; i++) {
                let balance = await this.token.getTotalTokens(ids[i]);
                expect(balance).to.equal(amounts[i]*3);  
            }
         
        })
            
    
        it("Should mint the right amount", async function () {
            let id = 4;
            let amount = 0;
            let accum = 1000;
            
            let balance = await this.token.getTotalTokens(id);
            expect(balance).to.equal(accum*3);          
        });
    
        it("Check tokens owned", async function () {
            let idds = [4,5,6];
            for (let i = 0; i < 3; i++) {
                let ids = await this.token.getTokensOwned(this.signers[i].address);
                for(let j = 0; j < ids.length; j++) {
                    expect(ids[j]).to.equal(idds[j]);
                }
            }
        });
    /*        
            it("Check owners of tokens", async function () {
                let id = 3;
                let owners = await this.token.getOwnersOfToken(id);
                for(let j = 0; j < owners.length; j++) {
                    expect(owners[j]).to.equal(this.signers[j].address);
                }
            });
    
            it("Check token balances", async function () {
                let id = 3;
                let amount = 0;
                for (let i = 0; i < 20; i++) {
                    amount = amount + 100;
                    expect(await this.token.balanceOf(this.signers[i].address, 3)).to.equal(amount);
                }
            });
            */
        });    
    });
        

    
  
  