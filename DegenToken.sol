// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract DegenToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    struct ItemRedeemed {
        string itemName;
        uint256 quantity;
        uint256 tokensRedeemed;
    }

    mapping(address => ItemRedeemed[]) private ItemRedeemeds;

    address public owner;

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Redeem(address indexed from, string itemName);

    string[] public items; 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        name = "Degen Token"; 
        symbol = "DGN";
        decimals = 18;
        totalSupply = 0;
        owner = msg.sender;

        items.push("Item 1");
        items.push("Item 2");
        items.push("Item 3");
        items.push("Item 4");
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function redeem() external returns (string memory) {
        require(balances[msg.sender] > 0, "Insufficient balance to redeem.");
        require(items.length > 0, "No items available for redemption.");

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % items.length;
        string memory chosenItem = items[randomIndex];

        uint256 redemptionAmount = 100; 
        require(balances[msg.sender] >= redemptionAmount, "Insufficient balance to redeem the item.");
        balances[msg.sender] -= redemptionAmount;

        // Track redeemed item
        ItemRedeemeds[msg.sender].push(ItemRedeemed({
            itemName: chosenItem,
            quantity: 1,
            tokensRedeemed: redemptionAmount
        }));

        emit Redeem(msg.sender, chosenItem);

        return chosenItem;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        totalSupply += amount;
        balances[to] += amount;

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external {
        require(amount <= balances[msg.sender], "Insufficient balance.");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance.");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(amount <= balances[sender], "Insufficient balance.");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance.");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function printRedeemedTokensList(address account) public view returns (string memory) { 
        require(account != address(0), "Query for zero address not possible");
        ItemRedeemed[] memory itemsRedeemed = ItemRedeemeds[account];
        require(itemsRedeemed.length > 0, "No redeemed tokens found");

        string memory redemptionDetails = "";
        for (uint256 index = 0; index < itemsRedeemed.length; index++) {
            redemptionDetails = string(abi.encodePacked(redemptionDetails,
            "Redemption Item ", uintToString(index + 1), ": ",
            "Quantity Redeemed: ", uintToString(itemsRedeemed[index].quantity),
            " Tokens Redeemed: ", uintToString(itemsRedeemed[index].tokensRedeemed), "\n"));
        }
        return redemptionDetails;
    }

    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
