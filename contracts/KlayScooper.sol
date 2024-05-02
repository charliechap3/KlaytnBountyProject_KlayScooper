// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./interfaces/IKlaySwapRouter.sol";
import "./Lib/TransferHelper.sol";
import {KIP7} from "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";

contract KlayScooper {

    address private immutable i_owner;
    address private immutable i_RouterAddress;
    uint256 private constant MIN_KLAY_AMOUNT = 0.1 Klay;


    constructor(address _RouterAddress) {
        i_RouterAddress = _RouterAddress;
        i_owner = msg.sender;
    }

    function swapTokensForKlay(address[] calldata tokenAddresses) external {
        require(tokenAddresses.length > 0, "No tokens");

        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i]
            KIP7 token = KIP7(tokenAddress); 

            uint256 tokenAmount = token.balanceOf(msg.sender);
            require(tokenAmount > 0);
            address memory path = new address[](2);
            path[0] = tokenAddress;
            path[1] = IKlaySwapRouter(i_RouterAddress).WKLAY();

            uint256[] memory amounts = IKlaySwapRouter(i_RouterAddress).getAmountsOut(tokenAmount, path);
            require(amounts[1] >= MIN_KLAY_AMOUNT, "Insufficient Klaytn value");

            TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), tokenAmount);
            TransferHelper.safeApprove(tokenAddress, i_RouterAddress, tokenAmount);

            IKlaySwapRouter(i_RouterAddress).swapExactTokensForKLAY(
                tokenAmount, 
                0, 
                path, 
                msg.sender, 
                block.timestamp
            );
        }
    }
}