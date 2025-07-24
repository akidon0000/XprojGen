# XprojGen

XprojGenは、iOSアプリケーション用のXcodeプロジェクトを自動生成するSwift製のコマンドラインツールです。
[XcodeGen](https://github.com/yonaskolb/XcodeGen)と[Stencil](https://github.com/stencilproject/Stencil)を使用して、SwiftUIベースのプロジェクトを瞬時に作成できます。
また、`R.swift`や`SwiftLint`も自動的にプロジェクトに組み込まれます。

## 使用方法

### 基本的な使用方法

```bash
mint run akidon0000/XprojGen {プロダクト名}
```

これにより、以下の構造でプロジェクトが生成されます：

```
MyApp/
├── MyApp.xcodeproj
├── MyApp/
│   ├── MyAppApp.swift
│   └── ContentView.swift
```

### フラット構造での生成

```bash
mint run akidon0000/XprojGen {プロダクト名} --flat
# または
mint run akidon0000/XprojGen {プロダクト名} -f
```

フラット構造では、現在のディレクトリに直接プロジェクトファイルが生成されます：

```
./
├── MyApp.xcodeproj
├── MyApp/
│   ├── MyAppApp.swift
│   └── ContentView.swift
```

### オプション

- `--flat`, `-f`: フラットなディレクトリ構造で生成します
- `--help`, `-h`: ヘルプメッセージを表示します

## 生成されるファイル

### App.swift
メインのアプリケーションエントリーポイント：

```swift
@main
struct {プロダクト名}App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### ContentView.swift
SwiftUIベースのメインビュー：

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! MyApp")
        }
        .padding()
    }
}
```

### プロジェクト設定
- **プラットフォーム**: iOS
- **Swift バージョン**: 6.0
- **Bundle Identifier**: `com.github.akidon0000.makexproj.gen.{プロダクト名}`
- **Info.plist**: 自動生成
- **ビルド設定**: Debug/Release設定を含む

## 開発

## インストール

### クローンしてビルド

```bash
git clone https://github.com/akidon0000/XprojGen.git
cd XprojGen
swift build -c release
```

実行可能ファイルは `.build/release/xprojgen` に作成されます。

### パッケージとして実行

```bash
swift run --package-path /path/to/XprojGen xprojgen {プロダクト名}
```

### ビルド

```bash
swift build
```

### 依存関係

- [apple/swift-argument-parser](https://github.com/apple/swift-argument-parser): コマンドライン引数の解析
- [stencilproject/Stencil](https://github.com/stencilproject/Stencil): テンプレートエンジン
- [yonaskolb/XcodeGen](https://github.com/yonaskolb/XcodeGen): Xcodeプロジェクト生成

## ライセンス

このプロジェクトは[LICENSE](LICENSE)ファイルに記載されたライセンスの下で公開されています。

## 参考リンク

- [mtj0928/SlideGen](https://github.com/mtj0928/SlideGen)
  本プロジェクトのインスピレーション元となったツールです。

## 作者

[akidon0000](https://x.com/akidon0000)
