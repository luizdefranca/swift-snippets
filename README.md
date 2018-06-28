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
