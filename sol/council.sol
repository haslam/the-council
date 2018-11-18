pragma solidity ^0.4.25;
contract TheCouncil{
	modifier onlyRegistered() {
		require(trustLevel[msg.sender] != 0, "ERR_COUNCIL_UNREGISTERED");
		_;
	}
	modifier onlyAdmin() {
	    require(trustLevel[msg.sender] == 1, "ERR_COUNCIL_NOT_ADMIN");
	    _;
	}
	mapping(address => uint256) public trustLevel;
	mapping(address => address[5]) internal previouslyTrustedBy;
	mapping(address => uint256) public blacklistAuthority;
	mapping(address => bool) public blacklist;
	mapping(address => address) public blacklister;
	
	constructor() public{
	    trustLevel[0x0] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
	}
    
    function vouchForUser(address vouchee) onlyRegistered public {
        address lowestAlreadyTrusted;
        uint256 lowestTrustLevel = trustLevel[msg.sender];
        uint8 lowestAlreadyTrustedIndex = 0;
        for (uint8 i = 0; i < 5; i += 1){
            if (trustLevel[previouslyTrustedBy[vouchee][i]] > lowestTrustLevel){
                lowestAlreadyTrusted = previouslyTrustedBy[vouchee][i];
                lowestTrustLevel = trustLevel[lowestAlreadyTrusted];
                lowestAlreadyTrustedIndex = i;
            }
        }
        require(lowestAlreadyTrusted != 0x0, "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        previouslyTrustedBy[vouchee][lowestAlreadyTrustedIndex] = msg.sender;
        trustLevel[vouchee] = trustLevel[msg.sender] + 1;
    }
    
    function unVouchForUser(address vouchee) onlyRegistered public{
        uint256 prevousTrustLevel = trustLevel[0x0];
        for (uint8 i = 0; i < 5; i+=1){
            if (previouslyTrustedBy[vouchee][i] == msg.sender){
                previouslyTrustedBy[vouchee][i] = 0x0;
            }else if (trustLevel[previouslyTrustedBy[vouchee][i]] < prevousTrustLevel){
                prevousTrustLevel = trustLevel[previouslyTrustedBy[vouchee][i]];
            }
        }
        // Known: If there are no other vouched users, MAX_INT is used, which then overflows to 0 which then makes the user "unregistered"
        trustLevel[vouchee] = prevousTrustLevel + 1;
    }
    
    function markUser(address markee) onlyRegistered public{
        require(blacklistAuthority[markee] == 0 || blacklistAuthority[markee] > trustLevel[msg.sender], "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        blacklistAuthority[markee] = trustLevel[msg.sender];
        blacklister[markee] = msg.sender;
        blacklist[markee] = true;
    }
    
    function unmarkUser(address markee) onlyRegistered public{
        require(blacklistAuthority[markee] > trustLevel[msg.sender] || blacklister[markee] == msg.sender, "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        blacklistAuthority[markee] = 0;
        blacklister[markee] = 0x0;
        blacklist[markee] = false;
    }
}