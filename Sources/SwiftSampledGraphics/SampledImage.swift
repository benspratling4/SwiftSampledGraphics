import Foundation
import SwiftGraphicsCore

/// a generic wrapper around a single bit-mapped image
/// pixels are laid out left-to-right, top-to-bottom
public class SampledImage {
	
	public var dimensions:(width:Int, height:Int)
	
	public var colorSpace:ColorSpace
	
	public var bytes:[UInt8]
	
	public init(width:Int, height:Int, colorSpace:ColorSpace, bytes:[UInt8]?) {
		self.dimensions = (width, height)
		self.colorSpace = colorSpace
		self.bytes = bytes ?? [UInt8](repeating:0, count:width * height * colorSpace.componentCount * colorSpace.bytesPerComponent)
	}
	///assumes x & y are within the image bounds
	public subscript (x:Int, y:Int)->SampledColor {
		get {
			let bytesPerPixel:Int = colorSpace.bytesPerComponent * colorSpace.componentCount
			let components:[[UInt8]] = (0..<colorSpace.componentCount).map({ (componentIndex)->([UInt8]) in
				let startIndex:Int = (dimensions.width * y + x) * bytesPerPixel + componentIndex * colorSpace.bytesPerComponent
				return [UInt8](bytes[startIndex..<startIndex+colorSpace.bytesPerComponent])
			})
			return SampledColor(components: components)
		}
		set {
			let bytesPerPixel:Int = colorSpace.bytesPerComponent * colorSpace.componentCount
			for componentIndex in 0..<colorSpace.componentCount {
				let startIndex:Int = (dimensions.width * y + x) * bytesPerPixel + componentIndex * colorSpace.bytesPerComponent
				for byteIndex in 0..<colorSpace.bytesPerComponent {
					bytes[startIndex+byteIndex] = newValue.components[componentIndex][byteIndex]
				}
			}
		}
	}
	
	
	public func copyWithColorSpace(_ newColorSpace:ColorSpace)->SampledImage {
		let newImage = SampledImage(width: dimensions.width, height: dimensions.height, colorSpace: newColorSpace, bytes: nil)
		for row in 0..<dimensions.height {
			for column in 0..<dimensions.width {
				let color:Color = colorSpace.toAbstractRGB(self[column, row])
				var newConcreteColor = newColorSpace.fromAbstractRGB(color)
				if newColorSpace.componentCount > newConcreteColor.components.count {
					newConcreteColor.components.append(newColorSpace.black.components[color.components.count])
				}
				newImage[column, row] = newConcreteColor
			}
		}
		return newImage
	}
	
	
	
	//todo: special methods for alpha channel conversions....
	
	//todo: tinting - render with a color, given the alha channel of this image
	
}
