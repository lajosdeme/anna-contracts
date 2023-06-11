// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ERC20Initializable.sol";

contract ERC20Factory {

    address public masterToken;

    event TokenDeployed(address indexed creator, address indexed token);

    constructor(address _masterToken) {
        masterToken = _masterToken;
    }

    function deployToken(string calldata name, string calldata symbol) external returns (address) {
        ERC20Initializable _token = ERC20Initializable(Clones.clone(masterToken));
        _token.initialize(msg.sender, name, symbol);
        emit TokenDeployed(msg.sender, address(_token));

        return address(_token);
    }
}