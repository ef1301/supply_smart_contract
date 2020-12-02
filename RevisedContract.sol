/* Assignment04 - Smart Contract
 *
 * Members:
 * - Emily F: emily.fang11@myhunter.cuny.edu
 *
 * Repository link:
 * - https://github.com/ef1301/
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

/**
 * @title Owned
 * @dev Base contract to represent ownership of a contract
 * @dev Sourced from Mastering Ethereum at https://github.com/ethereumbook/ethereumbook
 */
contract Owned {
  address payable public owner;

  // Contract constructor: set owner
  constructor() {
    owner = msg.sender;
  }
  // Access control modifier
  modifier onlyOwner {
    require(msg.sender == owner,
            "Only the contract owner can call this function");
    _;
  }
}

/**
 * @title Mortal
 * @dev Base contract to allow for construct to be destructed
 * @dev Sourced from Mastering Ethereum at https://github.com/ethereumbook/ethereumbook
 */
contract Mortal is Owned {
  // Contract destructor
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }
}

/**
 * @title SupplyContract
 * @dev Implements payment contract system between a supplier and manufacturer
 */
contract SupplyContract is Mortal {
    enum Progress { Null, Purchased, InTransit, Delivered, Received }

    struct Product {
        uint prod_id;
        string prod_name;
        uint quantity;
        uint256 cost;
        uint manufacture_date;
    }

    struct Track_Product {
        uint prod_id;
        address product_owner;
        uint quantity;
        uint purchase_time;
        Progress status;
    }

    mapping(uint => Track_Product) public orders;
    uint order_tracking_num;
    Product inventory; // list of products in inventory, is dynamic array

    constructor(
        uint _prod_id,
        string memory _prod_name,
        uint _quantity,
        uint256 _cost
        ) {
        order_tracking_num = 1;
        Product memory first_inventory = Product(_prod_id, _prod_name, _quantity, _cost, block.timestamp);
        inventory = first_inventory;
    }

    //EVENTS
    event GetInventoryInfo (
        uint _prod_id,
        string _prod_name,
        uint _quantity,
        uint256 _cost,
        uint manufacture_date
    );

    event GetOrderInfo (
        uint _prod_id,
        string _prod_name,
        uint _quantity,
        uint256 _cost,
        Progress _status
    );

    event Purchase (
        uint _order_id,
        address _buyer,
        uint _quantity,
        uint _time_stamp
    );

    event InTransit (
        uint _order_id,
        address _buyer,
        uint _time_stamp
    );

    event Delivered (
        uint _order_id,
        address _buyer,
        uint _time_stamp
    );

    event Received (
        uint _order_id,
        address _buyer,
        uint _time_stamp
    );

    fallback() external { //fallback function //payable?
        //buyProductTokens(1);
    }

    function buyProduct(uint _quantity) payable public {
        uint256 cost = inventory.cost * _quantity;
        if(msg.value == cost && _quantity <= inventory.quantity) {
            owner.transfer(msg.value);
            Track_Product memory new_order = Track_Product(inventory.prod_id, msg.sender, _quantity, block.timestamp, Progress.Purchased);
            orders[order_tracking_num] = new_order;
            emit Purchase(order_tracking_num, msg.sender, _quantity, block.timestamp);
            order_tracking_num ++;
        }

    }

    function orderInTransit(uint _order_id) public onlyOwner {
        orders[_order_id].status = Progress.InTransit;
        emit Delivered(_order_id, orders[_order_id].product_owner, block.timestamp);
    }

    function orderDelivered(uint _order_id) public onlyOwner {
        orders[_order_id].status = Progress.Delivered;
        emit Delivered(_order_id, orders[_order_id].product_owner, block.timestamp);
    }

    function orderReceived(uint _order_id) public onlyOwner {
        orders[_order_id].status = Progress.Received;
        emit Received(_order_id, orders[_order_id].product_owner, block.timestamp);
    }

    /**
    * @dev Emits event to show requested product info
    */
    function getInventoryInfo() public {
        emit GetInventoryInfo(inventory.prod_id, inventory.prod_name, inventory.quantity, inventory.cost, inventory.manufacture_date);
    }

    /**
    * @dev Owner sets the quantity for a specific product
    * @param _quantity new product shipment
    */
    function inventoryRestock(uint _quantity) public onlyOwner {
        inventory.quantity = _quantity;
    }

    /**
    * @dev Adds new product to inventory
    * @param prodId new produt's id
    * @param _quantity new product's quantity
    * @param _cost new product's cost
    */
    function newInventory(uint256 prodId, string calldata _name, uint _quantity, uint256 _cost) public onlyOwner {
        Product memory p = Product(prodId, _name, _quantity, _cost, block.timestamp);
        delete inventory;
        inventory = p;
    }

    /**
    * @dev Removes product from inventory
    * @param prodId id of product to be removed
    */
    function removeProduct(uint256 prodId) public onlyOwner {
    }

}
