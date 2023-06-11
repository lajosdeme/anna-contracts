// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BasePaymaster.sol";
import "./interfaces/UserOperation.sol";

// register users who paid the subscription fee
// if the user is in the list, approve the tx
contract Paymaster is Ownable, BasePaymaster {
    uint256 public constant duration = 2678400;
    uint256 public constant subscriptionFee = 20000000; // 20USDC
    uint256 constant public COST_OF_POST = 35000;
    ERC20 usdc;

    mapping(address => uint256) subscribers; // mapping from user to subscription start time

    constructor(address _usdc, IEntryPoint _entryPoint) BasePaymaster(_entryPoint) {
        usdc = ERC20(_usdc);
    }

    function subscribe() external {
        usdc.transferFrom(msg.sender, address(this), subscriptionFee);
        subscribers[msg.sender] = block.timestamp;
    }

    function isSubscribed(address _user) public view returns (bool) {
        return subscribers[_user] + duration > block.timestamp;
    }

    function withdraw() external onlyOwner {
        uint256 balance = usdc.balanceOf(address(this));
        usdc.transfer(owner(), balance);
    }

    function _validatePaymasterUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 maxCost)
    internal view override returns (bytes memory context, uint256 validationData) {
        (userOpHash);
        // verificationGasLimit is dual-purposed, as gas limit for postOp. make sure it is high enough
        require(userOp.verificationGasLimit > COST_OF_POST, "Paymaster: gas too low for postOp");

        bytes calldata paymasterAndData = userOp.paymasterAndData;
        require(paymasterAndData.length == 20+20, "DepositPaymaster: paymasterAndData must specify token");
        IERC20 token = IERC20(address(bytes20(paymasterAndData[20:])));
        address account = UserOperationLib.getSender(userOp);
        uint256 gasPriceUserOp = UserOperationLib.gasPrice(userOp);

        bool _isSubscribed = isSubscribed(account);
        require(_isSubscribed, "Paymaster: Call from non-subscriber");

        return (abi.encode(account, token, gasPriceUserOp, maxCost),0);
    }

    function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal override {
        
    }
}