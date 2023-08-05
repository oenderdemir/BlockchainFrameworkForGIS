pragma solidity ^0.8.0;

import "./Tokens/VatToken.sol";
import "../GIS/Geometry.sol";
import "../GIS/Point.sol";
contract Proposal {
    enum ProposalStatus {OPEN, IN_REVIEW, CLOSED}
    enum ReviewOutcome { PENDING, PROPOSAL_VALID, PROPOSAL_INVALID }

    struct Review {
        address reviewer;
        ReviewOutcome outcome;
        uint256 timestamp;
    }

    struct ProposalStruct {
        string description;
        uint256 categoryId;
        ProposalStatus status;
        Geometry.PointStruct location; 
        string[] comments;
        uint256 upvotes;
        uint256 creationTime;
        uint256 deadline;
        uint256 minimumDonationGoal;
        
        uint256 totalDonation;

        address[] donors;
        mapping(address => uint256) donations;

        Review[3] reviews;
        mapping(address => bool) reviewers;
        uint256  reviewerCounter;
    }
    
    mapping(uint256 => ProposalStruct) public proposals;
  
    uint256 public proposalCounter;
    VatToken public vatToken;

    constructor(address _vatToken) {
        vatToken = VatToken(_vatToken);
        proposalCounter=0;
    }

    function createProposal(
        string memory _description,
        uint256 _categoryId,
        uint256 _deadline,
        uint256 _minimumDonationGoal,
        Geometry.PointStruct memory _location
    ) public payable returns (uint256) {

        
        ProposalStruct storage newProposal = proposals[proposalCounter];
        newProposal.description = _description;
        newProposal.categoryId=_categoryId;
        newProposal.status=ProposalStatus.OPEN;
        newProposal.location = _location;  
        newProposal.comments=new string[](0);
        newProposal.upvotes=0;
        newProposal.creationTime=block.timestamp;
        newProposal.deadline=_deadline;
        newProposal.minimumDonationGoal=_minimumDonationGoal;
        newProposal.totalDonation=0;
        newProposal.donors=new address[](0);

        proposalCounter++;
        return proposalCounter - 1;
    }
    
    function addComment(uint256 proposalId, string memory comment) public {
        require(proposalId >= proposalCounter, "Invalid proposal ID");
        proposals[proposalId].comments.push(comment);
    }
    
    function upvoteProposal(uint256 proposalId) public {
        require(proposalId >= proposalCounter, "Invalid proposal ID");
        proposals[proposalId].upvotes++;
    }
    
    function assignReviewer(uint256 proposalId, address reviewer) public {
        require(proposalId >= proposalCounter, "Invalid proposal ID");
        require(proposals[proposalId].reviewerCounter<3,"Enough reviewers assigned to proposal");
        proposals[proposalId].reviewers[reviewer]=true;
        proposals[proposalId].reviewerCounter++;
    }
    
    function updateProposalStatus(uint256 proposalId, ProposalStatus newStatus) public {
        require(proposalId >= proposalCounter, "Invalid proposal ID");
        proposals[proposalId].status = newStatus;
    }
    
    function isProposalExpired(uint256 proposalId) public view returns (bool) {
        require(proposalId >= proposalCounter, "Invalid proposal ID");
        return (block.timestamp > proposals[proposalId].deadline);
    }

    function donateToProposal(uint256 proposalId, uint256 _amount) public {
        ProposalStruct storage proposal = proposals[proposalId];
        require(_amount >= 1, "Donation should be at least 1 VatToken");
        require(proposal.status == ProposalStatus.OPEN, "Proposal is not open for donations");

        vatToken.transferFrom(msg.sender, address(this), _amount);
        proposal.totalDonation += _amount;
        proposal.donations[msg.sender] += _amount;
        proposal.donors.push(msg.sender);

        if(proposal.totalDonation >= proposal.minimumDonationGoal) {
            proposal.status = ProposalStatus.IN_REVIEW;
        }
    }

    function reviewProposal(uint256 proposalId, ReviewOutcome outcome, Geometry.PointStruct memory reviewerLocation) public {
        ProposalStruct storage proposal = proposals[proposalId];
        require(proposal.reviewers[msg.sender], "Only authorized reviewers can review proposals");
        require(proposal.status == ProposalStatus.IN_REVIEW, "Proposal is not in review status");
        require(Point.distanceBetween2Points(proposal.location, reviewerLocation)<100,"You are not near enough");

        for(uint i=0; i<3; i++) {
            if(proposal.reviews[i].reviewer == address(0)) {
                proposal.reviews[i] = Review({
                    reviewer: msg.sender,
                    outcome: outcome,
                    timestamp: block.timestamp
                });
                break;
            }
        }

        // Reviewer'a belirli bir miktar VatToken gönder
        uint256 rewardAmount = 10; 
        vatToken.transfer(msg.sender, rewardAmount);
    }
}