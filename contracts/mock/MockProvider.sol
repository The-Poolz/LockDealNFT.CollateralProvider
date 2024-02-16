// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@poolzfinance/poolz-helper-v2/contracts/interfaces/ISimpleProvider.sol";
import "@poolzfinance/poolz-helper-v2/contracts/interfaces/ILockDealNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev MockProvider is a contract for testing purposes.
contract MockProvider {
    IProvider public _provider;
    ILockDealNFT public lockDealNFT;

    constructor(ILockDealNFT _lockDealNFT, address __provider) {
        lockDealNFT = _lockDealNFT;
        _provider = IProvider(__provider);
    }

    function createNewPool(
        address[] calldata addresses,
        uint256[] memory params,
        bytes calldata signature
    ) public returns (uint256 poolId) {
        poolId = lockDealNFT.safeMintAndTransfer(
            addresses[0],
            addresses[1],
            addresses[0],
            params[0],
            _provider,
            signature
        );
        _provider.registerPool(poolId, params);
    }

    function handleWithdraw(uint256 poolId, uint256 tokenAmount) external {
        (bool sucess, ) = address(_provider).call(
            abi.encodeWithSignature(
                "handleWithdraw(uint256,uint256)",
                poolId,
                tokenAmount
            )
        );
        require(sucess, "MockProvider: handleWithdraw failed");
    }

    function handleRefund(
        uint256 poolId,
        address user,
        uint256 tokenAmount
    ) external {
        (bool sucess, ) = address(_provider).call(
            abi.encodeWithSignature(
                "handleRefund(uint256,address,uint256)",
                poolId,
                user,
                tokenAmount
            )
        );
        require(sucess, "MockProvider: handleRefund failed");
    }
}
