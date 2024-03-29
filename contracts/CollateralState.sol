// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@poolzfinance/poolz-helper-v2/contracts/interfaces/IInnerWithdraw.sol";
import "@poolzfinance/lockdeal-nft/contracts/SimpleProviders/LockProvider/LockDealState.sol";
import "@poolzfinance/lockdeal-nft/contracts/SimpleProviders/Provider/ProviderModifiers.sol";
import "./interfaces/FundsManager.sol";

abstract contract CollateralState is IInnerWithdraw, FundsManager, IERC165, ProviderModifiers {
    mapping(uint256 => uint256) public poolIdToRateToWei;

    function getParams(uint256 poolId) public view override returns (uint256[] memory params) {
        (, , uint256 mainCoinHolderId) = getInnerIds(poolId);
        params = new uint256[](3);
        params[0] = provider.getParams(mainCoinHolderId)[0];
        params[1] = poolIdToTime[poolId];
        params[2] = poolIdToRateToWei[poolId];
    }

    function getInnerIdsArray(uint256 poolId) public view override returns (uint256[] memory ids) {
        if (isPoolFinished(poolId)) {
            return getSubProvidersPoolIds(poolId);
        } else {
            ids = new uint256[](2);
            (ids[0], ids[1], ) = getInnerIds(poolId);
        }
    }

    function currentParamsTargetLength() public pure override(IProvider, ProviderState) returns (uint256) {
        return 3;
    }

    function getInnerIds(
        uint256 poolId
    ) internal pure returns (uint256 mainCoinCollectorId, uint256 tokenCollectorId, uint256 mainCoinHolderId) {
        mainCoinCollectorId = poolId + 1;
        tokenCollectorId = poolId + 2;
        mainCoinHolderId = poolId + 3;
    }

    function getWithdrawableAmount(uint256 poolId) public view override returns (uint256 withdrawalAmount) {
        if (lockDealNFT.poolIdToProvider(poolId) == this) {
            (uint256 mainCoinCollectorId, , uint256 mainCoinHolderId) = getInnerIds(poolId);
            withdrawalAmount = lockDealNFT.getWithdrawableAmount(mainCoinCollectorId);
            if (isPoolFinished(poolId)) {
                withdrawalAmount += lockDealNFT.getWithdrawableAmount(mainCoinHolderId);
            }
        }
    }

    ///@dev Collateral can't be Refundble or Bundleble
    /// Override basic provider supportsInterface
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IInnerWithdraw).interfaceId;
    }

    function getSubProvidersPoolIds(uint256 poolId) public view virtual override(IProvider, ProviderState) returns (uint256[] memory poolIds) {
        if (lockDealNFT.poolIdToProvider(poolId) == this) {
            poolIds = new uint256[](3);
            (poolIds[0], poolIds[1], poolIds[2]) = getInnerIds(poolId);
        }
    }

    function isPoolFinished(uint256 poolId) public view override returns (bool) {
        return poolIdToTime[poolId] <= block.timestamp;
    }
}