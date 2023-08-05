pragma solidity ^0.8.0;



library Geometry {

    struct PointStruct {
        int256 latitude;
        int256 longitude;
    }

    struct LineStruct {
        PointStruct startPoint;
        PointStruct endPoint;
    }

    struct PolygonStruct {
        PointStruct[] vertices;
    }
   
   
    function sqrt(int256 x) public pure returns (int256) {
        require(x >= 0, "Non-negative value required");

        int256 z = (x + 1) / 2;
        int256 y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        return y;
    }

    function distanceBetweenPoints(PointStruct memory a, PointStruct memory b) 
    public pure returns (uint256) {
        int256 dLatitude = b.latitude - a.latitude;
        int256 dLongitude = b.longitude - a.longitude;

        return uint256(sqrt(dLatitude * dLatitude + dLongitude * dLongitude));
    }

    function orientation(PointStruct memory p, PointStruct memory q, PointStruct memory r) 
    public pure returns (int256) {
        int256 val = (q.longitude - p.longitude) * (r.latitude - q.latitude) 
        - (q.latitude - p.latitude) * (r.longitude - q.longitude);
        if(val>0)
        {
            return 1;
        }
        else if(val<0)
        {
            return -1;
        }
        else 
        {
            return 0;
        }       
    }

    function doSegmentsIntersect(LineStruct memory line1, LineStruct memory line2) public pure returns (bool) {
        PointStruct memory p1 = line1.startPoint;
        PointStruct memory q1 = line1.endPoint;
        PointStruct memory p2 = line2.startPoint;
        PointStruct memory q2 = line2.endPoint;

        int256 o1 = orientation(p1, q1, p2);
        int256 o2 = orientation(p1, q1, q2);
        int256 o3 = orientation(p2, q2, p1);
        int256 o4 = orientation(p2, q2, q1);

        if (o1 != o2 && o3 != o4) {
            return true;
        }

        return false;
    }
 function isPointOnLine(Geometry.PointStruct memory point, Geometry.LineStruct memory line) public pure returns (bool) {
        uint256 tolerance = 10000; // İzin verilen tolerans değeri (gerektiğinde ayarlayabilirsiniz)

        uint256 totalDistance = distanceBetweenPoints(line.startPoint, line.endPoint);
        uint256 distanceToStart = distanceBetweenPoints(point, line.startPoint);
        uint256 distanceToEnd = distanceBetweenPoints(point, line.endPoint);

        // Toplam mesafeden sapma toleransı kontrolü
        if (totalDistance + tolerance >= distanceToStart + distanceToEnd && totalDistance - tolerance <= distanceToStart + distanceToEnd) {
            return true;
        }

        return false;
    }


    
}