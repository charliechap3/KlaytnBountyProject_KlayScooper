// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./interfaces/IKlaySwapRouter.sol";
import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";

contract TokensScooper {

    /**
     * @dev Stores the version of the contract
     * and fulfills the same requirements for version tracking.
    */

    string private constant i_version = "1.0.0";

    /**
     * @dev Stores the deployer's address.
    */

    address private immutable i_owner;

    /**
     * @dev Stores the address of the KlaySwapV2 contract.
    */

    address private immutable i_RouterAddress;

    /**
     * @dev Stores the KIP7 Interface Id.
    */

    bytes4 private constant interfaceId = 0x01ffc9a7;

    /**
     * @dev wrapped Klay address;
    */

    KIP7 public immutable WKLAY;

    struct SwapData {
        address[] tokenaddresses;
        address user;
        uint256 timeStamp;
        uint256 ethAmount;
    }

    mapping (address => SwapData[]) private swapTxHistory;

    /**
     * @notice Emitted whenever tokens are minted for an account.
     *
     * @param swapper Address of the swapper.
     * @param amount  Amount of tokens minted.
    */

    event TokensSwapped(address indexed swapper, uint indexed balance, uint indexed amount);

    /**
     * @dev Reverts if the zero tokens are sent.
    */

    error TokensScooper__ZeroLengthArray();

    /**
     * @dev Reverts if the tokens to swap amount is less than zero.
    */

    error TokensScooper__InsufficientTokensAmount();

    /**
     * @dev Reverts if the token to swap is not KIP7 compatible.
    */

    error TokensScooper__UnsupportedToken();

    /**
     * @dev Reverts if the token to swap is WKLAY
    */

    error TokensScooper__WKLAYUnsupported();

    /**
     * @notice constructor
     * @dev initializers the KlaySwap V2 router and deployer
    */

    constructor(address _RouterAddress, address wklay) {
        i_RouterAddress = _RouterAddress;
        WKLAY = KIP7(wklay);
        i_owner = msg.sender;
    }

    /// view and pure functions

    function versionCheck() public pure returns (string memory) {
        return i_version;
    }

    function owner() public view returns (address) {
        return i_owner;
    }

    function router() public view returns (address) {
        return i_RouterAddress;
    }

    function getSwapHistory() external view returns (SwapData[] memory) {
        return swapTxHistory[msg.sender];
    }

    // internal functions
    /**
     * @notice KIP7 Token Interface Support.
     *
     * @param tokenAddress token address to check.
     *
     * @return Whether or not the token interface is supported by this contract.
    */

    function _checkIfKIP7Token(address tokenAddress) internal view returns (bool) {
        KIP7 token = KIP7(tokenAddress);
        return token.supportsInterface(interfaceId);
    }

    /**
     * @notice Low-level Zero Address Check.
     *
     * @param _address token address to check.
    */

    function _zeroAddressCheck(address _address) internal pure {
      assembly {
        if iszero(_address) {
          revert(0,0)
        }
      } 
    }

    /// external functions
    /**
     * @notice Scoops KIP7 Tokens for Klay.
     *
     * @param tokenAddresses token addresses to scoop.
     *
    */
    
    function swapTokensForKlay(address[] calldata tokenAddresses) external {
        if(tokenAddresses.length <= 0) revert TokensScooper__ZeroLengthArray();
        _zeroAddressCheck(address(msg.sender));

        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i];

            if(tokenAddress == address(WKLAY)) revert TokensScooper__WKLAYUnsupported();

           _zeroAddressCheck(tokenAddress);

            (bool ok) = _checkIfKIP7Token(tokenAddress);
            if(!ok) revert TokensScooper__UnsupportedToken();

            KIP7 token = KIP7(tokenAddress);

            uint256 tokenBalance = token.balanceOf(msg.sender);
            if(tokenBalance <= 0) revert TokensScooper__InsufficientTokensAmount();

            address[] memory path = new address[](2);
            path[0] = tokenAddress;
            path[1] = address(WKLAY);

            (uint[] memory amounts) = IKlaySwapRouter(i_RouterAddress).swapExactTokensForKLAY(
                tokenBalance, 
                1, 
                path, 
                msg.sender, 
                block.timestamp
            );

            swapTxHistory[msg.sender].push(SwapData({
                tokenaddresses: tokenAddresses,
                user: msg.sender,
                timeStamp: block.timestamp,
                ethAmount: amounts[i]
            }));

            emit TokensSwapped(msg.sender, tokenBalance, amounts[1]);

        }
    }
}