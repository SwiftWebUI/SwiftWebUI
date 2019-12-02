<h2>SwiftWebUI
  <img src="https://zeezide.com/img/TinkerIcon.svg"
       align="right" width="128" height="128" />
</h2>

![Swift5.1](https://img.shields.io/badge/swift-5.1-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![Travis](https://api.travis-ci.org/SwiftWebUI/SwiftWebUI.svg?branch=develop&style=flat)

More details can be found on the related blog post at the
[Always Right Institute](http://www.alwaysrightinstitute.com).

At
[WWDC 2019](https://developer.apple.com/wwdc19/)
Apple announced 
[SwiftUI](https://developer.apple.com/xcode/swiftui/).
A single "cross platform", "declarative" framework used to build 
tvOS, macOS, watchOS and iOS
UIs.
[SwiftWebUI](https://github.com/SwiftWebUI/SwiftWebUI)
is bringing that to the Web ✔️

**Disclaimer**: This is a toy project!
Do not use for production. 
Use it to learn more about SwiftUI and its inner workings.

## SwiftWebUI

So what exactly is 
SwiftWebUI?
It allows you to write SwiftUI 
[Views](https://developer.apple.com/documentation/swiftui/view)
which display in a web browser:

```swift
import SwiftWebUI

struct MainPage: View {
  @State var counter = 0
  
  func countUp() { 
    counter += 1 
  }
  
  var body: some View {
    VStack {
      Text("🥑🍞 #\(counter)")
        .padding(.all)
        .background(.green, cornerRadius: 12)
        .foregroundColor(.white)
        .onTapGesture(self.countUp)
    }
  }
}
```

Results in:

<center><img src="https://zeezide.com/img/AvocadoCounter.gif" align="center" /></center>

Unlike some other efforts this doesn't just render SwiftUI Views
as HTML. 
It also sets up a connection between the browser and the code hosted
in the Swift server, allowing for interaction - 
buttons, pickers, steppers, lists, navigation, you get it all!

In other words: 
[SwiftWebUI](https://github.com/SwiftWebUI/SwiftWebUI)
is an implementation of (many but not all parts of) the SwiftUI API for the browser.

To repeat the
**Disclaimer**: This is a toy project!
Do not use for production. 
Use it to learn more about SwiftUI and its inner workings.


## Requirements

- Swift 5.1

Note Combine requires macOS Catalina. For Linux or lower version macOS, open-source Combine is used. See [Combine Compatible Package](https://github.com/cx-org/CombineX/wiki/Combine-Compatible-Package)

## SwiftWebUI Hello World

To setup a SwiftWebUI project,
create a "macOS tool project" in Xcode 11,
then use the new SwiftPM integration and add
`https://github.com/SwiftWebUI/SwiftWebUI`
as a dependency.

Open the `main.swift` file and replace it's content
with:
```swift
import SwiftWebUI

SwiftWebUI.serve(Text("Holy Cow!"))
```

Compile and run the app in Xcode, open Safari and hit
[`http://localhost:1337/`](http://localhost:1337/):

<center><img src="https://zeezide.com/img/holycow.png" align="center" width="538" /></center>
  

## 🥑🍞 AvocadoToast

A small SwiftWebUI sample  based on the 
[SwiftUI Essentials](https://developer.apple.com/videos/play/wwdc2019/216)
"Avocado Toast App".
Find it over here:
[AvocadoToast](https://github.com/SwiftWebUI/AvocadoToast).

<center><img src="http://zeezide.com/img/AvocadoToast.gif" align="center" width="538" /></center>


## Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like
[feedback](https://twitter.com/ar_institute),
GitHub stars,
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
