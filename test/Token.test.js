const { expect } = require("chai");
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
        const craigToken = await ethers.getContractFactory("Craig");
        this.ctoken = await craigToken.deploy();
        await this.ctoken.deployed();
    });
    

    describe("ERC20", function () {  
        it("Should set the right owner", async function () {
            let name = await this.ctoken.name();
            let symbol = await this.ctoken.symbol();
            let decimals = await this.ctoken.decimals();
            let totalSupply = await this.ctoken.totalSupply();
            let balance = await this.ctoken.balanceOf(this.owner.address);
            let tx = await this.ctoken.transfer(this.bob.address, ethers.utils.parseUnits('10', decimals)) 
            await tx.wait()
            expect(await this.ctoken.balanceOf(this.bob.address)).to.equal(ethers.utils.parseUnits('10', decimals))
        });   
    });

    describe("Deploy", function () {  
      it("Should set the right owner", async function () {
        await this.token.setURI(1, "the URI we use");
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
        });

        
        it("burn blacklisted", async function () {
            let id = 3;
            let amount = 100;
            await this.token.changeBlacklister(this.owner.address);
            await this.token.blacklist(this.signers[4].address);
            await expect(this.token.connect(this.signers[4]).burn(this.signers[4].address, id, amount)).to.be.reverted;
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

        it("Mint blacklisted", async function () {
            let id = 4;
            let amount = 0;
            let accum = 1000;
            let ids = [4,5,6];
            let amounts = [1000, 2000, 3000];
            let balance = await this.token.getTotalTokens(id);
            expect(balance).to.equal(accum*3);          

            await this.token.changeBlacklister(this.owner.address);
            await this.token.blacklist(this.signers[2].address);            
            await expect(this.token.mintBatch(this.signers[2].address, ids, amounts, "0xdeadbeef")).to.be.reverted;
            
            balance = await this.token.getTotalTokens(id);
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
            
        it("Check owners of tokens", async function () {
            let idds = [4,5,6];
            for (let i = 0; i < 3; i++) {
                let owners = await this.token.getOwnersOfToken(idds[i]);
                for(let j = 0; j < owners.length; j++) {
                    expect(owners[j]).to.equal(this.signers[j].address);
                };
            }
        });

        it("Check token balances", async function () {
                let idds = [4,5,6];
                let amounts = [1000, 2000, 3000];
                let amount = 0;
                let decimals = await this.ctoken.decimals();
                for (let i = 0; i < 3; i++) {
                    let ids = await this.token.getTokensOwned(this.signers[i].address);
                    for(let j = 0; j < ids.length; j++) {

                        expect(await this.token.balanceOf(this.signers[i].address, 4+j)).to.equal(amounts[j]);
                    }
                }
            });
        });    
        describe("Pay Holders", function () {  
            beforeEach(async function () {
                let ids = [4,5,6];
                let amounts = [1000, 2000, 3000];
                await this.token.mintBatch(this.signers[3].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[4].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[5].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[6].address, ids, amounts, "0xdeadbeef");
                expect(await this.token.balanceOf(this.signers[4].address, ids[1])).to.equal(amounts[1]);
                for (let i=0; i<ids.length; i++) {
                    let balance = await this.token.getTotalTokens(ids[i]);
                    expect(balance).to.equal(amounts[i]*4);  
                }
             
            })
                
        
            it("Pay Holders of an ID", async function () {
                let id = 4;
                let decimals = await this.ctoken.decimals();
                let amount = 10 * 10**decimals;
                let accum = 1000;
                let tx = await this.ctoken.transfer(this.token.address, ethers.utils.parseUnits('10', decimals)) 
                await tx.wait()
                expect(await this.ctoken.balanceOf(this.token.address)).to.equal(ethers.utils.parseUnits('10', decimals))
                await this.ctoken.approve(this.token.address, ethers.utils.parseUnits('10', decimals))
                
                await this.token.payAllHolders(id, ethers.utils.parseUnits('10',decimals), this.ctoken.address);

                for (let i = 0; i < 4; i++) {
                    let balance = await this.ctoken.balanceOf(this.signers[i+3].address);
                    expect (balance).to.equal(ethers.utils.parseUnits('2.5', decimals));
                    
                };          
            });
            it("Drop NFT tokens to holders of an ID", async function () {
                let id = 4;
                let decimals = await this.ctoken.decimals();
                let amount = 10 * 10**decimals;
                let accum = 1000;
                let tx = await this.ctoken.transfer(this.token.address, ethers.utils.parseUnits('10', decimals)) 
                await tx.wait()
                expect(await this.ctoken.balanceOf(this.token.address)).to.equal(ethers.utils.parseUnits('10', decimals))
                await this.ctoken.approve(this.token.address, ethers.utils.parseUnits('10', decimals))
                
                await this.token.payAllHolders(id, ethers.utils.parseUnits('10',decimals), this.ctoken.address);

                for (let i = 0; i < 4; i++) {
                    let balance = await this.ctoken.balanceOf(this.signers[i+3].address);
                    expect (balance).to.equal(ethers.utils.parseUnits('2.5', decimals));
                    
                };          
            });

        });
        describe("Pause Token by ID", function () {  
            const ids = [4,5,6];
            let amounts = [1000, 2000, 3000];
            beforeEach(async function () {
                await this.token.mintBatch(this.signers[3].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[4].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[5].address, ids, amounts, "0xdeadbeef");
                await this.token.mintBatch(this.signers[6].address, ids, amounts, "0xdeadbeef");
                for (let i=0; i<ids.length; i++) {
                    let balance = await this.token.getTotalTokens(ids[i]);
                    expect(balance).to.equal(amounts[i]*4);  
                }
             
            })
                
        
            it("Pay Holders of an ID", async function () {
                let id = 4;
                let decimals = await this.ctoken.decimals();
                let amount = 10 * 10**decimals;
                let accum = 1000;
                let tx = await this.ctoken.transfer(this.token.address, ethers.utils.parseUnits('10', decimals)) 
                await tx.wait()
                expect(await this.ctoken.balanceOf(this.token.address)).to.equal(ethers.utils.parseUnits('10', decimals))
                await this.ctoken.approve(this.token.address, ethers.utils.parseUnits('10', decimals))
                
                await this.token.payAllHolders(id, ethers.utils.parseUnits('10',decimals), this.ctoken.address);

                for (let i = 0; i < 4; i++) {
                    let balance = await this.ctoken.balanceOf(this.signers[i+3].address);
                    expect (balance).to.equal(ethers.utils.parseUnits('2.5', decimals));
                    
                };          
            });
            it("Drop NFT tokens to holders of an ID", async function () {
                let id = 4;
                let decimals = await this.ctoken.decimals();
                let amount = 10 * 10**decimals;
                let accum = 1000;
                let tx = await this.ctoken.transfer(this.token.address, ethers.utils.parseUnits('10', decimals)) 
                await tx.wait()
                expect(await this.ctoken.balanceOf(this.token.address)).to.equal(ethers.utils.parseUnits('10', decimals))
                await this.ctoken.approve(this.token.address, ethers.utils.parseUnits('10', decimals))
                
                await this.token.payAllHolders(id, ethers.utils.parseUnits('10',decimals), this.ctoken.address);

                for (let i = 0; i < 4; i++) {
                    let balance = await this.ctoken.balanceOf(this.signers[i+3].address);
                    expect (balance).to.equal(ethers.utils.parseUnits('2.5', decimals));
                    
                };          
            });
            it ("Pause token", async function () {
                await this.token.pauseToken(ids[1]);
                /// expect transferFrom to fail

                await expect(
                    this.token.connect(this.signers[3]).safeTransferFrom(this.signers[3].address, this.signers[4].address, ids[1], 1000, "0xdeadbeef")
                ).to.be.revertedWith("ERC1155Pausable: token transfer while paused");
                await this.token.unPauseToken(ids[1]);
                /// expect transferFrom to succeed
                await this.token.connect(this.signers[3]).safeTransferFrom(this.signers[3].address, this.signers[4].address, ids[1], 1000, "0xdeadbeef")


                expect(await this.token.balanceOf(this.signers[4].address, ids[1])).to.equal(amounts[1]+1000);
            });


        });
        describe("URI", function () {  
            it("URI by id", async function () {
              await this.token.setURI(1, "the URI we use");
              console.log("URI: ", await this.token.uri(0));
      
              expect(await this.token.owner()).to.equal(this.owner.address);
            });
        
          });
          
    });
        

    
  
  