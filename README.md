# Supply Chain Smart Contract

## Group members:
-   Emily F: emily.fang11@myhunter.cuny.edu

## Purpose of Contract
To ensure that inventory/products are kept track of before distribution to consumers and retailers (from manufacturers to retailers), it is important that everything is kept inventory of and that products are produced and passed off to each supply chain body in a timely manner. Consequently, the focus of this smart contract is to secure this portion of the supply chain cycle. In this, we have manufacturers and retailers that are buying products from manufacturers before being exposed to the general public/consumers.

In short, this contract is in the realm of supply chain smart contracts, but it will be limited to the relationship between manufacturers that are delivering and charging for certain products and retailers that will be paying for the shipments and keeping track of their orders.

Additionally, with each restock, there are batch numbers associated with it.

All in all, we are keeping track of one product currently in inventory, orders, and batches (where a new patch is the restock of the product).

## Logic
The two parties involved are the manufacturer that produces and claim ownership over some product. The current product in stock or inventory and the history of batches/restocks are kept track of with the batch history; thus, with each restock of an item, a new "batch" of invntory is recorded.

Orders are kept track of and each party has a set of responsibilities.
* Manufacturer
  * Must update orders (Purchased, InTransit, Delivered). Without doing so, the retailer cannot state that they've received the product(s) and there is now a problem because they cannot claim ownership over it. Since these updates are emitted into the network, these updates can be used against manufacturers if they do not keep their end of the deal. If the manfuacturer attempts to claim the order's cost without the retailer claiming that they've received it, they therefore do not have the rights to that ether.
* Retailer
  * Must state that they have Received their order in order to be able to claim it. By not stating that they've received it, they cannot claim ownership of the product and without ownership, they cannot sell this product.
### [Styling of Interface](https://solidity.readthedocs.io/en/v0.5.13/style-guide.html)
