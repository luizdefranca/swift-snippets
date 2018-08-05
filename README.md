# swift-snippets

###### Print fonts family and names
```swift
for family: String in UIFont.familyNames {
    print("Family: \(String(describing: family))")

    for fontName: String in UIFont.fontNames(forFamilyName: family) {
        print("Name: \(String(describing: fontName))")
    }
}
```

###### Custom UITableViewCell border increases cell border only on specified borders
```swift
// the following code increases cell border only on specified borders
let bottom_border = CALayer()
let bottom_padding = CGFloat(10.0)
bottom_border.borderColor = UIColor.white.cgColor
bottom_border.frame = CGRect(x: 0, y: cell.frame.size.height - bottom_padding, width:  cell.frame.size.width, height: cell.frame.size.height)
bottom_border.borderWidth = bottom_padding

let right_border = CALayer()
let right_padding = CGFloat(15.0)
right_border.borderColor = UIColor.white.cgColor
right_border.frame = CGRect(x: cell.frame.size.width - right_padding, y: 0, width: right_padding, height: cell.frame.size.height)
right_border.borderWidth = right_padding

let left_border = CALayer()
let left_padding = CGFloat(15.0)
left_border.borderColor = UIColor.white.cgColor
left_border.frame = CGRect(x: 0, y: 0, width: left_padding, height: cell.frame.size.height)
left_border.borderWidth = left_padding

let top_border = CALayer()
let top_padding = CGFloat(10.0)
top_border.borderColor = UIColor.white.cgColor
top_border.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: top_padding)
top_border.borderWidth = top_padding


cell.layer.addSublayer(bottom_border)
cell.layer.addSublayer(right_border)
cell.layer.addSublayer(left_border)
cell.layer.addSublayer(top_border)
```

###### Add button to navigation bar
```swift
navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchWithAddresss))
```

###### Convert google map location to image !
```swift
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

let mapUrl = "https://maps.googleapis.com/maps/api/staticmap?center=\(String(describing: favoriteLocation.lat)),\(String(describing: favoriteLocation.lon))&zoom=17&size=400x200"
        
mapImage.image = UIImage(named: "logo-gray")
mapImage.downloadedFrom(link: mapUrl)
```

###### NSError usage
```swift
class Helper {

    static let errorDomain = "com.example.error"
    static let errorFuncKey = "com.example.error.function"
    static let errorFileKey = "com.example.error.file"
    static let errorLineKey = "com.example.error.line"

    static func error(_ message: String, record: Bool = true, function: String = #function, file: String = #file, line: Int = #line) -> NSError {

        let customError = NSError(domain: errorDomain, code: 0, userInfo: [
            NSLocalizedDescriptionKey: message,
            errorFuncKey: function,
            errorFileKey: file,
            errorLineKey: line
        ])

        // if (record) {
        //     customError.record()
        // }

        return customError
    }
}

let error = Helper.error(NSLocalizedString("Unauthorized", comment: "Account not activated"))

extension NSError {

    func record() {
        Crashlytics.sharedInstance().recordError(self)
    }

}

```

###### Realm file path
```swift
Realm.Configuration.defaultConfiguration.fileURL
```

###### Merge two image to one
```swift
func generatePin(avatar: String) -> UIImage {
    let bottomImage = UIImage(named: avatar)
    let frontImage = UIImage (named: "userMarker")
    let size = CGSize(width: 90, height: 90)

    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let areaSize = CGRect(x: 35, y: 13, width: 42, height: 42)
    let frontImageSize = CGRect(x: 14, y: 3, width: 84, height: 84)
    bottomImage!.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha:  1.0)
    frontImage!.draw(in: frontImageSize, blendMode: CGBlendMode.normal, alpha: 1.0)
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return newImage
}

marker.icon = generatePin(avatar: "farid")
```

###### Pulse effect
```swift
//            let m = GMSMarker(position: coordinate)
//
//            //custom marker image
//            let pulseRingImg = UIImageView(frame: CGRect(x: -30, y: -30, width: 32, height: 32))
//            pulseRingImg.image = UIImage(named: "pulse")
//            pulseRingImg.isUserInteractionEnabled = false
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(3.5)
//
//            //transform scale animation
//            var theAnimation: CABasicAnimation?
//            theAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
//            theAnimation?.repeatCount = Float.infinity
//            theAnimation?.autoreverses = false
//            theAnimation?.fromValue = Float(0.0)
//            theAnimation?.toValue = Float(2.0)
//            theAnimation?.isRemovedOnCompletion = false
//
//            pulseRingImg.layer.add(theAnimation!, forKey: "pulse")
//            pulseRingImg.isUserInteractionEnabled = false
//            CATransaction.setCompletionBlock({() -> Void in
//
//                //alpha Animation for the image
//                let animation = CAKeyframeAnimation(keyPath: "opacity")
//                animation.duration = 3.5
//                animation.repeatCount = Float.infinity
//                animation.values = [Float(2.0), Float(0.0)]
//                m.iconView?.layer.add(animation, forKey: "opacity")
//            })
//
//            CATransaction.commit()
//            m.iconView = pulseRingImg
//            m.layer.addSublayer(pulseRingImg.layer)
//            m.map = self.mapView
//            m.isDraggable = true
//            m.groundAnchor = CGPoint(x: 0.5, y: 0.5)
```

###### Border radius
```swift
view.clipsToBounds = true
view.layer.cornerRadius = 30
view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
                           // top right           // bottom right       // bottom left        // top left
```
