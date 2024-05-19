// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./interfaces/IKlaySwapRouter.sol";
import "./Lib/TransferHelper.sol";
import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";

contract TokensScooper {

    /**
     * @dev Stores the version of the contract
     * and fulfills the same requirements for version tracking.
    */

    string private constant version = "1.0.0";

    /**
     * @dev Stores the deployer's address.
    */

    address private immutable i_owner;

    /**
     * @dev Stores the address of the KlaySwapV2 contract.
    */

    address private immutable i_RouterAddress;

    /**
     * @dev Stores the Klay threshold.
    */

    uint256 private constant MIN_KLAY_AMOUNT = 1;

    /**
     * @dev Stores the KIP7 Interface Id.
    */

    bytes4 private constant interfaceId = 0x01ffc9a7;

    /**
     * @dev mapping of WKLAY to swapper's balance;
    */

    mapping (address => uint) private swapperKlayBalance;

    /**
     * @notice Emitted whenever tokens are minted for an account.
     *
     * @param swapper Address of the swapper.
     * @param amount  Amount of tokens minted.
    */

    event TokensSwapped(address indexed swapper, uint indexed amount);

    /**
     * @dev Reverts if the zero tokens are sent.
    */

    error TokensScooper__ZeroLengthArray();

    /**
     * @dev Reverts if the amount gotten from Klayswap is less than the threshold.
    */

    error TokensScooper__InsufficientAmount();

    /**
     * @dev Reverts if the tokens to swap amount is less than zero.
    */

    error TokensScooper__InsufficientTokens();

    /**
     * @dev Reverts if the allowance is less than the amount of tokens to swap.
    */

    error TokensScooper__InsufficientAllowance();

    /**
     * @dev Reverts if the token to swap is not KIP7 compatible.
    */

    error TokensScooper__UnsupportedToken();

    /**
     * @notice constructor
     * @dev initializers the KlaySwap V2 router and deployer
    */

    constructor(address _RouterAddress) {
        i_RouterAddress = _RouterAddress;
        i_owner = msg.sender;
    }

    /// view and pure functions

    function swapperBalance(address wklay) public view returns (uint) {
        return swapperKlayBalance[wklay];
    }

    function versionCheck() public pure returns (string memory) {
        return version;
    }

    function klayThreshold() public pure returns (uint) {
        return MIN_KLAY_AMOUNT;
    }

    function owner() public view returns (address) {
        return i_owner;
    }

    function router() public view returns (address) {
        return i_RouterAddress;
    }
    /**
     * @notice KIP7 Token Interface Support.
     *
     * @param tokenAddress token address to check.
     *
     * @return Whether or not the token interface is supported by this contract.
    */

   /// internal functions

    function _checkIfKIP7Token(address tokenAddress) internal view returns (bool) {
        KIP7 token = KIP7(tokenAddress);
        return token.supportsInterface(interfaceId);
    }

    /**
     * @notice Scoops KIP7 Tokens for Klay.
     *
     * @param tokenAddresses token addresses to scoop.
     *
    */

    // external functions
    
    function swapTokensForKlay(address[] calldata tokenAddresses) external {
        if(tokenAddresses.length > 0) revert TokensScooper__ZeroLengthArray();

        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i];

            (bool ok) = _checkIfKIP7Token(tokenAddress);
            if(!ok) revert TokensScooper__UnsupportedToken();

            KIP7 token = KIP7(tokenAddress);

            uint256 tokenAmount = token.balanceOf(msg.sender);
            if(tokenAmount > 0) revert TokensScooper__InsufficientTokens();

            uint256 allowance = token.allowance(msg.sender, address(this));
            if(allowance <= tokenAmount) revert TokensScooper__InsufficientAllowance();

            address[] memory path = new address[](2);
            path[0] = tokenAddress;
            path[1] = IKlaySwapRouter(i_RouterAddress).WKLAY();

            uint256[] memory amounts = IKlaySwapRouter(i_RouterAddress).getAmountsOut(tokenAmount, path);
            if(amounts[amounts.length - 1] >= MIN_KLAY_AMOUNT) revert TokensScooper__InsufficientAmount();

            TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), tokenAmount);
            TransferHelper.safeApprove(tokenAddress, i_RouterAddress, tokenAmount);

            IKlaySwapRouter(i_RouterAddress).swapExactTokensForKLAY(
                tokenAmount, 
                0, 
                path, 
                msg.sender, 
                block.timestamp
            );

            emit TokensSwapped(msg.sender, tokenAmount);
        }
    }
}