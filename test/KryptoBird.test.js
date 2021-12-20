const { assert } = require("chai");

const KryptoBird = artifacts.require("./KryptoBird");

require("chai")
  .use(require("chai-as-promised"))
  .should();

contract("KryptoBird", (accounts) => {
  let contract;
  // testing container
  //before tells the tests to run this before anything else is done
  before(async () => {
    contract = await KryptoBird.deployed();
  });

  describe("deployment", async () => {
    //test samples by writing "it"
    it("deploys successfully", async () => {
      const address = contract.address;
      assert.notEqual(address, "");
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
      assert.notEqual(address, 0x0);
    });

    it("name matches from contract", async () => {
      const contractName = await contract.name();
      assert.equal(contractName, "KryptoBird");
    });

    it("Symbol did match from contract", async () => {
      const contractSymbol = await contract.symbol();
      assert.equal(contractSymbol, "KBIRDZ");
    });
  });

  describe("minting", async () => {
    it("creates a new token", async () => {
      const resultMint = await contract.mint("https...1");
      const totalSupply = await contract.totalSupply();
      //successfully
      assert.equal(totalSupply, 1);
      const event = resultMint.logs[0].args;
      assert.equal(
        event._from,
        "0x0000000000000000000000000000000000000000",
        "_from is the contract"
      );
      assert.equal(event._to, accounts[0], "_to is the msg.sender");

      //failure
      await contract.mint("https...1").should.be.rejected;
    });
  });

  describe("indexing", async () => {
    it("lists KryptoBirdz", async () => {
      //mint 2 new tokens
      await contract.mint("https...2");
      await contract.mint("https...3");
      await contract.mint("https...4");
      const totalSupply = await contract.totalSupply();

      //loop through list and grab KBridz from list
      let result = [];
      let KryptoBird;

      for (i = 1; i <= totalSupply; i++) {
        KryptoBird = await contract.kryptoBirdz(i - 1);
        result.push(KryptoBird);
      }

      //assert that our new array result will equal our expexted result
      let expected = ["https...1", "https...2", "https...3", "https...4"];
      assert.equal(result.join(","), expected.join(","));
    });
  });
});
