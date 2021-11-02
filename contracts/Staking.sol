//SPDX-License-Identifier: Unlicense
import "./interfaces/IStakingContract.sol";
import "./interfaces/IERC20.sol";

import "./libraries/SafeERC20.sol";
import "./libraries/SafeMath.sol";

pragma solidity ^0.8.0;

contract Staking is IStakingContract {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event TokenStaked(
        uint256 stakeId,
        address account,
        uint256 amount,
        uint256 aggregateStakeAmount,
        Index stakeIndex,
        uint256 rewardSnapshot
    );

    event TokenUnstaked(
        uint256 stakeId,
        address account,
        uint256 amount,
        Index stakeIndex,
        uint256 aggregateStakeAmount
    );

    event DistributionRound(uint256 totalAccruedReward);

    IERC20 _token;

    address public _distributionContractAddress;

    uint256 public _totalStakedAmount = 0;
    uint256 public _totalAccruedReward = 0;

    struct Index {
        uint256 index;
        bool exists;
    }

    struct Stake {
        uint256 Id;
        uint256 amount;
        address account;
    }

    Stake[] public _stakes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = stake struct amount
     */
    mapping(address => mapping(uint256 => uint256)) public _individualStakes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake stake struct id
     * Inner Map Value = reward snapshot value
     */
    mapping(address => mapping(uint256 => uint256)) public _rewardSnapshot;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = index struct of the stake
     */
    mapping(address => mapping(uint256 => Index)) public _stakeIndexes;

    /** @dev
     * Outer Key = user address
     * Inner Key  = stake struct id
     * Inner Map Value = index struct of the stake
     */
    mapping(address => uint256) public _aggregateStakeAmount;

    constructor(address stakingTokenAddress) {
        _distributionContractAddress = msg.sender;
        _token = IERC20(stakingTokenAddress);
    }

    function stake(address account)
        external
        payable
        override
        returns (uint256)
    {
        //check allowance token contract to spend staker's tokens
        uint256 amount = _token.allowance(account, address(this));

        //transfer amount from staker to contract
        _token.safeTransferFrom(account, address(this), amount);
        //update the total amount
        _totalStakedAmount = _totalStakedAmount.add(amount);
        //create stake struct
        Stake memory stakeObject = Stake(
            _stakes.length.add(1),
            amount,
            account
        );
        //add to array
        _stakes.push(stakeObject);
        //create index
        Index memory stakeIndex = Index(stakeObject.Id, true);

        _stakeIndexes[account][stakeObject.Id] = stakeIndex;
        //create aggregate stake
        _aggregateStakeAmount[account] = _aggregateStakeAmount[account].add(
            amount
        );
        //create individual stakes
        _individualStakes[account][stakeObject.Id] = amount;
        //take snapshot
        _rewardSnapshot[account][stakeObject.Id] = _totalAccruedReward;
        //return index of stake

        emit TokenStaked(
            stakeObject.Id,
            account,
            amount,
            _aggregateStakeAmount[account],
            stakeIndex,
            _rewardSnapshot[account][stakeObject.Id]
        );
        return stakeObject.Id;
    }

    function distributeReward(uint256 amount) external override {
        require(
            _totalStakedAmount > 0,
            "Can only distribute reward when there are staked token stake"
        );

        _totalAccruedReward = _totalAccruedReward.add(
            amount.div(_totalStakedAmount)
        );

        emit DistributionRound(_totalAccruedReward);
    }

    function viewUnstakableToken(address recipient)
        external
        view
        override
        returns (uint256)
    {
        return _aggregateStakeAmount[recipient];
    }

    function unstake(address account, uint256 stakeId)
        external
        payable
        override
        returns (uint256)
    {
        //check that stake id exist
        require(_stakeIndexes[account][stakeId].exists, "No record of stake");
        //calculate reward
        uint256 stakedAmount = _individualStakes[account][stakeId];
        uint256 currentReward = _totalAccruedReward;
        uint256 rewardAtDeposit = _rewardSnapshot[account][stakeId];
        uint256 accruedReward = stakedAmount.mul(
            currentReward.sub(rewardAtDeposit)
        );
        //send user reward
        _token.safeTransfer(account, accruedReward);
        //update total staked amount
        _totalStakedAmount = _totalStakedAmount.sub(stakedAmount);
        //update aggregate staked amount
        _aggregateStakeAmount[account] = _aggregateStakeAmount[account].sub(
            stakedAmount
        );
        //update  stake index
        _stakeIndexes[account][stakeId].exists = false;
        //return amountStaked + reward

        emit TokenUnstaked(
            stakeId,
            account,
            stakedAmount,
            _stakeIndexes[account][stakeId],
            _aggregateStakeAmount[account]
        );
        return accruedReward;
    }
}
