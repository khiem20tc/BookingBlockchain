pragma solidity ^0.5.4;

import {Ownable} from "./Ownable.sol";
import {ERC20} from "./TokenERC20.sol";

contract MintableToken is Ownable, ERC20 {
    constructor(string memory Name, string memory Symbol) public ERC20(Name, Symbol) { }

    //function mint(address account, uint256 amount) public onlyOwner {
    //    _mint(account, amount);
    //}
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}