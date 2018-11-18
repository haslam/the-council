pragma solidity ^0.4.25;
contract TheCouncil{
	modifier registered() {
		require(trustLevel[msg.sender] != 0, "ERR_COUNCIL_UNREGISTERED");
		_;
	}
	modifier notBlacklisted() {
	    require(!blacklist[msg.sender], "ERR_COUNCIL_BLACKLISTED");
	    _;
	}
	
	event onVouchedFor(address indexed voucher,address indexed vouchee, uint256 voucherTrustLevel, uint256 voucheeTrustLevel);
	event onUnvouchedFor(address indexed voucher,address indexed vouchee);
	event onBlacklist(address indexed blacklister,address indexed blacklistee, uint256 blacklisterTrustLevel);
	event onUnblacklist(address indexed unblacklister,address indexed blacklistee, uint256 unblacklisterTrustLevel);
	
	mapping(address => uint256) public trustLevel;
	mapping(address => address[5]) internal previouslyTrustedBy;
	mapping(address => uint256) internal blacklistAuthority;
	mapping(address => bool) public blacklist;
	mapping(address => address) public blacklister;
	
	constructor() public{
	    // The lowest trust level (most untrustworthy)
	    trustLevel[0x0] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
	    
	    // The default Remix IDE address
	    //trustLevel[0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c] = 1;
	    
	    // ARitz Cracker
	    trustLevel[0x8c070C3c66F62E34bAe561951450f15f3256f67c] = 1;
	    
	    // Jake
	    trustLevel[0x2767B9539fDd8F9b9328194cB295593b60e6692d] = 1;
	    
	    // Bearium
	    trustLevel[0x9Dc330468caD65E6b89A4E49A9360B46e4220359] = 1;
	    
	    // Pat
	    trustLevel[0xa52B339666bbaD34EC4A0AC9113A7937cbb65a6A] = 1;
	}
	
	function previouslyTrustedByList(address user) public view returns(address, address, address, address, address){
	    return (previouslyTrustedBy[user][0], previouslyTrustedBy[user][1], previouslyTrustedBy[user][2], previouslyTrustedBy[user][3], previouslyTrustedBy[user][4]);
	}
    
    function vouchForUser(address vouchee) notBlacklisted registered public {
        require(vouchee != 0x0);
        require(msg.sender != vouchee, "ERR_COUNCIL_DONT_TRUST_SELF");
        checkIfStillTrustworthy(msg.sender);
        address lowestAlreadyTrusted;
        uint256 lowestTrustLevel = trustLevel[msg.sender];
        uint256 currentTrustLevel = trustLevel[msg.sender];
        uint8 lowestAlreadyTrustedIndex = 0;
        for (uint8 i = 0; i < 5; i += 1){
            if (trustLevel[previouslyTrustedBy[vouchee][i]] > lowestTrustLevel){
                lowestAlreadyTrusted = previouslyTrustedBy[vouchee][i];
                lowestTrustLevel = trustLevel[lowestAlreadyTrusted];
                lowestAlreadyTrustedIndex = i;
            }
        }
        require(lowestAlreadyTrusted != 0x0 || trustLevel[vouchee] == 0, "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        previouslyTrustedBy[vouchee][lowestAlreadyTrustedIndex] = msg.sender;
        if (trustLevel[vouchee] == 0 || currentTrustLevel < trustLevel[vouchee]){
            trustLevel[vouchee] = trustLevel[msg.sender] + 1;
        }
        emit onVouchedFor(msg.sender, vouchee, trustLevel[msg.sender], trustLevel[vouchee]);
    }
    
    function unVouchForUser(address vouchee) registered public{
        require(vouchee != 0x0);
        uint256 prevousTrustLevel = trustLevel[0x0];
        bool actuallyDidSomething = false;
        for (uint8 i = 0; i < 5; i+=1){
            if (previouslyTrustedBy[vouchee][i] == msg.sender){
                previouslyTrustedBy[vouchee][i] = 0x0;
                actuallyDidSomething = true;
            }else if (trustLevel[previouslyTrustedBy[vouchee][i]] < prevousTrustLevel){
                prevousTrustLevel = trustLevel[previouslyTrustedBy[vouchee][i]];
            }
        }
        require(actuallyDidSomething, "ERR_COUNCIL_NOT_VOUCHED");
        if (trustLevel[vouchee] > 1){
            // Overflow on maximum value is intentional (0 means unregistered)
            trustLevel[vouchee] = prevousTrustLevel + 1;
        }
        emit onUnvouchedFor(msg.sender, vouchee);
    }
    
    function markUser(address markee) notBlacklisted registered public{
        require(markee != 0x0);
        checkIfStillTrustworthy(msg.sender);
        require(
            // msg.sender must be more trustworthy than previous authority
            (blacklistAuthority[markee] == 0 || blacklistAuthority[markee] > trustLevel[msg.sender]) &&
            // msg.sender must be higher than the markee
            (trustLevel[markee] == 0) || trustLevel[markee] > trustLevel[msg.sender]
        , "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        blacklistAuthority[markee] = trustLevel[msg.sender];
        blacklister[markee] = msg.sender;
        blacklist[markee] = true;
        emit onBlacklist(msg.sender, markee, trustLevel[msg.sender]);
    }
    
    function unmarkUser(address markee) registered public{
        require(markee != 0x0);
        checkIfStillTrustworthy(msg.sender);
        require(blacklistAuthority[markee] > trustLevel[msg.sender] || blacklister[markee] == msg.sender, "ERR_COUNCIL_NOT_ENOUGH_TRUST");
        blacklistAuthority[markee] = trustLevel[msg.sender];
        blacklister[markee] = msg.sender;
        blacklist[markee] = false;
        emit onBlacklist(msg.sender, markee, trustLevel[msg.sender]);
    }
    
    function getTrustData(address user) public view returns (uint256 trust, bool isBlacklisted, address authority, uint256 authorityTrust){
        checkIfStillTrustworthy(user);
        return (trustLevel[user], blacklist[user], blacklister[user], blacklistAuthority[user]);
    }
    
    function getTrustLevel(address user) public view returns (uint256 trust, bool isBlacklisted){
        checkIfStillTrustworthy(user);
        return (trustLevel[user], blacklist[user]);
    }
    
    
    function checkIfStillTrustworthy(address user) internal {
        uint256 currentTrustLevel = trustLevel[0x0];
        
        if (trustLevel[user] > 1 && user != 0x0){
            uint256 previouslyTrustedBylevel;
            for (uint8 i = 0; i < 5; i+=1){
                previouslyTrustedBylevel = trustLevel[previouslyTrustedBy[user][i]];
                if (blacklist[previouslyTrustedBy[user][i]]){
                    previouslyTrustedBy[user][i] = 0x0;
                }else if(previouslyTrustedBylevel != 0 && previouslyTrustedBylevel < currentTrustLevel){
                    currentTrustLevel = previouslyTrustedBylevel;
                }
            }
            // Overflow on maximum value is intentional (0 means unregistered)
            currentTrustLevel += 1;
            if (currentTrustLevel != trustLevel[user]){
                trustLevel[user] = currentTrustLevel;
            }
        }

    }
}