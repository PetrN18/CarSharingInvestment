pragma solidity ^0.8.0;

contract CarSharingInvestment {
    address public owner;
    uint256 public totalTokens;
    uint256 public tokenPrice;
    uint256 public annualInterestRate;
    uint256 public tokenMaturityPeriod;
    uint256 public lastCouponPayment;

    struct Investor {
        uint256 tokenBalance;
        uint256 investedAt;
    }

    mapping(address => Investor) public investors;
    address[] public investorAddresses;

    event TokensPurchased(address indexed investor, uint256 amount);
    event CouponPaid(address indexed investor, uint256 amount);
    event TokensRedeemed(address indexed investor, uint256 amount);
    event ContractFunded(address indexed owner, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(
        uint256 _totalTokens,
        uint256 _tokenPrice,
        uint256 _annualInterestRate,
        uint256 _tokenMaturityPeriod
    ) {
        owner = msg.sender;
        totalTokens = _totalTokens;
        tokenPrice = _tokenPrice;
        annualInterestRate = _annualInterestRate;
        tokenMaturityPeriod = _tokenMaturityPeriod;
        lastCouponPayment = block.timestamp;
    }

    function buyTokens(uint256 amount) external payable {
        require(msg.value == amount * tokenPrice, "Incorrect payment amount");
        require(totalTokens >= amount, "Not enough tokens available");

        Investor storage investor = investors[msg.sender];
        if (investor.tokenBalance == 0 && !isInvestor(msg.sender)) {
            investorAddresses.push(msg.sender);
        }
        investor.tokenBalance += amount;
        investor.investedAt = block.timestamp;

        totalTokens -= amount;
        emit TokensPurchased(msg.sender, amount);
    }

    function payCoupon() external onlyOwner {
        require(block.timestamp >= lastCouponPayment + 180 days, "Coupon payment is not due yet");
        uint256 totalAmount = totalCouponAmount();
        require(address(this).balance >= totalAmount, "Insufficient funds to pay coupons");

        for (uint256 i = 0; i < investorAddresses.length; i++) {
            address investorAddress = investorAddresses[i];
            Investor storage investor = investors[investorAddress];
            if (investor.tokenBalance > 0) {
                uint256 couponAmount = (investor.tokenBalance * annualInterestRate / 2) / 100;
                (bool success, ) = payable(investorAddress).call{value: couponAmount}("");
                require(success, "Coupon payment failed");
                emit CouponPaid(investorAddress, couponAmount);
            }
        }
        lastCouponPayment = block.timestamp;
    }

    function totalCouponAmount() public view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            address investorAddress = investorAddresses[i];
            Investor storage investor = investors[investorAddress];
            if (investor.tokenBalance > 0) {
                totalAmount += (investor.tokenBalance * annualInterestRate / 2) / 100;
            }
        }
        return totalAmount;
    }

    function fundContract() external payable onlyOwner {
        require(msg.value > 0, "Must send some ether");
        emit ContractFunded(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner).transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
    }

    function getInvestorAddresses(uint256 start, uint256 count) external view returns (address[] memory) {
        uint256 end = start + count > investorAddresses.length ? investorAddresses.length : start + count;
        address[] memory slice = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            slice[i - start] = investorAddresses[i];
        }
        return slice;
    }

    function isInvestor(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            if (investorAddresses[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
