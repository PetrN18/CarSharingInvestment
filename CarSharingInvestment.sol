pragma solidity ^0.8.0;

contract CarSharingInvestment {
    // переменные состояния
    address public owner; // адрес владельца контракта (каршеринговая компания)
    uint256 public totalTokens; // общее количество выпущенных токенов
    uint256 public tokenPrice; // стоимость одного токена
    uint256 public annualInterestRate; // годовая процентная ставка для расчета дохода
    uint256 public tokenMaturityPeriod; // период погашения токенов (в секундах)
    uint256 public lastCouponPayment; //время последней выплаты купона

    struct Investor {
        uint256 tokenBalance; // количество токенов у инвестора
        uint256 investedAt; // время покупки токенов
    }

    // реестр инвесторов
    mapping(address => Investor) public investors;

    // ивенты
    event TokensPurchased(address indexed investor, uint256 amount); // "покупка токенов"
    event CouponPaid(address indexed investor, uint256 amount); // "выплата купона"
    event TokensRedeemed(address indexed investor, uint256 amount); // "погашение токенов"

    // модификатор для проверки прав владельца
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // конструктор контракта
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

    // покупка токенов
    function buyTokens(uint256 amount) external payable {
        require(msg.value == amount * tokenPrice, "Incorrect payment amount");
        require(totalTokens >= amount, "Not enough tokens available");

        Investor storage investor = investors[msg.sender];
        if (investor.tokenBalance == 0) {
            investor.tokenBalance = amount;
            investor.investedAt = block.timestamp;
        } else {
            investor.tokenBalance += amount;
        }

        totalTokens -= amount;
        emit TokensPurchased(msg.sender, amount);
    }

    // выплата купонного дохода
    function payCoupon() external onlyOwner {
        require(block.timestamp >= lastCouponPayment + 180 days, "Coupon payment is not due yet");

        for (address investorAddress = address(0); investorAddress < address(this); investorAddress++) {
            Investor storage investor = investors[investorAddress];
            if (investor.tokenBalance > 0) {
                uint256 couponAmount = (investor.tokenBalance * annualInterestRate / 2) / 100;
                payable(investorAddress).transfer(couponAmount);
                emit CouponPaid(investorAddress, couponAmount);
            }
        }

        lastCouponPayment = block.timestamp;
    }

    // пополнение контракта владельцем
    function fundContract() external payable onlyOwner {}

    // снятие средств владельцем
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }
}
