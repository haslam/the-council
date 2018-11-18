'use strict';

const contractAddress = "0x98a79B3871Eed82AB7f9C94B3D7E57C6bea9028d";
const contractABI = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "markee",
				"type": "address"
			}
		],
		"name": "markUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "voucher",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "vouchee",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "voucherTrustLevel",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "voucheeTrustLevel",
				"type": "uint256"
			}
		],
		"name": "onVouchedFor",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "voucher",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "vouchee",
				"type": "address"
			}
		],
		"name": "onUnvouchedFor",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "blacklister",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "blacklistee",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "blacklisterTrustLevel",
				"type": "uint256"
			}
		],
		"name": "onBlacklist",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "unblacklister",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "blacklistee",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "unblacklisterTrustLevel",
				"type": "uint256"
			}
		],
		"name": "onUnblacklist",
		"type": "event"
	},
	{
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "markee",
				"type": "address"
			}
		],
		"name": "unmarkUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "vouchee",
				"type": "address"
			}
		],
		"name": "unVouchForUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "vouchee",
				"type": "address"
			}
		],
		"name": "vouchForUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "blacklist",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "blacklister",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			}
		],
		"name": "getTrustData",
		"outputs": [
			{
				"name": "trust",
				"type": "uint256"
			},
			{
				"name": "isBlacklisted",
				"type": "bool"
			},
			{
				"name": "authority",
				"type": "address"
			},
			{
				"name": "authorityTrust",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "trustLevel",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]

class EthWrapperError extends Error{
	constructor(msg){
		super(msg);
		this.name = "EthWrapperError";
	}
}
class EthWrapperEnableError extends Error{
	constructor(msg, denied){
		super(msg);
		this.name = "EthWrapperEnableError";
		this.denied = Boolean(denied);
	}
}
const assert = function(e, msg){
	if (!e){
		throw new EthWrapperError(msg);
	}
}

let loaded = false;
let callLoad = false;
let currentAccount;
let accountChecker;
let web3;
let BigNumber;
let theCouncil;

let loginListeners = [];

let EthWrapper = {
	async load(){
		if (callLoad){
			throw new Error("Don't call load multiple times");
		}
		callLoad = true;
		// Modern dapp browsers...
		if (window.ethereum) {
			web3 = new Web3(ethereum);
			try {
				await ethereum.enable();
			} catch (error) {
				throw new EthWrapperEnableError("Permission not given", true);
			}
		}
		// Legacy dapp browsers...
		else if (window.web3) {
			web3 = new Web3(window.web3.currentProvider);
		}
		// Non-dapp browsers...
		else {
			throw new EthWrapperEnableError("Metamask not installed", false);
		}
		currentAccount = web3.eth.accounts[0];
		BigNumber = web3.BigNumber;
		accountChecker = setInterval(function() {
		  if (web3.eth.accounts[0] !== currentAccount) {
			currentAccount = web3.eth.accounts[0];
			let checksumAddress = web3.toChecksumAddress(currentAccount);
			for (let i = 0; i < loginListeners.length; i += 1){
				loginListeners[i](checksumAddress);
			}
		  }
		}, 500);
		loaded = true;
		theCouncil = web3.eth.contract(contractABI).at(contractAddress);
	},
	getBigNumberConstructor(){
		return BigNumber;
	},
	getCurrentAccount(){
		assert(loaded, "Not loaded");
		return web3.toChecksumAddress(currentAccount);
	},
	addLoginCallback(func){
		assert(loaded, "Not loaded");
		if(loginListeners.indexOf(func) == -1) {
			let i = 0;
			while(loginListeners[i] != null) {
				i += 1;
			}
			loginListeners[i] = func;
		}
	},
	removeLoginCallback(func){
		assert(loaded, "Not Loaded");
		for (let i = 0; i < loginListeners.length; i += 1) {
			if (loginListeners[i] == func){
				delete loginListeners[i];
				break;
			}
		}
		for (let i = loginListeners.length - 1; i >= 0; i -= 1) {
			if (loginListeners[i] == null){
				loginListeners.pop();
			}else{
				break;
			}
		}
	},
	// Council-specific data
	getTrustData(address) {
		assert(loaded, "Not Loaded");
		return new Promise((resolve, reject) => {
			theCouncil.getTrustData(address,(err, result) => {
				if (err) {
					reject(err);
				} else {
					resolve({
						trustLevel: result[0], // BigNumber
						blacklisted: result[1], // Boolean
						authority: result[2], // AddressString
						authorityTrustLevel: result[3] // BigNumber
					});
				}
			});
		})
	},
	vouchForUser(address){
		assert(loaded, "Not Loaded");
		return new Promise((resolve, reject) => {
			theCouncil.vouchForUser(address,(err, txHash) => {
				if (err) {
					reject(err);
				} else {
					resolve(txHash);
					// You can say something like "Visit https://ropsten.etherscan.io/tx/"+txHash
				}
			});
		})
	},
	unVouchForUser(address){
		assert(loaded, "Not Loaded");
		return new Promise((resolve, reject) => {
			theCouncil.unVouchForUser(address,(err, txHash) => {
				if (err) {
					reject(err);
				} else {
					resolve(txHash);
					// You can say something like "Visit https://ropsten.etherscan.io/tx/"+txHash
				}
			});
		})
	},
	markUser(address){
		assert(loaded, "Not Loaded");
		return new Promise((resolve, reject) => {
			theCouncil.markUser(address,(err, txHash) => {
				if (err) {
					reject(err);
				} else {
					resolve(txHash);
					// You can say something like "Visit https://ropsten.etherscan.io/tx/"+txHash
				}
			});
		})
	},
	unmarkUser(address){
		assert(loaded, "Not Loaded");
		return new Promise((resolve, reject) => {
			theCouncil.unmarkUser(address,(err, txHash) => {
				if (err) {
					reject(err);
				} else {
					resolve(txHash);
					// You can say something like "Visit https://ropsten.etherscan.io/tx/"+txHash
				}
			});
		})
	}
}

module.exports = EthWrapper;
