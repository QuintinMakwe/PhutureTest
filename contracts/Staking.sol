//SPDX-License-Identifier: Unlicense
import "./interfaces/IStakingContract.sol";
import "./interfaces/IERC20.sol";

import "./libraries/SafeERC20.sol";
import "./libraries/SafeMath.sol";

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Staking is IStakingContract {
    using SafeERC20 for IERC20;

    address _distributionContractAddress;

    uint256 _totalStakedAmount = 0;
    uint256 _totalAccruedReward = 0;

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
     * Inner Key  = stake stake struct id
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

    function stake(
        address account,
        uint256 amount,
        address stakingTokenAddress
    ) external override returns (uint256) {
        //check that staking token address is the right token address
        //check that amount is a non zero amount
        require(amount > 0, "Can only stake non zero amounts");
        //check allowance token contract to spend staker's tokens
        IERC20 token = IERC20(stakingTokenAddress);

        uint256 allowedAmount = token.allowance(account, address(this));

        require(
            allowedAmount > amount,
            "Provide appropriate allowance for staking"
        );

        //transfer amount from staker to contract
        token.safeTransferFrom(acount, address(this), amount);
        //update the total amount
        _totalStakedAmount += amount;
        //create stake struct
        Stake memory stakeObject = Stake(
            _stakes.length.add(1),
            amount,
            account
        );
        //add to array
        _stakes.push(stakeObject);
        //create index
        Index memory stakeIndex = Index(stakeObject.Id.sub(1), true, true);

        _stakeIndexes[account][stakeObject.Id] = stakeIndex;
        //create aggregate stake
        _aggregateStakeAmount[account] += amount;
        //create individual stakes
        _individualStakes[account][stakeObject.Id] = amount;
        //take snapshot
        _rewardSnapshot[account][stakeObject.Id] = _totalAccruedReward;
        //return index of stake
        return stakeObject.Id;
    }

    function distributeReward(uint256 amount) external override {
        require(
            _totalStakedAmount > 0,
            "Can only distribute reward when there are staked token stake"
        );

        _totalAccruedReward += amount / _totalStakedAmount;
    }

    function viewUnstakableToken(address recipient)
        external
        view
        override
        returns (uint256)
    {
        return _aggregateStakeAmount(recipient);
    }
}
