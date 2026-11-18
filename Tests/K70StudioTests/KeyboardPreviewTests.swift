import AppKit
import K70Core
import SwiftUI
import XCTest
@testable import K70Studio

final class KeyboardPreviewTests: XCTestCase {
    @MainActor
    func testKeycapsStayCenteredInsidePreviewWhenResized() async throws {
        let settings = LightingSettings(effect: .solid, baseColor: RGB(255, 0, 0), brightness: 1)
        let sizes = [CGSize(width: 820, height: 310), CGSize(width: 930, height: 245)]

        for size in sizes {
            let preview = KeyboardPreview(settings: settings, selectedKey: nil, onSelect: { _ in })
            let renderer = ImageRenderer(content: preview.frame(width: size.width, height: size.height))
            let image = try XCTUnwrap(renderer.cgImage)
            let bitmap = NSBitmapImageRep(cgImage: image)
            let keyPixels = redBounds(in: bitmap)
            let unit = min((size.width - 56) / KeyboardLayout.width, (size.height - 56) / KeyboardLayout.height)
            let width = unit * KeyboardLayout.width
            let height = unit * KeyboardLayout.height

            XCTAssertEqual(keyPixels.minX, (size.width - width) / 2, accuracy: 6)
            XCTAssertEqual(keyPixels.maxX, (size.width + width) / 2, accuracy: 6)
            XCTAssertEqual(keyPixels.minY, (size.height - height) / 2, accuracy: 6)
            XCTAssertEqual(keyPixels.maxY, (size.height + height) / 2, accuracy: 6)
        }
    }

    private func redBounds(in bitmap: NSBitmapImageRep) -> CGRect {
        var bounds = CGRect.null
        for y in stride(from: 0, to: bitmap.pixelsHigh, by: 2) {
            for x in stride(from: 0, to: bitmap.pixelsWide, by: 2) {
                guard let pixel = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.sRGB),
                      pixel.alphaComponent > 0.9,
                      pixel.redComponent > 0.28,
                      pixel.redComponent > 2 * max(pixel.greenComponent, pixel.blueComponent)
                else { continue }
                bounds = bounds.union(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        return bounds
    }
}
