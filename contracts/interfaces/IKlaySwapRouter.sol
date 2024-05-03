// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

interface IKlaySwapRouter {
    function swapExactTokensForKLAY(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function WKLAY() external view returns (address);
}