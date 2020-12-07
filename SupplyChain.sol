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

    uint order_tracking_num; //count of current order
    uint current_batch_id; //count of current batch
    Product public inventory; // Current Product/Product Batch in inventory

    mapping(uint => Product) public batchHistory; //tracks batches/restocks
    mapping(uint => TrackProduct) public orders; //tracks orders
    mapping(address => uint) public balance; //balance/quantity of products owned by each address

    constructor(string memory _prod_name, uint _quantity, uint256 _cost) public {
        order_tracking_num = 1;
        current_batch_id = 0;
        Product memory first_inventory = Product(current_batch_id, _prod_name, _quantity, _cost, block.timestamp);
        inventory = first_inventory;
        batchHistory[current_batch_id++] = inventory;
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

   function fallback() external {
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


    /**
    * @dev Sender purchases product in inventory and emits the Purchase event.
    * @param _quantity the quantity of products to be ordered
    */
    function buyProduct(uint _quantity) payable public {
        require(inventory.quantity > 0, "None left in stock.");
        require(inventory.quantity >= _quantity, "Not enough in stock.");
        require(inventory.cost * 1 wei == msg.value, "Not enough payment.");

        owner.transfer(msg.value);
        TrackProduct memory new_order = TrackProduct(inventory.batch_id, msg.sender, _quantity, block.timestamp, Progress.Deposited);
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
    * @dev Emits the details of the current product/inventory.
    */
    function getInventoryInfo() public {
        emit GetInventoryInfo(
            inventory.batch_id,
            inventory.prod_name,
            inventory.quantity,
            inventory.cost,
            inventory.manufacture_date
        );
    }

    /**
    * @dev Emits the details of a dispatched order.
    * @param _order_id the id of the order whose info is needed/called
    */
    function getOrderInfo(uint _order_id) public {
        require(_order_id <= order_tracking_num, "Order does not exist.");
        emit GetOrderInfo(
             _order_id, orders[_order_id].batch_id,
             orders[_order_id].balance,
             orders[_order_id].status
        );
    }


    /**
    * @dev Owner sets the Received status when order is received by new owner and emits the Received event.
    * @param _order_id the id of the order received, sender must be the new owner
    */
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

    /**
    * @dev Owner sets the Delivered status when order is in transit and emits the InTransit event.
    * @param _order_id the id of the order in InTransit/out for delivery.
    */
    function orderInTransit(uint _order_id) public onlyOwner {
        require(orders[_order_id].status == Progress.Deposited, "Payment not Deposited.");
        orders[_order_id].status = Progress.InTransit;
        emit Delivered(
             _order_id,
             orders[_order_id].product_owner,
             block.timestamp
        );
    }

    /**
    * @dev Owner sets the Delivered status when order is delivered and emtis the Delivered event.
    * @param _order_id the id of the order delivered
    */
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
    * @dev Owner resets the quantity or restocks on current product/inventory
    * @param _quantity restock quantity
    */
    function inventoryRestock(uint _quantity) public onlyOwner {
        require(inventory.quantity == 0);
        inventory.quantity += _quantity;
        inventory.manufacture_date = block.timestamp;
        inventory.batch_id ++;
        batchHistory[inventory.batch_id] = inventory;
    }
}
