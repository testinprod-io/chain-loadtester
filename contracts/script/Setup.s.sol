// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {Deployers} from "@v4-core/test/utils/Deployers.sol";
import {IHooks} from "@v4-core/src/interfaces/IHooks.sol";
import {Currency, CurrencyLibrary} from "@v4-core/src/types/Currency.sol";
import {PoolKey} from "@v4-core/src/types/PoolKey.sol";
import {PoolModifyLiquidityTest} from "@v4-core/src/test/PoolModifyLiquidityTest.sol";
import {IPoolManager} from "@v4-core/src/interfaces/IPoolManager.sol";

import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {SwapRouter} from "../src/SwapRouter.sol";

contract Setup is Script, Deployers {
    SwapRouter router;

    function _deployTokens(uint8 count, uint256 totalSupply) internal returns (ERC20Mock[] memory tokens) {
        tokens = new ERC20Mock[](count);
        for (uint8 i = 0; i < count; i++) {
            tokens[i] = new ERC20Mock();
            tokens[i].mint(msg.sender, totalSupply);
        }
    }

    function _deployMintAndApproveCurrency() internal returns (Currency currency) {
        ERC20Mock token = _deployTokens(1, 2 ** 255)[0];

        address[2] memory toApprove = [
            address(router),
            address(modifyLiquidityRouter)
        ];

        for (uint256 i = 0; i < toApprove.length; i++) {
            token.approve(toApprove[i], type(uint256).max);
        }

        return Currency.wrap(address(token));
    }

    function run() public {
        vm.startBroadcast();
        IHooks hooks = IHooks(address(0));
        deployFreshManager();
        router = new SwapRouter(manager);
        modifyLiquidityRouter = new PoolModifyLiquidityTest(manager);


        currency0 = _deployMintAndApproveCurrency();
        currency1 = _deployMintAndApproveCurrency();
        if (Currency.unwrap(currency0) > Currency.unwrap(currency1)) {
            (currency0, currency1) = (currency1, currency0);
        }
        (key,) = initPoolAndAddLiquidity(currency0, currency1, hooks, 3000, SQRT_PRICE_1_1, ZERO_BYTES);


        console.log(CurrencyLibrary.balanceOf(currency0, msg.sender));
        console.log(CurrencyLibrary.balanceOf(currency1, msg.sender));
        router.swap(key, -1);
        console.log(CurrencyLibrary.balanceOf(currency0, msg.sender));
        console.log(CurrencyLibrary.balanceOf(currency1, msg.sender));

        vm.stopBroadcast();

        string memory json = "";
        json = stdJson.serialize("contracts", "poolManager", address(manager));
        json = stdJson.serialize("contracts", "currency0", Currency.unwrap(currency0));
        json = stdJson.serialize("contracts", "currency1", Currency.unwrap(currency1));
        json = stdJson.serialize("contracts", "swapRouter", address(router));

        vm.writeJson({ json: json, path: "./artifacts/contracts.json" });
    }
}
