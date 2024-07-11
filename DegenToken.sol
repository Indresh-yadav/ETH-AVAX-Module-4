// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DegenToken is ERC20, Ownable {

    uint256 public tokenPrice = 1;

    struct ItemRedeemed {
        uint256 quantity;          
        uint256 tokensRedeemed;  
    }
    

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {}

    event TokensRedeemed(address indexed user, uint256 quantity, uint256 tokensRedeemed);

    mapping(address => ItemRedeemed[]) private ItemRedeemeds;

    function mintTokens(address to, uint256 quantity) public onlyOwner { 
        require(to != address(0), "Minting to zero address is not possible");
        require(quantity > 0, "Mint quantity must be greater than zero");
        _mint(to, quantity);
    }


    function checkTokenBalance(address account) public view returns (uint256) { 
        require(account != address(0), "You eneterd zero address, that is not possible");
        return balanceOf(account);
    }

    function transferTokens(address from, address to, uint256 quantity) public { 
        require(from != address(0), "Transfer from zero address is not allowed");
        require(to != address(0), "Transfer to zero address is not allowed");

        if (from == _msgSender()) {
            _transfer(from, to, quantity);
        } else {
            uint256 currentAllowance = allowance(from, _msgSender());
            require(currentAllowance >= quantity, "Transfer quantity exceeds allowance");
            _approve(from, _msgSender(), currentAllowance - quantity);
            _transfer(from, to, quantity);
        }
    }

    function burnTokens(uint256 quantity) public { 
        require(quantity > 0, "The burn quantity needs to exceed zero.");
        _burn(_msgSender(), quantity);
    }

    function redeemTokens(uint256 quantity) public { 
        require(quantity > 0, "The quantity for redemption must be greater than zero.");
        uint256 cost = quantity * tokenPrice;
        require(balanceOf(_msgSender()) >= cost, "Insufficient token balance");

        _burn(_msgSender(), cost);

        ItemRedeemeds[_msgSender()].push(ItemRedeemed({
            quantity: quantity,
            tokensRedeemed: cost
        }));

        emit TokensRedeemed(_msgSender(), quantity, cost);
    }

    function printRedeemedTokensList(address account) public view returns (string memory) { 
        require(account != address(0), "Query for zero address not possible");
        ItemRedeemed[] memory items = ItemRedeemeds[account];
        require(items.length > 0, "No redeemed tokens found");

        string memory redemptionDetails = "";
        for (uint256 index = 0; index < items.length; index++) {
            redemptionDetails = string(abi.encodePacked(redemptionDetails,
            "Redemption Item ", uintToString(index + 1), ": ",
            "Quantity Redeemed: ", uintToString(items[index].quantity),
            "Tokens Redeemed: ", uintToString(items[index].tokensRedeemed),"\n"));
        }
        return redemptionDetails;
    }

    function uintToString(uint256 v) internal pure returns (string memory) { 
        if (v == 0) {
            return "0";
        }
        uint256 numDigits;
        uint256 tempNum = v;
        while (tempNum != 0) {
            numDigits++;
            tempNum /= 10;
        }
        bytes memory digitBytes = new bytes(numDigits);
        while (v != 0) {
            numDigits -= 1;
            digitBytes[numDigits] = bytes1(uint8(48 + uint256(v % 10)));
            v /= 10;
        }
        return string(digitBytes);
    }
}
