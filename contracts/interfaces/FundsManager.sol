// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@poolzfinance/poolz-helper-v2/contracts/interfaces/IProvider.sol";
import "@poolzfinance/lockdeal-nft/contracts/SimpleProviders/LockProvider/LockDealState.sol";

abstract contract FundsManager is LockDealState, IProvider {
    function handleWithdraw(uint256 poolId, uint256 tokenAmount) external virtual {}
    function handleRefund(uint256 poolId, address user, uint256 tokenAmount) external virtual {}
    function isPoolFinished(uint256 poolId) external view virtual returns (bool) {}
}