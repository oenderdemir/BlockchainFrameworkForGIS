pragma solidity ^0.8.0;


import "./Geometry.sol";

library Line  {


    function isPointOnLine(Geometry.PointStruct memory point, Geometry.LineStruct memory line) public pure returns (bool) {
        uint256 tolerance = 10000; // İzin verilen tolerans değeri (gerektiğinde ayarlayabilirsiniz)

        uint256 totalDistance = Geometry.distanceBetweenPoints(line.startPoint, line.endPoint);
        uint256 distanceToStart = Geometry.distanceBetweenPoints(point, line.startPoint);
        uint256 distanceToEnd = Geometry.distanceBetweenPoints(point, line.endPoint);

        // Toplam mesafeden sapma toleransı kontrolü
        if (totalDistance + tolerance >= distanceToStart + distanceToEnd && totalDistance - tolerance <= distanceToStart + distanceToEnd) {
            return true;
        }

        return false;
    }

    function doLinesIntersect(Geometry.LineStruct memory line1, Geometry.LineStruct memory line2) public pure returns (bool) {
        return Geometry.doSegmentsIntersect(line1, line2);
    }

    function areLineEndsClose(Geometry.LineStruct memory line1, Geometry.LineStruct memory line2, uint256 tolerance) public pure returns (bool) {
        uint256 distance = Geometry.distanceBetweenPoints(line1.endPoint, line2.startPoint);
        return distance <= tolerance;
    }


 

    // Line ile ilgili diğer fonksiyonlar burada olacaktır.
}