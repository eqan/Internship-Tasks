// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

// ERC20 Token Implementation: Fungilble Contract

contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 
 
//ERC Token Standard #20 Interface
abstract contract  ERC20Interface {
    // TotalSupply: provides information about the total token supply
    function  TotalSupply() public virtual  returns (uint);
    // BalanceOf: provides account balance of the owner's account
    function BalanceOf(address user) public virtual returns (uint balance);
    // Allowance: returns a set number of tokens from a spender to the owner
    function Allowance(address user, address spender) public virtual returns (uint remaining);
    // Transfer: executes transfers of a specified number of tokens to a specified address
    function Transfer(address to, uint tokens) public virtual returns (bool success);
    // Approve: allow a spender to withdraw a set number of tokens from a specified account
    function Approve(address spender, uint tokens) public virtual returns (bool success);
    // TransferFrom: executes transfers of a specified number of tokens from a specified address
    function TransferFrom(address from, address to, uint tokens) public virtual returns (bool success);
    // approval: activated whenever approval is required.
    event approval(address indexed user, address indexed spender, uint tokens);
    // transfer: that takes place whenever tokens are transferred
    event transfer(address indexed from, address indexed to, uint tokens);
}
 
  
//Actual token contract
contract BTCToken is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint256 public decimals;
    uint public _totalSupply;
    address public owner;
 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed; // 2d Dictionary dict[Address][Address] => Integer
 
    constructor(string memory symbol_,string memory name_, uint256 decimals_, uint totalSupply_) 
    {
        owner = msg.sender;
        symbol = symbol_;
        name = name_;
        decimals = decimals_;
        _totalSupply = totalSupply_ ** decimals; // The actual total supply will be this multiply by decimals
        balances[msg.sender] = _totalSupply;
    }

    function TotalSupply() public view override returns (uint) {
        return _totalSupply;
    }
 
    function BalanceOf(address user) public view override returns (uint balance) {
        return balances[user];
    }

    function Transfer(address to, uint tokens) public override returns (bool success) {
        return _transfer(to, tokens);
    }

    function Approve(address spender, uint tokens) public override returns (bool success) {
        return _approve(spender, tokens);
    }

    function TransferFrom(address from, address to, uint tokens) public override returns (bool success) {
        return _transferFrom(from, to, tokens);
    }

    function Allowance(address user, address spender) public view override returns (uint remaining) {
        return _allowance(user, spender);
    }

    function Mint(address user, uint256 amount) public virtual returns(bool success) {
        require(user == msg.sender,"user must be msg.sender");
        return _mint(user, amount);
    }
   
    function Burn(address user, uint256 amount) public virtual returns(bool success) {
        return _burn(user, amount);
    }
 
    // Transfer 'To' a specified address
    function _transfer(address to, uint tokens) private returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit transfer(msg.sender, to, tokens);
        return true;
    }
 
    function _approve(address spender, uint tokens) private returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit approval(msg.sender, spender, tokens);
        return true;
    }

    // Transfer 'From' a specified address
    function _transferFrom(address from, address to, uint tokens) private returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit transfer(from, to, tokens);
        return true;
    }

     function _mint(uint256 amount) checkLimit(msg.sender, amount) private  onlyOwner() returns(bool success) {
        address user = msg.sender;
        _totalSupply = safeAdd(_totalSupply, amount);
        balances[user] = safeAdd(balances[user], amount);
        emit transfer(address(0), user, amount);
        return true;
    }

    function _burn(uint256 amount) private  onlyOwner() returns(bool success)  {
        address user = msg.sender;
        _totalSupply = safeSub(_totalSupply, amount);
        balances[user] = safeSub(balances[user], amount);
        emit transfer(user, address(0), amount);
        return true;
    }

    function _allowance(address user, address spender) view private returns (uint remaining) {
        return allowed[user][spender];
    }
}