// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/ERC20Burnable.sol";
import "./utils/SafeMath.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract BLUS is ERC20Burnable, Operator {
    using SafeMath for uint256;

    uint256 public _minimumSupply = 0;
    uint8   public _burnRate = 1;
    mapping(address => uint8) public lockList;
    mapping(address => uint8) public feeAddress;
    mapping(address => uint256) public lockAmount;
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(0xc389fB99bF7b3414bf57e02755fd5F9A94e0E11A, 10 * 10**8 * 10**18);  //totalamount = 1billion
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        if (lockList[msg.sender] == 1) {
        require (balanceOf(msg.sender).sub(amount) >= lockAmount[msg.sender],  "amount locked");
        }
        if (feeAddress[msg.sender] == 1){
        uint256 amountafterBurn = _amountafterBurn(msg.sender, amount);
        _transfer(msg.sender, recipient, amountafterBurn);
        return true;
        }
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        if (lockList[sender] == 1) {
        require (balanceOf(sender).sub(amount) >= lockAmount[sender],  "amount locked");
        }
        if (feeAddress[sender] == 1){
        uint256 amountafterBurn = _amountafterBurn(sender, amount);
        _transfer(sender, recipient, amountafterBurn);
        return true;
        }
        _transfer(sender, recipient, amount);
        uint256 allowance = allowance(sender, msg.sender);
        _approve(sender, msg.sender, allowance.sub(amount, "BLUS: TRANSFER_AMOUNT_EXCEEDED"));
        return true;
    }

    function _amountafterBurn(address from, uint256 amount) internal returns (uint256) {
        uint256 burnAmount = _calculateBurnAmount(amount);

        if (burnAmount > 0) {
            _burn(from, burnAmount);
        }

        return amount.sub(burnAmount);
    }

    function _calculateBurnAmount(uint256 amount)
        internal
        view
        returns (uint256)
    {
        uint256 burnAmount = 0;
        // burn amount calculations
        if (totalSupply() > _minimumSupply) {
            burnAmount = amount.mul(_burnRate).div(100);
            uint256 availableBurn = totalSupply().sub(_minimumSupply);
            if (burnAmount > availableBurn) {
                burnAmount = availableBurn;
            }
        }

        return burnAmount;
    }


    function mintToken(address recipient, uint256 amount) onlyOwner external {
        _mint(recipient, amount);
        require(totalSupply() <= 10 * 10**8 * 10**18, "BLUS: TOTAL_SUPPLY_EXCEEDED");
    }

    function burn(uint256 amount) public override  {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
    {
        super.burnFrom(account, amount);
    }


    function setLock(address account, uint8 stats, uint256 amount)
        onlyOwner external
    {
        lockList[account] = stats;
        lockAmount[account] = amount;
    }

    function setFeeAddress(address account, uint8 stats)
        onlyOwner external
    {
        feeAddress[account] = stats;
    }


    function setMinimumSupply(uint256 amount) external onlyOwner {
        _minimumSupply = amount;
    }

    function setBurnRate(uint8 rate) external onlyOwner {
        require(rate<100, "error rate");
        _burnRate = rate;
    }




}
