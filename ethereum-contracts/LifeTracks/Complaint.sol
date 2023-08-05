pragma solidity ^0.8.0;

import "./Tokens/VatToken.sol";
import "../GIS/Geometry.sol";
import "../GIS/Point.sol";
contract Complaint {
    enum ComplaintStatus {OPEN, IN_REVIEW, CLOSED}
    enum ReviewOutcome { PENDING, COMPLAINT_VALID, COMPLAINT_INVALID }

    struct Review {
        address reviewer;
        ReviewOutcome outcome;
        uint256 timestamp;
    }
    address public municipalityAddress;
    struct ComplaintStruct {
        string description;
        uint256 categoryId;
        ComplaintStatus status;
        Geometry.PointStruct location;  // Here is the new property for location
        string[] comments;
        uint256 upvotes;
        uint256 creationTime;
        uint256 deadline;
        uint256 minimumDonationGoal;
        //Parayi buraya mi gonderecegiz cok emin olamadim. Bir dusunelim???
        
        uint256 totalDonation;

        address[] donors;
        mapping(address => uint256) donations;

        Review[3] reviews;
        mapping(address => bool) reviewers;
        uint256  reviewerCounter;
        //sikayeti review edenlere ayri bir para gonderilebilir.
        //sikayete para yatirilmasi gerekli
        //sikayet hakli ise sikayet icin para yatiranlara yatirdiklari para oraninda bir odul gonderilerbiir.
        //sikayet haksız ise paralar belediyenin hesabina gecebilir.
    }
    
    mapping(uint256 => ComplaintStruct) public complaints;
  
    uint256 public complaintCounter;
    VatToken public vatToken;

    constructor(address _vatToken) {
        vatToken = VatToken(_vatToken);
        complaintCounter=0;
        municipalityAddress=msg.sender;
    }

    function createComplaint(
        string memory _description,
        uint256 _categoryId,
        uint256 _deadline,
        uint256 _minimumDonationGoal,
        Geometry.PointStruct memory _location
    ) public payable returns (uint256) {

        
        ComplaintStruct storage newComplaint = complaints[complaintCounter];
        newComplaint.description = _description;
        newComplaint.categoryId=_categoryId;
        newComplaint.status=ComplaintStatus.OPEN;
        newComplaint.location = _location;  // setting the location
        newComplaint.comments=new string[](0);
        newComplaint.upvotes=0;
        newComplaint.creationTime=block.timestamp;
        newComplaint.deadline=_deadline;
        newComplaint.minimumDonationGoal=_minimumDonationGoal;
        newComplaint.totalDonation=0;
        newComplaint.donors=new address[](0);

        complaintCounter++;
        return complaintCounter - 1;
    }
    
    function addComment(uint256 complaintId, string memory comment) public {
        require(complaintId >= complaintCounter, "Invalid complaint ID");
        complaints[complaintId].comments.push(comment);
    }
    
    function upvoteComplaint(uint256 complaintId) public {
        require(complaintId >= complaintCounter, "Invalid complaint ID");
        complaints[complaintId].upvotes++;
    }
    
    function assignReviewer(uint256 complaintId, address reviewer) public {
        require(complaintId >= complaintCounter, "Invalid complaint ID");
        require(complaints[complaintId].reviewerCounter<3,"Enough reviewers assigned to complaint");
        complaints[complaintId].reviewers[reviewer]=true;
        complaints[complaintId].reviewerCounter++;
    }
    
    function updateComplaintStatus(uint256 complaintId, ComplaintStatus newStatus) public {
        require(complaintId >= complaintCounter, "Invalid complaint ID");
        complaints[complaintId].status = newStatus;
    }
    
    function isComplaintExpired(uint256 complaintId) public view returns (bool) {
        require(complaintId >= complaintCounter, "Invalid complaint ID");
        return (block.timestamp > complaints[complaintId].deadline);
    }

    function donateToComplaint(uint256 complaintId, uint256 _amount) public {
        ComplaintStruct storage complaint = complaints[complaintId];
        require(_amount >= 1, "Donation should be at least 1 VatToken");
        require(complaint.status == ComplaintStatus.OPEN, "Complaint is not open for donations");

        vatToken.transferFrom(msg.sender, address(this), _amount);
        complaint.totalDonation += _amount;
        complaint.donations[msg.sender] += _amount;
        complaint.donors.push(msg.sender);

        if(complaint.totalDonation >= complaint.minimumDonationGoal) {
            complaint.status = ComplaintStatus.IN_REVIEW;
        }
    }

    function reviewComplaint(uint256 complaintId, ReviewOutcome outcome, Geometry.PointStruct memory reviewerLocation) public {
        ComplaintStruct storage complaint = complaints[complaintId];
        require(complaint.reviewers[msg.sender], "Only authorized reviewers can review complaints");
        require(complaint.status == ComplaintStatus.IN_REVIEW, "Complaint is not in review status");
        require(Point.distanceBetween2Points(complaint.location, reviewerLocation)<100,"You are not near enough");
        for(uint i=0; i<3; i++) {
            if(complaint.reviews[i].reviewer == address(0)) {
                complaint.reviews[i] = Review({
                    reviewer: msg.sender,
                    outcome: outcome,
                    timestamp: block.timestamp
                });
                break;
            }
        }

        uint256 rewardAmount = 10; // reviewer reward
        vatToken.transfer(msg.sender, rewardAmount);
        
        // check if all reviews are done and make a decision
        if(complaint.reviews[2].reviewer != address(0)) { // check if the last review is done
            uint validCounter = 0;
            uint invalidCounter = 0;
            for(uint i=0; i<3; i++) {
                if(complaint.reviews[i].outcome == ReviewOutcome.COMPLAINT_VALID) {
                    validCounter++;
                } else if (complaint.reviews[i].outcome == ReviewOutcome.COMPLAINT_INVALID) {
                    invalidCounter++;
                }
            }

            // if all are COMPLAINT_VALID, refund the donors
            if(validCounter >= 2) {
                for(uint i=0; i<complaint.donors.length; i++) {
                    address donor = complaint.donors[i];
                    uint256 donationAmount = complaint.donations[donor];
                    vatToken.transfer(donor, donationAmount*1.1);
                }
                complaint.status = ComplaintStatus.CLOSED;
            }
            // if all are COMPLAINT_INVALID, transfer the funds to municipality
            else if(invalidCounter == 3) {
                vatToken.transfer(municipalityAddress, complaint.totalDonation);
                complaint.status = ComplaintStatus.CLOSED;
            }
        }
    }
}
