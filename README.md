# Butler
Everyone has a local set of common utilities and extensions they like to use in Swift. Now I do too.

I don't want to pollute the cocoapods repo with my stuff so you can use this as such:

`pod 'Butler', :git => 'git@github.com:nickoneill/Butler.git'`

If you're importing this as a framework, (cocoapods with `use_frameworks!` or carthage), you probably want to use these helpful things all over your app without adding `import Butler` in every file. In that case, make a `defines.swift` file that imports and typealiases Butler so it's accessible everywhere. It doesn't matter what you call the typealias, you don't need to reference it. This import hack brought to you by [@jeffboek](https://twitter.com/jeffboek).

```swift
import Butler 

// this is a workaround to bring the extensions from Butler into
// the rest of the project without having to declare `import Butler` everywhere
typealias Jeeves = Butler
```

