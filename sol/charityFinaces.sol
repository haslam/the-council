pragma solidity ^0.4.25;
interface TheCouncil{
    
    /*
	event onVouchedFor(address indexed voucher,address indexed vouchee, uint256 voucherTrustLevel, uint256 voucheeTrustLevel);
	event onUnvouchedFor(address indexed voucher,address indexed vouchee);
	event onBlacklist(address indexed blacklister,address indexed blacklistee, uint256 blacklisterTrustLevel);
	event onUnblacklist(address indexed unblacklister,address indexed blacklistee, uint256 unblacklisterTrustLevel);
    */
    function getTrustLevel(address) external view returns (uint256 trust, bool isBlacklisted);
    function getTrustData(address) external view returns (uint256 trust, bool isBlacklisted, address authority, uint256 authorityTrust);
    function vouchForUser(address) external;
    function unVouchForUser(address) external;
    function markUser(address) external;
    function unmarkUser(address) external;
}

interface CharityDB{
    /*
        event onRegistered(address indexed addr, address indexed submitter, bytes32 name, uint8 t, uint256 otherData);
    */
    function getOrganization(address addr) external view returns (address, address, string, string, uint8, uint256);
    function getOrganizationByName(string name) external view returns (address, address, string, string, uint8, uint256);
    function getOrganizationAddressByName(string name) external view returns (address);
}

