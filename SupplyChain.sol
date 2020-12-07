/* Assignment04 - Smart Contract
 *
 * Members:
 * - Emily F: emily.fang11@myhunter.cuny.edu
 *
 * Repository link:
 * - https://github.com/ef1301/supply_smart_contract
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.6.0;

/**
 * @title Owned
 * @dev Base contract to represent ownership of a contract
 * @dev Sourced from Mastering Ethereum at https://github.com/ethereumbook/ethereumbook
 */
contract Owned {
  address payable public owner;

  // Contract constructor: set owner
  constructor() public {
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
 * @dev Implements payment contract system between a manufacturer and retailers that want to buy their product
 */
contract SupplyContract is Mortal {
    enum Progress {
         Null,
         Deposited,
         InTransit,
         Delivered,
         Received
    }

    struct Product {
        uint batch_id;
        string prod_name;
        uint quantity;
        uint256 cost;
        uint manufacture_date;
    }

    struct TrackProduct {
        uint batch_id;
        address product_owner;
        uint balance;
        uint purchase_time;
        Progress status;
    }

    mapping(uint => Product) public batchHistory;
    mapping(uint => TrackProduct) public orders;
    mapping(address => uint) public balance;

    uint order_tracking_num;
    uint current_batch_id;
    Product public inventory; // Current Product/Product Batch in inventory

    constructor(string memory _prod_name, uint _quantity, uint256 _cost) public {
        order_tracking_num = 1;
        current_batch_id = 0;
        Product memory first_inventory = Product(current_batch_id, _prod_name, _quantity, _cost, block.timestamp);
        inventory = first_inventory;
        batch_history[current_batch_id++] = inventory;
    }

    //EVENTS
    event GetInventoryInfo (
        uint _pro_id,
        string _prod_name,
        uint _quantity,
        uint256 _cost,
        uint manufacture_date
    );

    event GetOrderInfo (
        uint _order_id,
        uint _batch_id,
        uint _quantity,
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

   function fallback() external { //fallback function //payable?
        emit GetInventoryInfo(
             inventory.batch_id,
             inventory.prod_name,
             inventory.quantity,
             inventory.cost,
             inventory.manufacture_date
        );
    }

    /*receive() external payable {
        owner.transfer(msg.value);
    }*/

    function buyProduct(uint _quantity) payable public {
        require(inventory.quantity > 0, "None left in stock.");
        require(inventory.quantity >= _quantity, "Not enough in stock.");
        require(inventory.cost * 1 wei == msg.value, "Not enough payment.");

        owner.transfer(msg.value);
        Track_Product memory new_order = Track_Product(inventory.batch_id, msg.sender, _quantity, block.timestamp, Progress.Deposited);
        orders[order_tracking_num] = new_order;
        emit Purchase(
             order_tracking_num,
             msg.sender,
             _quantity,
             block.timestamp
        );
        order_tracking_num ++;
        inventory.quantity -= _quantity;

    }

    /**
    * @dev Emits event to show requested product info
    */
    function getInventoryInfo() public {
        emit GetInventoryInfo(inventory.batch_id, inventory.prod_name, inventory.quantity, inventory.cost, inventory.manufacture_date);
    }

        /**
    * @dev Emits event to show requested product info
    */
    function getOrderInfo(uint _order_id) public {
        require(_order_id <= order_tracking_num, "Order does not exist.");
        require(msg.sender == orders[_order_id].product_owner, "Not the product owner.");
        emit GetOrderInfo(
             _order_id, orders[_order_id].batch_id,
             orders[_order_id].balance,
             orders[_order_id].status
        );
    }


    function orderInTransit(uint _order_id) public onlyOwner {
        require(orders[_order_id].status == Progress.Deposited, "Payment not Deposited.");
        orders[_order_id].status = Progress.InTransit;
        emit Delivered(
             _order_id,
             orders[_order_id].product_owner,
             block.timestamp
        );
    }

    function orderReceived(uint _order_id) public {
        require(orders[_order_id].status == Progress.Delivered, "Not Delivered.");
        require(msg.sender == orders[_order_id].product_owner, "Not the product owner.");
        orders[_order_id].status = Progress.Received;
        balance[msg.sender] += orders[_order_id].balance;
        emit Received(
             _order_id,
             orders[_order_id].product_owner,
             block.timestamp
        );
    }


    function orderDelivered(uint _order_id) public onlyOwner {
        require(orders[_order_id].status == Progress.InTransit, "Not InTransit.");
        orders[_order_id].status = Progress.Delivered;
        emit Delivered(
             _order_id,
             orders[_order_id].product_owner,
             block.timestamp
        );
    }

    /**
    * @dev Owner sets the quantity for a specific product
    * @param _quantity new product shipment
    */
    function inventoryRestock(uint _quantity) public onlyOwner {
        require(inventory.quantity == 0);
        inventory.quantity += _quantity;
        inventory.manufacture_date = block.timestamp;
        inventory.batch_id ++;
        batchHistory[inventory.batch_id] = inventory;
    }
}
