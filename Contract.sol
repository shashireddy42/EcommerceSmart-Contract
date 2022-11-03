// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract ecommerce{
    // products info
    struct Product{
        string name;
        uint price;
        string desc;
        address payable seller;
        address payable buyer;
        uint id; 
        uint Ordertime;
        bool delivery;   
    }
    uint counter;
    //Events for differenet functions 
    event registered(uint id,string name, string desc,uint _price,address seller);
    event bought(uint id,uint price,uint time, address buyer);
    event status(uint id,uint time);

    Product[] public products;
    //Seller need to register his/her product
    function registerproduct(string memory _name, uint _price, string memory _desc) public {
        require(_price>0, "Price should not be zero ");
        counter++;
        Product memory material;
        material.name=_name;
        material.Ordertime=block.timestamp;
        material.price=_price* 1 ether;
        material.desc=_desc;
        material.seller=payable(msg.sender);
        material.id=counter;
        //Pushing all the products info to material list
        products.push(material);
        counter++;
        emit registered(material.id,_name,_desc,_price,msg.sender);
}
    receive() external payable{    
    }
    //Buyer need to buy his product by entering the products id 
    function buy(uint _id) payable public{
        require(products[_id-1].id<counter,"The id is not registerd");
        require(products[_id-1].price==msg.value,"Pay the exact ammount of price");
        require(products[_id-1].seller!=msg.sender,"seller cannot be buyer");
        (bool sent,)=address(this).call{value:products[_id-1].price}("");
        require(sent,"Transfer failed");  
        products[_id-1].buyer=payable(msg.sender);
        uint256 time=block.timestamp;
        
        emit bought(_id,msg.value,time,msg.sender);
    }
    //Seller&Buyer can check the Contract balance 
    function Contractbalance() public  view returns(uint256){
        return address(this).balance;
    }
    //After Delivery Buyer need to transfer the ammount to seller address
    function delivered(uint _id) payable public{
        require(products[_id-1].buyer==msg.sender,"Buyer should confirm the product");
        products[_id-1].delivery=true;
       (bool sent,)=products[_id-1].seller.call{value:products[_id-1].price}("");
        require(sent,"Transfer failed");
        uint256 time=block.timestamp;
        emit status(_id,time);
    }

}
