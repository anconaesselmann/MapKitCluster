//  Created by Axel Ancona Esselmann on 12/28/20.
//

import MapKit

public struct Cluster<T> {
    public let coordinate: CLLocationCoordinate2D
    public var elements: [T]

    public var count: Int { elements.count }
}
