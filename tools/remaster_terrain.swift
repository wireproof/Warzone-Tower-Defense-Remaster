import AppKit
import Foundation

// Preprocess terrain sprites: retain the original alpha silhouette and shading
// while adding subtle high-resolution stone detail to each 2x tile.
let args = CommandLine.arguments
precondition(args.count == 4, "usage: remaster_terrain.swift input-images texture output")
let input = URL(fileURLWithPath: args[1]), textureURL = URL(fileURLWithPath: args[2]), output = URL(fileURLWithPath: args[3])
let ids = Array(18...24) + Array(28...46) + Array(56...58) + Array(69...76)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
func rgba(_ url: URL, _ w: Int, _ h: Int, zoom: CGFloat = 1) -> [UInt8] {
    guard let image = NSImage(contentsOf: url), let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { fatalError("Cannot load \(url.path)") }
    var pixels = [UInt8](repeating: 0, count: w*h*4)
    pixels.withUnsafeMutableBytes { p in
        let ctx = CGContext(data: p.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.interpolationQuality = .high; let dw = CGFloat(w) * zoom, dh = CGFloat(h) * zoom; ctx.draw(cg, in: CGRect(x: (CGFloat(w)-dw)/2, y: (CGFloat(h)-dh)/2, width: dw, height: dh))
    }
    return pixels
}
let texture = rgba(textureURL, 34, 34, zoom: 4)
let files = try FileManager.default.contentsOfDirectory(at: input, includingPropertiesForKeys: nil)
for id in ids {
    guard let src = files.first(where: { $0.lastPathComponent.hasPrefix("\(id)_") && $0.pathExtension == "png" }) else { fatalError("missing tile \(id)") }
    var px = rgba(src, 34, 34)
    for i in stride(from: 0, to: px.count, by: 4) {
        let alpha = Double(px[i+3])/255.0
        let grain = (Double(texture[i]) - 128.0) * 0.32 * alpha
        for c in 0..<3 { px[i+c] = UInt8(max(0, min(Double(px[i+3]), Double(px[i+c]) + grain))) }
    }
    let data = Data(px) as CFData
    let provider = CGDataProvider(data: data)!
    let cg = CGImage(width: 34, height: 34, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 136, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
    let rep = NSBitmapImageRep(cgImage: cg)
    try rep.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent("\(id).png"))
}
print("Generated \(ids.count) two-times terrain tiles")
