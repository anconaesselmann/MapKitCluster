//  Created by Axel Ancona Esselmann on 12/27/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import MapKit
import SwiftQuadTree

public extension MKMapRect {
    var boundingBox: BoundingBox {
        let topLeft = origin.coordinate
        let bottomRight = MKMapPoint(x: maxX, y: maxY).coordinate

        let minLat = bottomRight.latitude
        let maxLat = topLeft.latitude

        let minLong = topLeft.longitude
        let maxLong = bottomRight.longitude

        return BoundingBox(x: minLat, y: minLong, xf: maxLat, yf: maxLong)
    }

    init(x: Double, y: Double, size: Double) {
        self.init(x: x, y: y, width: size, height: size)
    }

    init(x: Int, y: Int, size: Double) {
        self.init(x: Double(x), y: Double(y), width: size, height: size)
    }

    init(x: Double, y: Double, zoomScale: MKZoomScale) {
        let scaleFactor = Double(zoomScale) / zoomScale.cellSize
        self.init(
            x: x / scaleFactor,
            y: y / scaleFactor,
            width: 1.0 / scaleFactor,
            height: 1.0 / scaleFactor
        )
    }

    init(x: Int, y: Int, zoomScale: MKZoomScale) {
        self.init(x: Double(x), y: Double(y), zoomScale: zoomScale)
    }
}

public extension MKZoomScale {
    var zoomLevel: Int {
        Int(Swift.max(0.0, Double(Int(log2(MKMapSize.world.width / 256.0))) + floor(log2(Double(self)) + 0.5)))
    }

    var cellSize: Double {
        switch zoomLevel {
            case 13, 14, 15: return 64
            case 16, 17, 18: return 32
            case 19: return 16
            default: return 88
        }
    }
}

public extension BoundingBox {
    static var mapBoundingBox: BoundingBox {
        BoundingBox(x: -90, y: -180, width: 180, height: 360)
    }

    init(x: Double, y: Double, zoomScale: MKZoomScale) {
        self = MKMapRect(x: x, y: y, zoomScale: zoomScale).boundingBox
    }

    init(x: Int, y: Int, zoomScale: MKZoomScale) {
        self.init(x: Double(x), y: Double(y), zoomScale: zoomScale)
    }
}


public extension MKMapView {
    func update<T>(annotations: [T]) where T: Hashable, T: MKAnnotation {
        let before = Set(self.annotations.compactMap({ $0 as? T }))
        let after = Set(annotations)
        let toKeep = before.intersection(after)
        let toAdd = after.subtracting(toKeep)
        let toRemove = before.subtracting(after)

        OperationQueue.main.addOperation() { [weak self] in
            self?.addAnnotations(Array<T>(toAdd))
            self?.removeAnnotations(Array<T>(toRemove))
        }
    }

    var zoomScale: MKZoomScale {
        bounds.size.width / CGFloat(visibleMapRect.size.width)
    }
}

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

public struct Cluster<T> {
    public let coordinate: CLLocationCoordinate2D
    public var elements: [T]

    public var count: Int { elements.count }
}
