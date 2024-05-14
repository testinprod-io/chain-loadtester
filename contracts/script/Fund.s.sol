// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract Fund is Script {
    address internal poolManager;
    address internal swapRouter;

    function mintAndApprove(ERC20Mock currency) internal {
        uint256 amount = 10000 ether;
        currency.mint(msg.sender, amount);
        currency.approve(poolManager, amount);
        currency.approve(swapRouter, amount);
    }

    function run() public {
        string memory json = vm.readFile("./artifacts/contracts.json");
        address currency0 = stdJson.readAddress(json, "$.currency0");
        address currency1 = stdJson.readAddress(json, "$.currency1");
        poolManager = stdJson.readAddress(json, "$.poolManager");
        swapRouter = stdJson.readAddress(json, "$.swapRouter");
        vm.startBroadcast();
        mintAndApprove(ERC20Mock(currency0));
        mintAndApprove(ERC20Mock(currency1));
        vm.stopBroadcast();
    }
}
