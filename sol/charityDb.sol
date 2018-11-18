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


// 300 ether


// 10,000

contract CharityDB{
    struct Organization{
        address addr;
        address submitter;
        bytes32 name;
        bytes32[4] fullName;
        // 1 = Charity
        // 2 = Merchant
        uint8 t;
        uint256 otherData;
    }
    
    event onRegistered(address indexed addr, address indexed submitter, bytes32 name, uint8 t, uint256 otherData);
    
    mapping (address => Organization) public organizations;
    mapping (bytes32 => address) public organizationAddresses;
    
    TheCouncil internal council;
    constructor(address tc) public {
        
        council = TheCouncil(tc);
    }
    
    function getOrganization(address addr) public view returns (address, address, string, string, uint8, uint256){
        Organization memory o = organizations[addr];
        return (o.addr, o.submitter, string(bytes32ToBytes(o.name)), string(bytes128ToBytes(o.fullName)), o.t, o.otherData);
    }
    function getOrganizationByName(string name) public view returns (address, address, string, string, uint8, uint256){
        name = toUpperCase(name);
        bytes32 n = bytesToBytes32(bytes(name));
        Organization memory o = organizations[organizationAddresses[n]];
        return (o.addr, o.submitter, string(bytes32ToBytes(o.name)), string(bytes128ToBytes(o.fullName)), o.t, o.otherData);
    }
    function getOrganizationAddressByName(string name) public view returns (address){
        bytes32 n = bytesToBytes32(bytes(name));
        return organizationAddresses[n];
    }
    
    function validateName(string name) public pure returns (bool){
        bytes memory b = bytes(name);
        if (b.length > 32){
            return false;
        }
        
        // Only chars a-z, A-Z, 0-9, and space
        for (uint i = 0; i < b.length; i += 1){
            if (
                b[i] < 0x20 ||
                (b[i] > 0x20 && b[i] < 0x30) ||
                (b[i] > 0x39 && b[i] < 0x41) ||
                (b[i] > 0x5A && b[i] < 0x61) ||
                b[i] > 0x7A
            ){
                return false;
            }
        }
        return true;
    }
    function toUpperCase(string str) public pure returns (string){
        // this function assumes validateName has passed
        bytes memory b = bytes(str);
        for (uint i = 0; i < b.length; i += 1){
            b[i] &= 0xDF;
        }
        return string(b);
    }
    
    function register(uint8 t, string name, string fullName, uint256 otherData) public {
        registerOther(msg.sender, t, name, fullName, otherData);
    }
    
    function registerOther(address user, uint8 t, string name, string fullName, uint256 otherData) public {
        require(user != 0x0);
        require(validateName(name), "ERR_CHARITY_INVALID_NAME");
        require(t == 1 || t == 2, "ERR_CHARITY_INVALID_TYPE");
        name = toUpperCase(name);
        
        uint256 senderTrustLevel;
        bool senderIsBlacklisted;
        (senderTrustLevel, senderIsBlacklisted) = council.getTrustLevel(msg.sender);
        require(senderTrustLevel > 0 && !senderIsBlacklisted, "ERR_CHARITY_UNTRUSTWORTHY");
        
        uint256 prevSubmitterTrustLevel;
        bool prevSubmitterIsBlacklisted;
        (prevSubmitterTrustLevel, prevSubmitterIsBlacklisted) = council.getTrustLevel(organizations[user].submitter);
        
        require(prevSubmitterTrustLevel > senderTrustLevel || prevSubmitterIsBlacklisted, "ERR_CHARITY_UNTRUSTWORTHY");
        
        if (organizations[user].addr != 0x0){
            organizationAddresses[organizations[user].name] = 0x0;
        }
        
        Organization newOrg;
        newOrg.addr = user;
        newOrg.submitter = msg.sender;
        newOrg.name = bytesToBytes32(bytes(name));
        newOrg.fullName = bytesToBytes128(bytes(fullName));
        newOrg.t = t;
        newOrg.otherData = otherData;
        
        emit onRegistered(user, msg.sender, newOrg.name, t, otherData);
        organizations[user] = newOrg;
        organizationAddresses[newOrg.name] = user;
       // newOrg.name = bytesToBytes32(bytes(name));
    }

    function bytes128ToBytes(bytes32[4] b) internal pure returns (bytes) {
        bytes memory bytesString = new bytes(128);
        uint charCount = 0;
        uint ii = 0;
        for (uint i = 0; i < 128; i++) {
            ii = i / 4;
            byte char = byte(bytes32(uint(b[ii]) * 2 ** (8 * (i - ii * 32))));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return bytesStringTrimmed;
    }

    function bytes32ToBytes(bytes32 b) internal pure returns (bytes) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint i = 0; i < 32; i++) {
            byte char = byte(bytes32(uint(b) * 2 ** (8 * i)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return bytesStringTrimmed;
    }
    
    function bytesToBytes32(bytes b) internal pure returns (bytes32) {
        uint len = b.length;
        if (len > 32){
            len = 32;
        }
        bytes32 out;
        
        for (uint i = 0; i < len; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }
    
    function bytesToBytes128(bytes b) internal pure returns (bytes32[4]){
        uint len = b.length;
        if (len > 128){
            len = 128;
        }
        bytes32[4] memory out;
        uint i = 0;
        for (uint ii = 0; ii < len; ii++) {
            i = ii / 32;
            out[i] |= bytes32(b[ii] & 0xFF) >> ((ii - (i * 32)) * 8);
        }
        return out;
    }
}




