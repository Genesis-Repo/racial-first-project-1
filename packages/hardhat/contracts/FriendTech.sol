// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FriendTech is ERC721Enumerable, Ownable {
    mapping(address => uint256) private sharesPrice; // Mapping to store the price of shares for each user
    mapping(address => uint256) private totalSharesSupply; // Mapping to store the total supply of shares for each user
    mapping(address => mapping(address => uint256)) private userSharesBalance; // Mapping to track user's shares balance

    event SharesPriceSet(address indexed user, uint256 price);
    event SharesSupplySet(address indexed user, uint256 supply);
    event SharesBought(address indexed buyer, address indexed seller, uint256 amount);
    event SharesSold(address indexed seller, address indexed buyer, uint256 amount);
    event SharesTransferred(address indexed from, address indexed to, uint256 amount);

    constructor() ERC721("FriendTech", "FTCH") {}

    // Function to allow users to set the price of their shares
    function setSharesPrice(uint256 price) public {
        sharesPrice[msg.sender] = price;
        emit SharesPriceSet(msg.sender, price);
    }

    // Function to allow users to set their total supply of shares
    function setSharesSupply(uint256 supply) public {
        totalSharesSupply[msg.sender] = supply;
        emit SharesSupplySet(msg.sender, supply);
    }

    // Function for users to buy shares from another user
    function buyShares(address seller, uint256 amount) public payable {
        uint256 price = sharesPrice[seller];
        require(price > 0, "Seller has not set the price for the shares");
        require(msg.value >= price * amount, "Insufficient Ether sent");

        userSharesBalance[seller][msg.sender] += amount; // Corrected the logic for balance tracking
        userSharesBalance[msg.sender][seller] -= amount; // Adjusted for correct balance tracking

        payable(seller).transfer(msg.value); // Changed to transfer the sent value instead

        emit SharesBought(msg.sender, seller, amount);
    }

    // Function for users to sell shares to another user
    function sellShares(address buyer, uint256 amount) public {
        uint256 price = sharesPrice[msg.sender];
        require(price > 0, "You have not set the price for your shares");
        
        require(userSharesBalance[msg.sender][msg.sender] >= amount, "Insufficient shares balance");

        userSharesBalance[buyer][msg.sender] += amount; // Corrected the logic for balance tracking
        userSharesBalance[msg.sender][buyer] -= amount; // Adjusted for correct balance tracking

        emit SharesSold(msg.sender, buyer, amount);
    }

    // Function for users to transfer shares to another user
    function transferShares(address to, uint256 amount) public {
        require(userSharesBalance[msg.sender][msg.sender] >= amount, "Insufficient shares balance");

        userSharesBalance[to][msg.sender] += amount; // Corrected the logic for balance tracking
        userSharesBalance[msg.sender][to] -= amount; // Adjusted for correct balance tracking

        emit SharesTransferred(msg.sender, to, amount);
    }
}