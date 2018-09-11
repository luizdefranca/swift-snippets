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

###### Socket IO
```swift
let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:3000")!, config: [.log(false), .compress])
    
var socket: SocketIOClient! = nil


override func viewDidLoad() {
    super.viewDidLoad()

    self.socket = manager.defaultSocket

    socket.on(clientEvent: .connect) {data, ack in
        print("connected")
    }

    socket.on(clientEvent: .disconnect) {data, ack in
        print("WebSocket connection closed.")
    }

    socket.connect()

    socket.on("chat message") {data, ack in
        if let value = data.first as? String {
            print(value)
        }
    }

}

// js
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = process.env.PORT || 3000;

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  socket.on('chat message', function(msg){
    io.emit('chat message', msg);
  });
});

http.listen(port, function(){
  console.log('listening on *:' + port);
});

// html
<!doctype html>
<html>
  <head>
    <title>Socket.IO chat</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body { font: 13px Helvetica, Arial; }
      form { background: #000; padding: 3px; position: fixed; bottom: 0; width: 100%; }
      form input { border: 0; padding: 10px; width: 90%; margin-right: .5%; }
      form button { width: 9%; background: rgb(130, 224, 255); border: none; padding: 10px; }
      #messages { list-style-type: none; margin: 0; padding: 0; }
      #messages li { padding: 5px 10px; }
      #messages li:nth-child(odd) { background: #eee; }
      #messages { margin-bottom: 40px }
    </style>
  </head>
  <body>
    <ul id="messages"></ul>
    <form action="">
      <input id="m" autocomplete="off" /><button>Send</button>
    </form>
    <script src="/socket.io/socket.io.js"></script>
    <script src="https://code.jquery.com/jquery-1.11.1.js"></script>
    <script>
      $(function () {
        var socket = io();
        
        
      });
    </script>
  </body>
</html>
```

###### Hexagon ImageView
```swift
let notificationContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    view.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
    view.alpha = 0.9
    setupHexagonImageView(view: view)

    return view
}()

internal static func setupHexagonImageView(view: UIView) {
    let lineWidth: CGFloat = 0
    let path = Helper.roundedPolygonPath(rect: view.bounds, lineWidth: lineWidth, sides: 6, cornerRadius: 10, rotationOffset: CGFloat(Double.pi / 2.0))

    let mask = CAShapeLayer()
    mask.path = path.cgPath
    mask.lineWidth = lineWidth
    mask.strokeColor = UIColor.clear.cgColor
    mask.fillColor = UIColor.white.cgColor
    view.layer.mask = mask

    let border = CAShapeLayer()
    border.path = path.cgPath
    border.lineWidth = lineWidth
    border.strokeColor = UIColor.white.cgColor
    border.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(border)
}

internal static func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0)
        -> UIBezierPath {
            let path = UIBezierPath()
            let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides) // How much to turn at every corner
            let offset: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
            let width = min(rect.size.width, rect.size.height)        // Width of the square
            
            let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
            
            // Radius of the circle that encircles the polygon
            // Notice that the radius is adjusted for the corners, that way the largest outer
            // dimension of the resulting shape is always exactly the width - linewidth
            let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
            
            // Start drawing at a point, which by default is at the right hand edge
            // but can be offset
            var angle = CGFloat(rotationOffset)
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
            
            for _ in 0 ..< sides {
                angle += theta
                
                let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
                let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
                let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
                
                path.addLine(to: start)
                path.addQuadCurve(to: end, controlPoint: tip)
            }
            
            path.close()
            
            // Move the path to the correct origins
            let bounds = path.bounds
            let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0,
                                              y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
            path.apply(transform)
            
            return path
    }
```

###### Print json data
```swift
let string = String(data: jsonData, encoding: String.Encoding.utf8) ?? "Data could not be printed"
print(string)
```

###### Iran phone mask
```swift
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let separator = "-"
    let filler = "#"
    if var number = textField.text, string != "" {
        number = number.replacingOccurrences(of: separator, with: "")
        number = number.replacingOccurrences(of: filler, with: "")
        if number.count == 10 { return false }
        number += string
        while number.count < 10 { number += "#" }
        number.insert("-", at: number.index(number.startIndex,
                                            offsetBy: 6))
        number.insert("-", at: number.index(number.startIndex,
                                            offsetBy: 3))
        textField.text = number.convertToPersian()
    }
    return false
}

```
