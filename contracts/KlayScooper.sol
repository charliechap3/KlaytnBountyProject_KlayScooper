// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./interfaces/IKlaySwapRouter.sol";
import "./Lib/TransferHelper.sol";
import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";

error KlayScooper__ZeroLengthArray();
error KlayScooper__InsufficientAmount();
error KlayScooper__InsufficientTokens();
error KlayScooper__InsufficientAllowance();
error KlayScooper__UnsupportedToken();

contract KlayScooper {

    address private immutable i_owner;
    address private immutable i_RouterAddress;
    uint256 private constant MIN_KLAY_AMOUNT = 0.1 Klay;
    bytes4 private constant interfaceId = 0x01ffc9a7;
    string private constant version = "1.0.0";


    constructor(address _RouterAddress) {
        i_RouterAddress = _RouterAddress;
        i_owner = msg.sender;
    }

    function _checkIfKIP7Token(address tokenAddress) internal view returns (bool) {
        KIP7 token = KIP7(tokenAddress);
        (bool true) = token.supportsInterface(interfaceId);
    }

    function swapTokensForKlay(address[] calldata tokenAddresses) external {
        if(tokenAddresses.length > 0) revert KlayScooper__ZeroLengthArray();

        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i];

            (bool ok) = _checkIfKIP7Token(tokenAddress);
            if(!ok) revert KlayScooper__UnsupportedToken;

            KIP7 token = KIP7(tokenAddress);

            uint256 tokenAmount = token.balanceOf(msg.sender);
            if(tokenAmount > 0) revert KlayScooper__InsufficientTokens();
            uint256 allowance = token.allowance(msg.sender, address(this));
            if(allowance <= tokenAmount) revert KlayScooper__InsufficientAllowance();

            address memory path = new address[](2);
            path[0] = tokenAddress;
            path[1] = IKlaySwapRouter(i_RouterAddress).WKLAY();

            uint256[] memory amounts = IKlaySwapRouter(i_RouterAddress).getAmountsOut(tokenAmount, path);
            if(amounts[amounts.length - 1] >= MIN_KLAY_AMOUNT) revert KlayScooper__InsufficientAmount();

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