contract CharityFinaces{
    using SafeMath for uint256;
    using SafeMath for int256;
    
    TheCouncil internal council;
    CharityDB internal charityDb;
    uint256 constant internal roundingMagnitude = 2**64;
    
    event onDonated(address indexed donator, address indexed charity, uint256 amount);
    
    constructor(address tc, address cdb) public{
        council = TheCouncil(tc);
        charityDb = CharityDB(cdb);
    }
    
    modifier validCharity(){
        (
            address charityAddr,
            address submitter,
            string memory name,
            string memory fullName,
            uint8 t,
            uint256 data
        ) = charityDb.getOrganization(msg.sender);
        require(t == 1, "ERR_CHARITY_UNKNOWN");
        (
            uint256 trustLevel,
            bool isBlacklisted
        ) = council.getTrustLevel(msg.sender);
        require(trustLevel > 0 && !isBlacklisted, "ERR_CHARITY_UNTRUSTWORTHY");
        _;
    }
    
    struct Refugee {
        uint256 shares;
        address charity;
        int256 payout;
    }
    
    struct CharityFunds {
        uint256 profitPerShare;
        uint256 totalShareSupply;
        uint256 totalMoneySupply;
        
        mapping(address => uint256) fundsSpent;
        uint256 totalFundsSpent;
    }
    
    mapping (address => Refugee) refugees;
    mapping (address => CharityFunds) charityFunds;
    
    
    // Charity functions
    function doPayout(uint256 amount) public {
        require(charityFunds[msg.sender].totalMoneySupply >= amount, "ERR_CHARITY_CANT_AFFORD");
        require(charityFunds[msg.sender].totalShareSupply > 0, "ERR_CHARITY_NO_SHARES");
        charityFunds[msg.sender].totalMoneySupply -= amount;
        charityFunds[msg.sender].profitPerShare = charityFunds[msg.sender].profitPerShare.add((amount * roundingMagnitude) / charityFunds[msg.sender].totalShareSupply);
    }
    
    function withdraw(uint256 amount) public {
        require(charityFunds[msg.sender].totalMoneySupply >= amount, "ERR_CHARITY_CANT_AFFORD");
        charityFunds[msg.sender].totalMoneySupply -= amount;
        charityFunds[msg.sender].fundsSpent[msg.sender] += amount;
        charityFunds[msg.sender].totalFundsSpent = charityFunds[msg.sender].totalFundsSpent.add(amount);
        msg.sender.transfer(amount);
    }
    
    function charityOf (address refugee) public view returns (address) {
        return refugees[refugee].charity;
    }
    
    function sharesOf (address refugee) public view returns (uint256) {
        return refugees[refugee].shares;
    }
    
    function totalShares(address charity) public view returns (uint256) {
        return charityFunds[charity].totalShareSupply;
    }
    
    function addShares(address refugee, uint256 amount) public validCharity {
        require(refugees[refugee].charity == 0x0 || refugees[refugee].charity == msg.sender, "ERR_CHARITY_ALREADY_SPONSORED");
        
        charityFunds[refugees[refugee].charity].totalShareSupply = charityFunds[refugees[refugee].charity].totalShareSupply.add(amount);
        
        // Refugee is not allowed to have payouts from before they owned the tokens.
        refugees[refugee].payout = refugees[refugee].payout.add(int256(charityFunds[msg.sender].profitPerShare * amount));
        refugees[refugee].shares = refugees[refugee].shares.add(amount);
    }
    
    function removeShares(address refugee, uint256 amount) public validCharity {
        require(refugees[refugee].charity == msg.sender, "ERR_CHARITY_PERMISSION_DENIED");
        
        charityFunds[refugees[refugee].charity].totalShareSupply = charityFunds[refugees[refugee].charity].totalShareSupply.sub(amount);
        
        // Sender can have their payouts from when they owned the tokens
        refugees[refugee].payout = refugees[refugee].payout.sub(int256(charityFunds[msg.sender].profitPerShare * amount));
        refugees[refugee].shares = refugees[refugee].shares.sub(amount);
        if (refugees[refugee].shares == 0){
            refugees[refugee].charity = 0x0;
        }
    }
    
    // refugee functions
    
    function donatedFundsOf(address refugee) public view returns(uint256){
        uint256(int256(charityFunds[ refugees[refugee].charity ].profitPerShare * refugees[refugee].shares) - refugees[refugee].payout) / roundingMagnitude;
    }
    
    function spendDonatedFunds(address to, uint256 amount) public{
        require(amount >= donatedFundsOf(msg.sender), "ERR_CHARITY_CANT_AFFORD");
        (
            address charityAddr,
            address submitter,
            string memory name,
            string memory fullName,
            uint8 t,
            uint256 data
        ) = charityDb.getOrganization(to);
        require(t == 2, "ERR_CHARITY_NOT_MERCHANT");
        refugees[msg.sender].payout = refugees[msg.sender].payout.add(int256(amount * roundingMagnitude));
        charityFunds[refugees[msg.sender].charity].totalFundsSpent += amount;
        charityFunds[refugees[msg.sender].charity].fundsSpent[to] += amount;
        to.transfer(amount);
    }
    
    
    // public functions
    
    function getCharitySpendingAmount(address charity, address merchant) public view returns (uint256){
        return charityFunds[charity].fundsSpent[merchant];
    }
    function getTotalCharitySpendingAmount(address charity) public view returns (uint256){
        return charityFunds[charity].totalFundsSpent;
    }
    
    function donateByAddress(address addr) public payable {
        (
            address charityAddr,
            address submitter,
            string memory name,
            string memory fullName,
            uint8 t,
            uint256 data
        ) = charityDb.getOrganization(addr);
        require(t == 1, "ERR_CHARITY_NOT_CHARITY");
        (
            uint256 trustLevel,
            bool isBlacklisted
        ) = council.getTrustLevel(submitter);
        require(trustLevel > 0 && !isBlacklisted, "ERR_CHARITY_UNTRUSTWORTHY");
        (
            trustLevel,
            isBlacklisted
        ) = council.getTrustLevel(charityAddr);
        require(trustLevel > 0 && !isBlacklisted, "ERR_CHARITY_UNTRUSTWORTHY");
        
        charityFunds[addr].totalMoneySupply += msg.value;
        emit onDonated(msg.sender, charityAddr, msg.value);
    }
    function donateByName(string name) public payable {
        donateByAddress(charityDb.getOrganizationAddressByName(name));
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
           return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}