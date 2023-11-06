// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingSmartContract {
    string public name = "MirasCoin";
    string public symbol = "MIRAS";
    uint8 public decimals = 5;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewards;

    uint256 public stakingDuration = 30 seconds; // продолжительность стейка 30 секунд
    uint256 public annualInterestRate = 5; // 5% годовой процент

    uint256 public stakingStart;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Rewarded(address indexed user, uint256 amount);

    constructor(uint256 initialSupply) { 
        // Конструктор, высчитывает начальную сумму
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        // Модификатор, который отвечает за то, что только владелец может юзать функции
        require(msg.sender == owner, "Only the owner can perform this operation");
        _;
    }

    function stake(uint256 amount) external {

        // Функция стейка, где есть условия, такие как, сумма для стейка должна быть больше нуля, она должна быть меньше 
        // чем сам баланс и тд
        require(amount > 0, "The amount for the stake must be greater than 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");
        require(stakedBalance[msg.sender] == 0, "Do you already have an active stake");

        balanceOf[msg.sender] -= amount; // После стейка, отнимает деньги с баланса
        stakedBalance[msg.sender] = amount; // Присваивает к функции текущую сумму стейка
        stakingStart = block.timestamp; // Точная секунда стейка

        emit Staked(msg.sender, amount);
    }

    function unstake() external {
        require(stakedBalance[msg.sender] > 0, "no active stake");
        require(block.timestamp >= stakingStart + stakingDuration, "The duration of the steak is not fulfilled");

        uint256 originalAmount = stakedBalance[msg.sender];
        uint256 interest = (originalAmount * annualInterestRate * (block.timestamp - stakingStart)) / (365 days * 100);
        uint256 totalAmount = originalAmount + interest;
        // Это конкретные формулы для высчитывание дохода, зависящие конкретно от самого процентой ставки, и суммы стейка

        balanceOf[msg.sender] += totalAmount;
        stakedBalance[msg.sender] = 0;
        stakingStart = 0;

        emit Unstaked(msg.sender, originalAmount);
        emit Rewarded(msg.sender, interest);
    }

    function reward() external onlyOwner {
       
        if (stakedBalance[msg.sender] > 0) {
            uint256 rewardAmount = (stakedBalance[msg.sender] * annualInterestRate) / 100;
            // Высчитываение процента, как в школе
            rewards[msg.sender] += rewardAmount; 
            balanceOf[msg.sender] += rewardAmount; // Прибавление процента к балансу
            emit Rewarded(msg.sender, rewardAmount);
        }
    }
}