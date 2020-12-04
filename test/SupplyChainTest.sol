pragma solidity 0.5.16;

import "truffle/Assert.sol";
import "../contracts/SupplyChain.sol";

contract SupplyContractTest {
function testSettingAnOwnerDuringCreation() public {
         SupplyContract supplyChain = new SupplyContract('Rex Orange County Album Record: Apricot Princess', 2000, 250000000000000000);
         Assert.equal(supplyChain.owner(), address(this), "Owner is different than a deployer.");
}

function testSettingAnOwnerDuringCreation() public {
         SupplyContract supplyChain = new SupplyContract('Rex Orange County Album Record: Apricot Princess', 2000, 250000000000000000);
         Assert.equal(supplyChain.owner(), address(this), "Owner is different than a deployer.");
}

}
