# Sub2API Monitor

macOS 桌面小组件，实时查看 [sub2api](https://github.com/Wei-Shaw/sub2api) 的 AI Token 用量。

## 功能

- 🎯 桌面小组件支持 3 种尺寸（small / medium / large）
- 📊 显示今日花费、Token 消耗、请求次数、累计花费
- 🔄 小组件内置刷新按钮，点击立即更新（macOS 14+）
- 🔐 账号密码安全存储在 macOS Keychain，Token 过期自动续期
- ⚙️ 可配置服务器地址，适配任意 sub2api 部署

## 系统要求

- macOS 14 (Sonoma) 或更新 — 桌面小组件需要
- Apple Silicon 或 Intel Mac
- [sub2api](https://github.com/Wei-Shaw/sub2api) 后端服务

## 小组件尺寸

| 尺寸 | 展示内容 |
|---|---|
| **Small (2×2)** | 今日花费 大字 + 请求数 |
| **Medium (4×2)** | 今日花费 / Tokens / 请求数 / 累计 + 刷新按钮 |
| **Large (4×4)** | 全部指标 + 最近 7 天趋势柱状图 + 刷新按钮 |

## 刷新频率说明

⚠️ **WidgetKit 的刷新由苹果系统调度**，无法做到秒级：

- 系统自动刷新：约每 15-30 分钟一次（由系统根据电量、使用习惯决定）
- **手动刷新：点击小组件上的 🔄 按钮立即更新**（这是获取实时数据的最佳方式）
- 主 App 打开时会立即刷新一次并通知小组件

如果需要实时监控，建议保持主 App 在后台运行。

## 快速开始

详见 [`docs/SETUP.md`](docs/SETUP.md)。简要步骤：

1. 安装 Xcode 15+
2. `git clone https://github.com/HaoYan-A/sub2api-mac-widget`
3. Xcode 打开并按 SETUP.md 配置两个 target
4. Build & Run，首次启动配置服务器地址 + 登录
5. 右键桌面 → 编辑小组件 → 搜索 "Sub2API Monitor"

## 项目结构

```
sub2api-mac-widget/
├── Shared/                    # 主 App 和 Widget 共享的代码
│   ├── Models/                # APIResponse, DashboardStats, LoginResponse
│   └── Services/              # APIClient, AuthService, KeychainHelper, SharedStore
├── Sub2APIMonitor/            # 主 App（登录页、设置页、主窗口）
├── UsageWidget/               # Widget Extension（small/medium/large + 刷新按钮）
└── docs/                      # 文档
```

## 技术栈

- Swift 5.9+ / SwiftUI
- WidgetKit + AppIntents（macOS 14 交互式小组件）
- Keychain Services（安全存储登录凭据）
- App Groups（主 App 与 Widget 共享数据）

## License

MIT
