# Xcode 集成指南

本项目**源码完整，但没有 .xcodeproj 文件**。你需要在 Xcode 里新建一个项目，然后把这里的源码导入进去。整个过程约 10-15 分钟。

> 作者选择不把 `.xcodeproj` 提交到 git，因为它包含本地路径和 Team ID，提交后会频繁冲突。

## 前置条件

- macOS 14 (Sonoma) 或更新
- Xcode 15+（App Store 免费下载，约 12GB）
- Apple ID（免费账号即可，不需要付费开发者账号）

## 步骤 1：新建主 App 项目

1. 打开 Xcode → **File → New → Project**
2. 选 **macOS** → **App**，点 Next
3. 填写：
   - **Product Name**: `Sub2APIMonitor`
   - **Team**: 选你的 Apple ID（如果没有登录，Xcode → Settings → Accounts 里加一下）
   - **Organization Identifier**: `com.yanhao`（如果你要改，需要同步修改 `Shared/AppConfig.swift` 中的 `appGroupID` 和 `keychainService`）
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - ❌ 不勾选 Include Tests
4. 保存位置选一个**空目录**（不要选 clone 下来的项目目录本身，Xcode 会在所选目录下再建一层 `Sub2APIMonitor/`）
5. Xcode 打开项目后，先**关掉窗口**（不退出 Xcode），把 Xcode 自动生成的：
   - `Sub2APIMonitorApp.swift`
   - `ContentView.swift`
   
   两个文件在 Finder 里**直接删除**（我们会用仓库里的版本替代）

## 步骤 2：导入本仓库的源码

1. 在 Finder 里打开本仓库目录 `sub2api-mac-widget/`
2. 把下面 3 个目录整个拖进 Xcode 左侧 Project Navigator，**放在 `Sub2APIMonitor` target 下方**：
   - `Shared/`
   - 把 `Sub2APIMonitor/` 目录**内部所有 .swift 文件**拖入（目标文件夹：`Sub2APIMonitor` group）
3. 拖入对话框出现时：
   - ✅ 勾选 **Copy items if needed**
   - **Added folders**: 选 `Create groups`
   - **Add to targets**: 只勾 `Sub2APIMonitor`（Widget target 还没建，下一步再加）

## 步骤 3：添加 Widget Extension target

1. 在 Xcode 左侧点击项目根节点（蓝色图标）→ 顶部 **TARGETS** 下面点 **+** 按钮
2. 选 **macOS** → **Widget Extension** → Next
3. 填写：
   - **Product Name**: `UsageWidget`
   - **Bundle Identifier**: `com.yanhao.sub2api.monitor.UsageWidget`
   - ❌ **Include Live Activity**: 不勾
   - ❌ **Include Configuration Intent**: 不勾（我们用自己的 AppIntent）
4. 点 Finish。Xcode 会弹出"Activate scheme?"，点 **Activate**
5. Xcode 会自动生成一个 `UsageWidget.swift` 样板，把它**直接删除**
6. 从 Finder 把仓库的 `UsageWidget/*.swift` 拖进 Xcode 的 `UsageWidget` group：
   - ✅ Copy items if needed
   - **Add to targets**: 只勾 `UsageWidget`

## 步骤 4：让 Shared 代码被两个 target 都能用

1. 在 Xcode 左侧选中 `Shared/` 下所有 .swift 文件（按住 ⌘ 多选）
2. 右侧 File Inspector（⌥⌘1）→ **Target Membership**
3. **两个都勾上**：`Sub2APIMonitor` 和 `UsageWidget`

## 步骤 5：开启 App Group（共享数据）

对**两个 target**都要做一次：

1. 选中 `Sub2APIMonitor` target → **Signing & Capabilities** tab
2. 点 **+ Capability** → 搜 **App Groups** → 双击添加
3. 在 App Groups 框里点 **+** → 输入：`group.com.yanhao.sub2api.monitor`
4. 右上角的 Team 选你的 Apple ID
5. 对 `UsageWidget` target 重复一遍，使用**完全相同**的 group ID

## 步骤 6：开启 Keychain Sharing（两个 target 共享登录凭据）

对**两个 target**都要做：

1. Signing & Capabilities → **+ Capability** → **Keychain Sharing**
2. 输入：`com.yanhao.sub2api.monitor`

## 步骤 7：替换 entitlements（可选，上面两步做完已等价）

如果你想用仓库里预置的 entitlements 文件：

- `Sub2APIMonitor/Sub2APIMonitor.entitlements`
- `UsageWidget/UsageWidget.entitlements`

在 Build Settings → `Code Signing Entitlements` 里指向这两个文件。

## 步骤 8：Build & Run

1. 顶部 scheme 选 `Sub2APIMonitor`（**不是 UsageWidget**，小组件无法直接运行）
2. ⌘R 运行
3. 首次运行会弹登录界面，填：
   - Server URL: 你的 sub2api 地址，如 `http://your-host:3002`
   - Email / Password
4. 登录成功会看到今日用量卡片，说明 API 打通

## 步骤 9：把小组件放到桌面

1. App 在运行状态下，**右键桌面空白处** → **Edit Widgets**（或点右上角菜单栏时间 → 小组件库）
2. 搜索 "Sub2API Usage"，会看到 3 种尺寸
3. 拖到桌面，选尺寸
4. 回到桌面就能看到数据

## 常见问题

### Q: 小组件显示 "Open app to configure"
A: App Group 没配好或 Bundle ID 对不上。检查两个 target 的 App Groups 是否都是同一个 `group.com.yanhao.sub2api.monitor`。

### Q: 小组件数据不刷新
A: 这是**苹果系统设计**，WidgetKit 由系统调度，大约 15-30 分钟才会自动刷新一次。点小组件上的 🔄 按钮可以立即刷新。

### Q: "Signing for 'Sub2APIMonitor' requires a development team"
A: Signing & Capabilities → Team 下拉里选你的 Apple ID。如果没有，Xcode → Settings → Accounts → + Apple ID。

### Q: 编译报错说 `Formatting` 或 `SharedStore` undefined
A: 步骤 4 漏了，`Shared/` 下的文件需要同时 Target Membership 给两个 target。

### Q: Keychain 报 -34018
A: Keychain Sharing capability 没加，或者两个 target 的 keychain group 不一致。

### Q: 修改了代码，小组件没更新
A: Xcode Product → Clean Build Folder (⇧⌘K)，重新运行主 App。系统会自动让小组件重新加载。

## 开发调试 Tips

- 在 Xcode 预览里可以直接看 widget 效果（每个 widget view 文件底部的 `#Preview`）
- 主 App 打开时会自动每 30 秒刷一次数据（仅限 App 前台）
- 手动调 `WidgetCenter.shared.reloadAllTimelines()` 可以让所有 widget 立即去系统请求 timeline
- 真实刷新频率受系统预算控制，不可绕过

## 项目改名指南

如果你想 fork 后改 Bundle ID，需要同步修改：

1. `Shared/AppConfig.swift` 里的 `appGroupID` 和 `keychainService`
2. 两个 target 的 Bundle Identifier
3. 两个 `.entitlements` 文件里的 App Group ID 和 keychain-access-groups
4. 两个 target 的 Signing & Capabilities 里的 App Groups 和 Keychain Sharing
