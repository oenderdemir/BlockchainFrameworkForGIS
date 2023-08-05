pragma solidity ^0.8.0;
import "./Geometry.sol";
library Point {
  


    function distanceBetween2Points(Geometry.PointStruct memory a, Geometry.PointStruct memory b) public pure returns (uint256) {
       

        return uint256(Geometry.distanceBetweenPoints(a,b));
    }

    function arePointsDistinct(Geometry.PointStruct memory point1, Geometry.PointStruct memory point2) 
    public pure returns (bool) {
        return point1.latitude != point2.latitude || point1.longitude != point2.longitude;
    }

    function isPointOnLine(Geometry.PointStruct memory point, Geometry.LineStruct memory line) public pure returns (bool) {
        return Geometry.isPointOnLine(point, line);
    }

    function isPointAtStartOrEndOfLine(Geometry.PointStruct memory point, Geometry.LineStruct memory line) public pure returns (bool) {
        bool atStart = (point.latitude == line.startPoint.latitude) && (point.longitude == line.startPoint.longitude);
        bool atEnd = (point.latitude == line.endPoint.latitude) && (point.longitude == line.endPoint.longitude);
        return atStart || atEnd;
    }
    // Point ile ilgili fonksiyonlar burada olacaktır.
}