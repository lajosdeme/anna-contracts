// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./SimpleAccount.sol";

contract AccountFactory {
    address public masterAccount;
    IEntryPoint public entryPoint;

    event AccountCreated(address indexed creator, address indexed account);

    constructor(address _masterAccount, IEntryPoint _entryPoint) {
        masterAccount = _masterAccount;
        entryPoint = _entryPoint;
    }

    function createAccount() external {
        SimpleAccount _acc = SimpleAccount(payable(Clones.clone(masterAccount)));
        _acc.initialize(msg.sender, entryPoint);

        emit AccountCreated(msg.sender, address(_acc));
    }
}