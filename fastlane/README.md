fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

ビルドして TestFlight にアップロードする

### ios test

```sh
[bundle exec] fastlane ios test
```

テストを実行する

### ios verify

```sh
[bundle exec] fastlane ios verify
```

App Store Connect 上のビルドの状態を確認する

### ios answer_export_compliance

```sh
[bundle exec] fastlane ios answer_export_compliance
```

輸出コンプライアンスが未回答のビルドに自動で回答する

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
