// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IPoolManager} from "@v4-core/src/interfaces/IPoolManager.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@v4-core/src/types/BalanceDelta.sol";
import {PoolKey} from "@v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@v4-core/src/types/PoolId.sol";
import {PoolTestBase} from "@v4-core/src/test/PoolTestBase.sol";
import {Currency} from "@v4-core/src/types/Currency.sol";
import {CurrencySettleTake} from "@v4-core/src/libraries/CurrencySettleTake.sol";

contract SwapRouter is PoolTestBase {
    using CurrencySettleTake for Currency;
    using PoolIdLibrary for PoolKey;

    constructor(IPoolManager _manager) PoolTestBase(_manager) {}

    struct CallbackData {
        address sender;
        PoolKey key;
        IPoolManager.SwapParams params;
    }

    function swap(
        PoolKey memory key,
        int256 amount
    ) external payable returns (BalanceDelta delta) {
        (uint160 sqrtPriceX96,,,) = manager.getSlot0(key.toId());
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true, amountSpecified: amount, sqrtPriceLimitX96: sqrtPriceX96-1
        });
        delta = abi.decode(
            manager.unlock(abi.encode(CallbackData(msg.sender, key, params))), (BalanceDelta)
        );
    }

    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        require(msg.sender == address(manager));
        CallbackData memory data = abi.decode(rawData, (CallbackData));
        BalanceDelta delta = manager.swap(data.key, data.params, new bytes(0));
        (,, int256 deltaAfter0) = _fetchBalances(data.key.currency0, data.sender, address(this));
        (,, int256 deltaAfter1) = _fetchBalances(data.key.currency1, data.sender, address(this));
        if (deltaAfter0 < 0) {
            data.key.currency0.settle(manager, data.sender, uint256(-deltaAfter0), false);
        }
        if (deltaAfter1 < 0) {
            data.key.currency1.settle(manager, data.sender, uint256(-deltaAfter1), false);
        }
        if (deltaAfter0 > 0) {
            data.key.currency0.take(manager, data.sender, uint256(deltaAfter0), false);
        }
        if (deltaAfter1 > 0) {
            data.key.currency1.take(manager, data.sender, uint256(deltaAfter1), false);
        }
        return abi.encode(delta);
    }
}
