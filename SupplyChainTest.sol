pragma solidity >=0.7.0 <0.8.0;

import "truffle/Assert.sol";
import "./RevisedContract.sol";

contract SupplyContractTest {
function testSettingAnOwnerDuringCreation() public {
         SupplyContract supplyChain = new SupplyContract('Rex Orange County Album Record: Apricot Princess', 2000, .025);
         Assert(supplyChain.owner(), this, "Owner is different than a deployer.");
}

function testProductPurchase() public {

}
}
