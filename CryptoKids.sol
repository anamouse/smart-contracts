// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKids {
    // owner DAD
    address owner;

    event LogKidFundingReceived(
        address addr,
        uint256 amount,
        uint256 contractBalance
    );

    constructor() {
        owner = msg.sender;
    }

    // define Kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint256 releaseTime;
        uint256 amount;
        bool canWithdraw;
    }

    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    // add kid to contract
    function addKid(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        uint256 releaseTime,
        uint256 amount,
        bool canWithdraw
    ) public onlyOwner {
        kids.push(
            Kid(
                walletAddress,
                firstName,
                lastName,
                releaseTime,
                amount,
                canWithdraw
            )
        );
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    //deposit funds to contract, specifically to a kid's account
    function deposit(address walletAddress) public payable {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private {
        for (uint256 i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(
                    walletAddress,
                    msg.value,
                    balanceOf()
                );
            }
        }
    }

    function getIndex(address walletAddress) private view returns (uint256) {
        for (uint256 i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 999;
    }

    // kid checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns (bool) {
        uint256 i = getIndex(walletAddress);
        require(
            block.timestamp > kids[i].releaseTime,
            "You cannot withdraw yet"
        );
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) public payable {
        uint256 i = getIndex(walletAddress);
        require(
            msg.sender == kids[i].walletAddress,
            "You must be the kid to withdraw"
        );
        require(
            kids[i].canWithdraw == true,
            "You are not able to withdraw at this time"
        );
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}
