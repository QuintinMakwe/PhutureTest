//SPDX-License-Identifier: Unlicense
import "./interfaces/IStakingContract.sol";
import "./interfaces/IERC20.sol";

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Staking {
    address _distributionContractAddress;

    uint256 _totalStakedAmount;
    uint256 _totalAccruedReward;

    struct Index {
        uint256 index;
        bool exists;
        bool active;
    }

    struct Stake {
        uint256 Id;
        uint256 amount;
        address account;
    }

    Stake[] _stakes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = stake struct amount
     */
    mapping(address => mapping(uint256 => uint256)) _individualStakes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = reward snapshot value
     */
    mapping(address => mapping(uint256 => uint256)) _rewardSnapshot;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = index struct of the stake
     */
    mapping(address => mapping(uint256 => Index)) _stakeIndexes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = index struct of the stake
     */
    mapping(address => uint256) _aggregateStakeAmount;

    constructor() {
        _distributionContractAddress = msg.sender;
    }
}
