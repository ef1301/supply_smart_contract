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
    enum Progress { Null, InStock, Deposited, InTransit, Delivered }

    struct Product {
        uint256 prod_id;
        string prod_name;
        uint quantity;
        uint256 cost;
        Progress status;
    }

    struct Supplier {
        uint256 id; // unique identifier for tenant
        address payable account; // supplier's billing address
        Product[] catalog;
    }

    Product[] inventory; // list of products in inventory, is dynamic array
    uint minQuantity;
    uint inventoryCount;

    constructor(
        uint _minQuantity
    ) {
        minQuantity = _minQuantity;
    }

    //EVENTS
    event productPayment(
        address indexed _from,
        bytes32 indexed _id,
        uint256 _value
    );

    event GetProductInfo(
        uint256 productID,
        string prodName,
        uint numInStock,
        uint256 price,
        Progress progress
    );

    /**
    * @dev Emits event to show requested product info
    * @param prodId id of product being requested
    */
    function getProduct(uint256 prodId) public {
        for (uint i = 0; i < inventory.length; i++){
            if (inventory[i].prod_id == prodId){
                emit GetProductInfo(inventory[i].prod_id, inventory[i].prod_name, inventory[i].quantity, inventory[i].cost, inventory[i].status);
                break;
            }
        }
    }

    /**
    * @dev Payment is made from owner of contract to supplier for specific product
    * @param prodId id of product being requested
    * @param _quantity new product shipment
    */
    function productRequests(uint256 prodId, uint _quantity) public onlyOwner {
        /** Find correct tenant by ID */
        for (uint i = 0; i < inventory.length; i++){
            if (inventory[i].prod_id == prodId){
                //ERROR
                //emit productPayment(owner, prodId, inventory[i].cost * _quantity);

                inventory[i].quantity += _quantity;

                break;
            }
        }
    }


    /**
    * @dev Owner sets the quantity for a specific product
    * @param prodId id of product being requested
    * @param _quantity new product shipment
    */
    function setInventory(uint256 prodId, uint _quantity) public onlyOwner {
        /** Find correct tenant by ID */
        for (uint i = 0; i < inventory.length; i++){
            if (inventory[i].prod_id == prodId){
                /** Refund security deposit */
                inventory[i].quantity = _quantity;
                break;
            }
        }
    }

    /**
    * @dev Adds new product to inventory
    * @param prodId new produt's id
    * @param _quantity new product's quantity
    * @param _cost new product's cost
    */
    function addNewProduct(uint256 prodId, string calldata _name, uint _quantity, uint256 _cost) public onlyOwner {
        Progress progress = Progress.InStock;
        Product memory p = Product(prodId, _name, _quantity, _cost, progress);
        inventory.push(p);
    }

    /**
    * @dev Removes product from inventory
    * @param prodId id of product to be removed
    */
    function removeProduct(uint256 prodId) public onlyOwner {
        /** Find correct tenant by ID */
        for (uint i = 0; i < inventory.length; i++){
            if (inventory[i].prod_id == prodId){

                Product memory p = inventory[i];
                inventory[i] = inventory[inventory.length-1];
                inventory[inventory.length-1] = p;
                delete inventory[inventory.length-1];
                //inventory.length--;
                break;
            }
        }
    }

    /**
    * @dev Checks for the exist of a product in inventory iwth given id
    * @param prodId product id
    */
    function productExists(uint256 prodId) public onlyOwner{

        //return true;
    }
}
