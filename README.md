# JY 应用

## 项目概述

JY是一款现代化的iOS应用，提供流畅的用户体验和丰富的功能。本应用采用SwiftUI和UIKit混合架构，实现了高度可定制的用户界面和交互体验。

## 主要功能

- **抽屉式导航**：通过自定义的DrawerContainerViewController实现流畅的侧边抽屉导航
- **自适应文本输入**：支持自动调整高度的文本输入组件
- **社交功能**：包含关注系统、评论互动和用户资料管理
- **内容浏览**：文章阅读、热门话题和推荐内容
- **多媒体支持**：支持图片、富文本等多种媒体格式

## 技术特点

- **混合架构**：结合SwiftUI和UIKit的优势，实现现代UI和复杂交互
- **响应式设计**：支持各种iOS设备和屏幕尺寸
- **手势控制**：丰富的手势支持，提升用户体验
- **性能优化**：采用多种技术确保应用流畅运行
- **无障碍支持**：支持动态字体大小和其他辅助功能

## 组件库

应用包含多个可复用的自定义组件：

- `DrawerContainerView`：可从侧边滑出的抽屉容器
- `AdaptiveTextView`：自适应高度的文本输入框
- `CustomTabBar`：自定义标签栏
- `InfiniteLoopScrollingView`：无限循环滚动视图

## 开发环境

- Xcode 14.0+
- Swift 5.7+
- iOS 15.0+
- SwiftUI 3.0+

## 项目结构

- **Views**：用户界面组件
- **ViewModels**：视图模型和业务逻辑
- **Services**：网络服务和API交互
- **Components**：可复用UI组件
- **Utils**：工具类和辅助函数

## 贡献指南

欢迎提交问题报告和功能建议。如需贡献代码，请遵循以下步骤：

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 许可证

[MIT License](LICENSE)
