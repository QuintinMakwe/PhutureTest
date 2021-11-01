pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TKNToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("PHUTURE", "TKN") {
        _mint(msg.sender, initialSupply);
    }
}
