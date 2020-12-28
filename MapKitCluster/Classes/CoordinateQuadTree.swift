//  Created by Axel Ancona Esselmann on 12/28/20.
//

import MapKit
import SwiftQuadTree

public class CoordinateQuadTree<T> {

    private weak var mapView: MKMapView!
    private var root: QuadTreeNode<T>?

    public init(root: QuadTreeNode<T>, mapView: MKMapView) {
        self.root = root
        self.mapView = mapView
    }

    public func clusters(withinMapRect rect: MKMapRect, zoomScale: MKZoomScale) -> [Cluster<T>] {
        guard let root = root else {
            return []
        }
        let scaleFactor = Double(zoomScale) / zoomScale.cellSize

        let minX = Int(floor(rect.minX * scaleFactor))
        let maxX = Int(floor(rect.maxX * scaleFactor))
        let minY = Int(floor(rect.minY * scaleFactor))
        let maxY = Int(floor(rect.maxY * scaleFactor))

        return (minX...maxX).flatMap { x in
            (minY...maxY).map { y in
                let boundingBox = BoundingBox(x: x, y: y, zoomScale: zoomScale)
                let clusterArray = root.queryRange(range: boundingBox)

                let coordinate = CLLocationCoordinate2D(
                    latitude:  clusterArray.reduce(0.0) { $0 + $1.x } / Double(clusterArray.count),
                    longitude: clusterArray.reduce(0.0) { $0 + $1.y } / Double(clusterArray.count)
                )
                return Cluster<T>(coordinate: coordinate, elements: clusterArray.map { $0.data })
            }
        }
    }
}
