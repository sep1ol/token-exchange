// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    uint256 public orderCount;

    mapping(address => mapping(address => uint256)) public tokens;
    mapping(uint256 => _Order) public orders;
    mapping(uint256 => bool) public orderCancelled;

    event Deposit(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );
    event Withdraw(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );
    event Order(
        uint256 id,
        address user,
        address _tokenGet, uint256 _amountGet, 
        address _tokenGive, uint256 _amountGive,
        uint256 timestamp
    );
    event Cancel(
        uint256 id,
        address user,
        address _tokenGet, uint256 _amountGet, 
        address _tokenGive, uint256 _amountGive,
        uint256 timestamp
    );

    struct _Order {
        uint256 id;
        address user;
        address _tokenGet; uint256 _amountGet; 
        address _tokenGive; uint256 _amountGive;
        uint256 timestamp;
    }

    constructor (address _feeAccount, uint256 _feePercent){
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    function balanceOf(address _token, address _user) public view returns (uint256){
        return tokens[_token][_user];
    }

    //Deposit tokens
    function depositToken ( address _token, uint256 _amount ) public {
        // transfer tokens to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount), "Transfer to exchange not completed");
        // update balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount;
        // emit event
        emit Deposit(_token, msg.sender, _amount, balanceOf(_token,msg.sender));
    }

    function withdrawToken( address _token, uint256 _amount ) public {
        require(balanceOf(_token, msg.sender) >= _amount, "Insufficient balance to withdraw");
        // transfer tokens to user
        require(Token(_token).transfer(msg.sender, _amount));
        // update balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;
        // emit event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function makeOrder( 
        address _tokenGet, uint256 _amountGet, 
        address _tokenGive, uint256 _amountGive 
    ) public {
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive, "Insufficient balance for creating order");

        orderCount = orderCount + 1;
        orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);

        emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
    }

    function cancelOrder(uint256 _id) public {
        _Order storage _order = orders[_id];

        require(address(_order.user) == msg.sender);
        require(_order.id == _id, "Unexisting ID");

        orderCancelled[_id] = true;

        emit Cancel(
            _order.id, 
            msg.sender, 
            _order._tokenGet, 
            _order._amountGet, 
            _order._tokenGive, 
            _order._amountGive, 
            block.timestamp
        );
    }
}
