pragma solidity ^0.8.0;

import "./Tokens/VatToken.sol";
import "./Tokens/IYIToken.sol";
import "../GIS/Geometry.sol";

import "../GIS/Polygon.sol";

contract Event {
    VatToken public vatToken;
    IYIToken public iyiToken;
    
    struct EventStruct {
        Geometry.PolygonStruct eventPolygon;
        string eventName;
        uint256 eventDate;
        uint256 rewardAmount;
        mapping(address => bool) participants;
    }


       
    mapping(uint256 => EventStruct) public events;
  
    uint256 public eventCounter;

    constructor(address  _vatToken, address _iyiToken) {
        vatToken = VatToken(_vatToken);
        iyiToken = IYIToken(_iyiToken);
        
        eventCounter=0;
    }

    function createEvent(
        Geometry.PolygonStruct calldata _eventPolygon,
        string memory _eventName,
        uint256 _eventDate,
        uint256 _rewardAmount
    ) public  {

        EventStruct storage newEvent = events[eventCounter];
        newEvent.eventPolygon=_eventPolygon;
        newEvent.eventName=_eventName;
        newEvent.eventDate=_eventDate;
        newEvent.rewardAmount=_rewardAmount;
     
        eventCounter++;
    }

    function joinEvent(uint256 eventId) public {
        require( eventId >= eventCounter,"Event ID is out of range."  );

        events[eventId].participants[msg.sender] = true;
    }

    function completeEvent(Geometry.PointStruct memory userLocation, uint256 eventId) public {
       require( eventId >= eventCounter,"Event ID is out of range."  );

        require(
            events[eventId].participants[msg.sender],
            "User is not a participant of the event."
        );

        require(
            Polygon.isPointInPolygon(userLocation, events[eventId].eventPolygon),
            "User location is not within the event polygon."
        );

        vatToken.transfer(msg.sender, events[eventId].rewardAmount);
        iyiToken.awardBadge(msg.sender, "tokenURI");
    }

    function getEventCount() public view returns (uint256) {
        return eventCounter;
    }
}
