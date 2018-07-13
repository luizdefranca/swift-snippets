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
let Width = 100
let Height = 200

let mapImageUrl = "https://maps.googleapis.com/maps/api/staticmap?center="
let latlong = "\(lat), \(lon)"

let mapUrl  = mapImageUrl + latlong

let size = "&size=" +  "\(Int(Width))" + "x" +  "\(Int(Height))"
let positionOnMap = "&markers=size:mid|color:red|" + latlong
let staticImageUrl = mapUrl + size + positionOnMap

let url = URL(string: staticImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

do {
    let data = try NSData(contentsOf: url!, options: NSData.ReadingOptions())
    mapImage.image = UIImage(data: data as Data)
} catch {
    mapImage.image = UIImage()
}
```

