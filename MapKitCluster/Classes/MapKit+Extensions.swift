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

    func update<T>(overlays: [T], done: (() -> Void)? = nil) where T: Hashable, T: MKOverlay {
        let before = Set(self.overlays.compactMap({ $0 as? T }))
        let after = Set(overlays)
        let toKeep = before.intersection(after)
        let toAdd = after.subtracting(toKeep)
        let toRemove = before.subtracting(after)

        OperationQueue.main.addOperation() { [weak self] in
            self?.addOverlays(Array<T>(toAdd))
            self?.removeOverlays(Array<T>(toRemove))
            done?()
        }
    }

    var zoomScale: MKZoomScale {
        bounds.size.width / CGFloat(visibleMapRect.size.width)
    }
}
