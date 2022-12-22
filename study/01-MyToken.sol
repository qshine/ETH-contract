// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract MyToken is IERC20, IERC20Metadata{
    string _name = "First ERC20 Token";
    uint8 _decimals = 18;     // 小数点位数
    string _symbol = "FFTT";  // 代币符号
    uint256 _totalSupply;  // 定义发行总量
    address _owner;

    mapping (address => uint256) public _balances;                       // 余额
    mapping (address => mapping (address => uint256)) public _allowed;   // 授权及额度
    

    // 构造函数
    constructor() {
        _owner = msg.sender;
        _totalSupply = 10000;  // 初始化发行总量
        _balances[msg.sender] = _totalSupply; // 更新合约创建者的余额
    }

    modifier onlyOwner(){
        require(_owner == msg.sender, "ERROR: only owner can access this function");
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // mint 铸造代币 - 给指定地址发放代币
    function mint(address account, uint256 _value) public onlyOwner {
        require(account != address(0), "ERROR: address 0");
        _totalSupply += _value;
        _balances[account] += _value;

        emit Transfer(address(0), account, _value);
    }

    // burn 销毁代币
    function burn(address account, uint256 value) public onlyOwner {
        require(account != address(0), "ERROR: address 0");
        require(_balances[account] >= value, "ERROR: no more token to burn");

        _totalSupply -= value;
        _balances[account] -= value;

        emit Transfer(account, address(0), value);
    }

    // 查询指定地址余额
    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    // 授权额度申请
    function approve(address _spender, uint256 _value) public returns (bool success){
        // 授权某人多少额度
        _allowed[msg.sender][_spender] = _value;
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 转账函数
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(_balances[msg.sender] >= _value, "No more token to transfer");
        require(_to != address(0), "Transfer address is 0"); 
        
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;

        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权人转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_to != address(0), "Transfer address is 0"); 
        require(_balances[_from] >= _value, "from balance must < _value");
        require(_allowed[_from][msg.sender] >= _value, "app value < _value");

        _allowed[_from][msg.sender] -= _value;
        _balances[_from] -= _value;
        _balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // 查询owner授权给spender的额度
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowed[_owner][_spender];
    }
}