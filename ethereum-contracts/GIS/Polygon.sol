pragma solidity ^0.8.0;


import "./Geometry.sol";
library Polygon {
  

    /*
Bu fonksiyon, "Ray casting" algoritması kullanarak bir noktanın poligonun içinde olup olmadığını kontrol eder. 
İçerideki for döngüsü, poligonun köşelerini dolaşır ve noktadan geçen yatay bir ışın kullanarak, ışının poligonun 
kenarlarıyla kaç kez kesiştiğini belirler. 
Eğer kesişme sayısı tek ise, nokta poligonun içindedir ve fonksiyon true döndürür. Aksi takdirde, 
nokta poligonun dışındadır ve fonksiyon false döndürür.

    */
    function isPointInPolygon(Geometry.PointStruct memory point, Geometry.PolygonStruct memory polygon) 
    public pure returns (bool) {
        uint256 n = polygon.vertices.length;
        bool inside = false;
        uint256 i = 0;
        for (uint256 j = n - 1; i < n; j = i++) {
            Geometry.PointStruct memory vertexI = polygon.vertices[i];
            Geometry.PointStruct memory vertexJ = polygon.vertices[j];

            if ((vertexI.longitude > point.longitude) != (vertexJ.longitude > point.longitude) &&
                (point.latitude < (vertexJ.latitude - vertexI.latitude) * (point.longitude - vertexI.longitude) / 
                (vertexJ.longitude - vertexI.longitude) + vertexI.latitude)) {
                inside = !inside;
            }
        }

        return inside;
    }

    function containsOnlyOnePoint(Geometry.PolygonStruct memory polygon, Geometry.PointStruct[] memory points) 
    public pure returns (bool) {
        uint256 count = 0;

        for (uint256 i = 0; i < points.length; i++) {
            if (isPointInPolygon(points[i], polygon)) {
                count++;
            }
            // Eğer poligon birden fazla noktayı içeriyorsa, fonksiyon hemen false döner.
            if (count > 1) {
                return false;
            }
        }

        // Eğer poligon yalnızca bir noktayı içeriyorsa, fonksiyon true döner.
        return count == 1;
    }

    // Bu fonksiyon, bir poligonun diğer bir poligon içerisinde olup olmadığını kontrol eder.
    function isPolygonInsidePolygon(Geometry.PolygonStruct memory polygon1, Geometry.PolygonStruct memory polygon2) 
    public pure returns (bool) {
        for (uint256 i = 0; i < polygon1.vertices.length; i++) {
            if (!isPointInPolygon(polygon1.vertices[i], polygon2)) {
                return false;
            }
        }
        return true;
    }

     // Bu fonksiyon, iki poligonun birbirine değip değmediğini kontrol eder.
    function doPolygonsTouch(Geometry.PolygonStruct memory polygon1, Geometry.PolygonStruct memory polygon2) public pure returns (bool) {
        for (uint256 i = 0; i < polygon1.vertices.length; i++) {
            for (uint256 j = 0; j < polygon2.vertices.length; j++) {
                if (Geometry.distanceBetweenPoints(polygon1.vertices[i], polygon2.vertices[j]) == 0) {
                    return true;
                }
            }
        }
        return false;
    }

    // Polygon ile ilgili diğer fonksiyonlar burada olacaktır.
}