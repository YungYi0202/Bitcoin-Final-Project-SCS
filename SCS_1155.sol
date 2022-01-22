// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/token/ERC1155/ERC1155.sol";

struct issuedProposal {
    address proposer;
    uint proposalID;
    uint agreedAmount;
    uint shareAmount;
}


struct redeemedProposal {
    uint targetProposalID;
    uint agreedAmount;
}

contract SCS is ERC1155 {
    uint256 public constant GOLD = 0;
    mapping(address => mapping(uint => bool)) public isAgree;
    mapping(address => bool) public boardMember;
    mapping(uint => issuedProposal) public issuedProposals;
    mapping(uint => redeemedProposal) public redeemedProposals;
    uint boardMemberAmount = 0;
    uint proposalCnt = 0;

    constructor(address[] memory other_member_address) 
    public
    ERC1155("https://abcoathup.github.io/SampleERC1155/api/token/{id}.json")  
    {
        // chairman = msg.sender;
        boardMember[msg.sender] = true;
        boardMemberAmount++;
        for (uint i = 0; i < other_member_address.length; i++) {
            boardMember[other_member_address[i]] = true;
            boardMemberAmount++;
        }
    }

    modifier isBoardMember() {
        require(boardMember[msg.sender], "Caller is not boardMember");
        _;
    }

    function askIssue(uint shareAmount) external isBoardMember returns (uint) {
        issuedProposals[proposalCnt] = issuedProposal(msg.sender, proposalCnt, 0, shareAmount);
        return proposalCnt++;
    }

    function agreeIssue(uint proposalID) external isBoardMember {
        require(!isAgree[msg.sender][proposalID], "You have agreed!");
        isAgree[msg.sender][proposalID] = true;
        issuedProposals[proposalID].agreedAmount += 1;
    }


    function issue(uint proposalID) external isBoardMember {
        require(issuedProposals[proposalID].agreedAmount == boardMemberAmount, "not all agreed yet");
        require(issuedProposals[proposalID].proposer == msg.sender, "Caller is not the proposer");
        // require(!_exists(proposalID), "This proposal has been issued.");
        _mint(msg.sender, proposalID, issuedProposals[proposalID].shareAmount, "");
    }

    
    function askRedeem(uint targetProposalID) external isBoardMember returns (uint) {
        redeemedProposals[proposalCnt] = redeemedProposal(targetProposalID, 0);
        return proposalCnt++;
    }

    function agreeRedeem(uint proposalID) external isBoardMember {
        require(!isAgree[msg.sender][proposalID], "You have agreed!");
        isAgree[msg.sender][proposalID] = true;
        redeemedProposals[proposalID].agreedAmount += 1;
    }

    function redeem(uint proposalID) external isBoardMember {
        require(redeemedProposals[proposalID].agreedAmount == boardMemberAmount, "not all agreed yet");
        uint targetId = redeemedProposals[proposalID].targetProposalID;
        require(issuedProposals[targetId].proposer == msg.sender, "Caller is not the proposer of target proposal");
        
        _burn(msg.sender, issuedProposals[targetId].proposalID, issuedProposals[targetId].shareAmount);
        issuedProposals[targetId].shareAmount = 0;
    }


}
