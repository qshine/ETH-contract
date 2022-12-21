// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MyToken {
    string public name = "First ERC20 Token";
    uint8 public decimals = 18;     // 小数点位数
    string public symbol = "FFTT";  // 代币符号
    uint public totalSupply;  // 定义发行总量

    // 转账和授权事件
    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => uint256) public balances;                       // 余额
    mapping (address => mapping (address => uint256)) public allowed;   // 授权及额度

    // 构造函数
    constructor() {
        totalSupply = 100;  // 初始化发行总量
        balances[msg.sender] = totalSupply; // 更新合约创建者的余额
    }

    // 查询指定地址余额
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // 授权额度申请
    function approve(address _spender, uint256 _value) public returns (bool success){
        require(balances[msg.sender] >= _value);
        // 授权某人多少额度
        allowed[msg.sender][_spender] = _value;
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 转账函数
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权人转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        allowed[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}