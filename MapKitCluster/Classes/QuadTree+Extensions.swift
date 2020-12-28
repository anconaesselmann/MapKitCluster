//  Created by Axel Ancona Esselmann on 12/28/20.
//

import MapKit
import SwiftQuadTree

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
