pragma solidity 0.5.16;

import "truffle/Assert.sol";
import "../contracts/SupplyChain.sol";

contract SupplyContractTest {
uint public initialBalance = 10 ether;
function testSettingAnOwnerDuringCreation() public {
         SupplyContract supplyChain = new SupplyContract('Rex Orange County Album Record: Apricot Princess', 2000, 250000000000000000);
         Assert.equal(supplyChain.owner(), address(this), "Owner is different than a deployer.");
}

function testPurchase() public {
         SupplyContract supplyChain = new SupplyContract('Rex Orange County Album Record: Apricot Princess', 2000, 250000000000000000);
         supplyChain.buyProduct.value(20)(500000000000000000);
         supplyChain.Product memory inventory =
         Assert.equal(supplyChain.inventory(), 1980, "Owner is different than a deployer.");
}
}
