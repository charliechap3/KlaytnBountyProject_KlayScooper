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
     * @dev Stores the Klay threshold.
    */

    uint256 private constant MIN_KLAY_AMOUNT = 1;

    /**
     * @dev Stores the KIP7 Interface Id.
    */

    bytes4 private constant interfaceId = 0x01ffc9a7;

    /**
     * @dev wrapped Klay address;
    */

    KIP7 public immutable WKLAY;

    /**
     * @dev mapping of WKLAY to swapper's balance;
    */

    mapping (address => mapping (address => uint)) private swapperKlayBalance;

    address[] addresses;

    uint256[] amounts;
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

    error TokensScooper__InsufficientTokensAmount();

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

    constructor(address _RouterAddress, address wklay) {
        i_RouterAddress = _RouterAddress;
        i_owner = msg.sender;
        WKLAY = KIP7(wklay);
    }

    /// view and pure functions

    function versionCheck() public pure returns (string memory) {
        return i_version;
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

            (bool ok) = _checkIfKIP7Token(tokenAddresses[i]);
            if(!ok) revert TokensScooper__UnsupportedToken();

            KIP7 token = KIP7(tokenAddresses[i]);

            uint256 tokenAmount = token.balanceOf(msg.sender);

            if(tokenAmount < 0) revert TokensScooper__InsufficientTokensAmount();

            tokenToAddress[tokenAmount] = tokenAddresses[i]

            amounts.push(tokenAmount);
        }

        uint256[] memory amountsToken = amounts;
        address[] memory path = new address[](2);

        for(uint256 j = 0; j < amountsToken.length; j ++) {
            address token0 = tokenToAddress[amountsToken[j]];

            path[0] = token0; // tokenToAddress[]
            path[1] = address(WKLAY);

            uint256[] memory amounts = IKlaySwapRouter(i_RouterAddress).getAmountsOut(amountsToken[j], path);
            if(amounts[amounts.length - 1] >= MIN_KLAY_AMOUNT) revert TokensScooper__InsufficientAmount();
        }

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