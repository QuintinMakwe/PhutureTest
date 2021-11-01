// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStakingContract {
    function stake(address account, uint256 amount) external returns (uint256);

    function unstake(address account, uint256 stakeId)
        external
        returns (uint256);

    function viewUnstakableToken(address recipient)
        external
        view
        returns (uint256);

    function distributeReward(uint256 amount) external;
}
