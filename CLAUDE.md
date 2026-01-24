# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

SwiftUIでUITextViewを扱うチャットUIサンプルアプリ。Foundation Modelsによる応答機能を持つ。

## 技術スタック

- 言語: Swift 6.2
- IDE: Xcode 26.x
- UIフレームワーク: UIKit、SwiftUI
- 対応プラットフォーム: iOS, macOS, visionOS

## ビルドコマンド

```bash
# シミュレータ向けビルド
xcodebuild -project TextViewSample.xcodeproj -scheme TextViewSample -destination 'platform=iOS Simulator,name=iPhone 16' build

# macOS向けビルド
xcodebuild -project TextViewSample.xcodeproj -scheme TextViewSample -destination 'platform=macOS' build
```

## アーキテクチャ

Model-View (MV) アーキテクチャを採用。

### View
- UIの表示とプレゼンテーションロジックの制御
- RepositoryはEnvironmentによりDIして依存

### Model
- ドメインロジックを持つ
- UIやプロセス外依存には一切依存しない
- Model内の定義にのみ依存

### Repository
- プロセス外依存の処理を提供
- protocolではなくstructとして定義
- APIはstructのクロージャプロパティとして定義
- 原則として特定のActorに依存しない（例外: 内部APIがMainActor依存の場合）
