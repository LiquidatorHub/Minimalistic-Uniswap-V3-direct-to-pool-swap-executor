// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;


interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

interface ICLPool {
    function swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data) external returns (int256 amount0, int256 amount1);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function slot0() external view returns (uint160 sqrtPriceX96, int24, uint16, uint16, uint16, bool);
}

library SafeTransferLib {
    function safeTransfer(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TF");
    }
}

contract SwapDirectToPoolV3 {
    // Here’s a concise one-liner to define two owners in Solidity using a single line
    address[2] internal OWNERS = [0x5b5C8961354F8C577d1C7A5D0303b2ced7436275,0x666666A66658d97Ed8963c979fd260A44c113298];
    mapping(address => bool) internal activePools;

    function swapdirecttopoolv3(address pool, bool zeroForOne) external {
        require(msg.sender == OWNERS[0] || msg.sender == OWNERS[1], "dolboeb");
        activePools[pool] = true;
        (uint160 sqrtPriceX96, , , , , ) = ICLPool(pool).slot0();
        address tokenIn = zeroForOne ? ICLPool(pool).token0() : ICLPool(pool).token1();
        uint256 amountIn = IERC20(tokenIn).balanceOf(address(this));
        uint160 sqrtLimit = uint160((sqrtPriceX96 * (zeroForOne ? 505 : 1495)) / 1000);

        ICLPool(pool).swap(address(this), zeroForOne, int256(amountIn), sqrtLimit, abi.encode(pool));
        activePools[pool] = false;
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        address pool = abi.decode(data, (address));
        require(activePools[pool], "unauthorized callback");
        
        if (amount0Delta > 0) {
            SafeTransferLib.safeTransfer(ICLPool(pool).token0(), pool, uint256(amount0Delta));
        } else if (amount1Delta > 0) {
            SafeTransferLib.safeTransfer(ICLPool(pool).token1(), pool, uint256(amount1Delta));
        }
    }
}
