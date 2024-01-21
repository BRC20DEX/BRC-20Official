// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function mint(address to, uint256 value) external returns (bool);

    function burn(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract ERC20Locker {
    IERC20 public token;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
    uint256 public constant LOCKED_SUPPLY = 1_000_000_000 * (10**18); // Locked supply is 600 million tokens
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    event TokensLocked(uint256 amount);
    event TokensUnlocked(uint256 amount);
    // Lock tokens in the locker bridge (onlyOwner)
    function lockTokens(uint256 amount) external {
        require(amount <= token.balanceOf(address(this)) - LOCKED_SUPPLY, "Cannot lock more than available supply");
        token.transferFrom(msg.sender,address(this), amount);
        emit TokensLocked(amount);
    }

    // Unlock tokens from the locker bridge (onlyOwner)
    function unlockTokens(uint256 amount,address to) external onlyOwner {
        require(to != address(0), "Locker address not set");
        require(amount <= LOCKED_SUPPLY, "Cannot unlock more than locked supply");
        token.transfer(to, amount);
        emit TokensUnlocked(amount);
    }
    
     function changeToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function changeOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
}
