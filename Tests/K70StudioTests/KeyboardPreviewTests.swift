import CoreGraphics
import K70Core
import XCTest
@testable import K70Studio

final class KeyboardPreviewTests: XCTestCase {
    func testKeycapsStayCenteredInsidePreviewWhenResized() {
        let sizes = [CGSize(width: 700, height: 310), CGSize(width: 930, height: 245)]

        for size in sizes {
            let geometry = KeyboardPreviewGeometry(in: size)
            let keyArea = geometry.keyArea
            let stage = CGRect(origin: .zero, size: size)
            let plate = keyArea.insetBy(dx: -KeyboardPreviewGeometry.caseInset, dy: -KeyboardPreviewGeometry.caseInset)
            var coverage = CGRect.null

            XCTAssertTrue(stage.insetBy(dx: 15.99, dy: 15.99).contains(plate))
            for key in KeyboardLayout.brazilian {
                let cap = geometry.keycapFrame(for: key).offsetBy(dx: keyArea.minX, dy: keyArea.minY)
                XCTAssertTrue(keyArea.contains(cap), key.name)
                coverage = coverage.union(cap)
            }

            XCTAssertEqual(coverage.midX, stage.midX, accuracy: 0.1)
            XCTAssertEqual(coverage.midY, stage.midY, accuracy: 0.1)
            XCTAssertEqual(coverage.width, keyArea.width, accuracy: 3)
            XCTAssertEqual(coverage.height, keyArea.height, accuracy: 3)
        }
    }
}
