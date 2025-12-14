# Android Studio 可视化开发指南

## 🎨 在 Android Studio 中可视化查看和编辑界面

---

## 📋 准备工作

### 1. 打开项目

1. 启动 **Android Studio**
2. 选择 **Open** (或 File → Open)
3. 选择目录：`D:\My_Website\App\android-app`
4. 点击 **OK**
5. 等待项目加载完成（首次打开可能需要几分钟）

### 2. 配置 Flutter 插件

1. File → Settings → Plugins
2. 搜索 "Flutter"
3. 安装 **Flutter** 插件（会自动安装 Dart 插件）
4. 重启 Android Studio

### 3. 配置 Flutter SDK 路径

1. File → Settings → Languages & Frameworks → Flutter
2. 设置 **Flutter SDK path**：`C:\flutter`（你的 Flutter 安装路径）
3. 点击 **Apply** → **OK**

---

## 🖥️ 方法一：使用模拟器实时预览（推荐）

### 1. 创建 Android 模拟器

1. 点击顶部工具栏的 **Device Manager** 图标（手机图标）
2. 或者 Tools → Device Manager
3. 点击 **Create Device**
4. 选择设备型号（推荐 **Pixel 5** 或 **Pixel 6**）
5. 点击 **Next**
6. 选择系统镜像（推荐 **Android 13 (API 33)** 或 **Android 14 (API 34)**）
   - 如果没有下载，点击旁边的 **Download** 下载
7. 点击 **Next** → **Finish**

### 2. 启动模拟器

1. 在 Device Manager 中，点击你创建的模拟器旁边的 ▶️ 按钮
2. 等待模拟器启动（首次启动较慢，约1-2分钟）
3. 模拟器启动后，你会看到一个 Android 手机界面

### 3. 运行应用并实时查看界面

1. 在 Android Studio 顶部工具栏，确保选中了你的模拟器设备
2. 点击绿色的 **▶️ Run** 按钮（或按 `Shift + F10`）
3. 等待应用编译和安装（首次运行需要几分钟）
4. 应用会自动在模拟器中打开，你就能看到完整的界面了！

### 4. 热重载 - 实时修改界面

**这是 Flutter 最强大的功能！**

1. 应用运行后，修改任何 Dart 代码（比如修改文字、颜色、布局）
2. 保存文件（`Ctrl + S`）
3. 点击 Android Studio 底部 Run 窗口的 **⚡ Hot Reload** 按钮
   - 或者在代码编辑器中按 `Ctrl + \`
4. **界面会立即更新，无需重新编译！**（通常只需 1-2 秒）

**示例：**
```dart
// 修改前
Text('小狙的账单助手')

// 修改后
Text('我的账单助手')  // 保存后按热重载，界面立即更新！
```

---

## 📱 方法二：使用真机实时预览

### 1. 连接手机

1. 手机开启 **开发者选项**：
   - 设置 → 关于手机 → 连续点击"版本号"7次
2. 开启 **USB 调试**：
   - 设置 → 开发者选项 → USB 调试（开启）
3. 用 USB 线连接手机到电脑
4. 手机上会弹出"允许 USB 调试"提示，点击 **允许**

### 2. 验证连接

在 Android Studio 底部的 **Terminal** 中运行：
```bash
flutter devices
```

如果看到你的手机设备，说明连接成功！

### 3. 运行到真机

1. 在顶部工具栏选择你的手机设备
2. 点击 **▶️ Run** 按钮
3. 应用会安装到你的手机上并自动打开
4. 修改代码后，同样可以使用 **热重载** 实时更新界面！

---

## 🎨 方法三：查看和编辑 UI 代码

### 1. 打开界面文件

在左侧项目树中，展开：
```
android-app
└── lib
    └── screens
        ├── home_screen.dart      # 首页（上传界面）
        └── settings_screen.dart  # 设置页（API 管理）
```

双击打开任意文件。

### 2. 代码编辑器功能

**Flutter Outline（Flutter 大纲）：**
1. 点击右侧边栏的 **Flutter Outline** 标签
2. 可以看到整个 Widget 树的结构
3. 点击任意 Widget，代码会自动跳转到对应位置
4. 可以直观地看到界面的层级结构

**Widget 预览：**
- 虽然 Flutter 没有像 Android XML 那样的可视化设计器
- 但你可以通过 **热重载** 实时看到修改效果
- 这比传统的可视化设计器更快更灵活！

### 3. 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + Space` | 代码自动补全 |
| `Ctrl + Click` | 跳转到定义 |
| `Alt + Enter` | 快速修复/重构 |
| `Ctrl + Alt + L` | 格式化代码 |
| `Shift + F10` | 运行应用 |
| `Ctrl + \` | 热重载 |
| `Ctrl + Shift + \` | 热重启 |

---

## 🔍 方法四：使用 Flutter Inspector 调试界面

### 1. 启动 Flutter Inspector

1. 运行应用后，点击 Android Studio 右侧边栏的 **Flutter Inspector** 标签
2. 或者 View → Tool Windows → Flutter Inspector

### 2. Flutter Inspector 功能

**Widget 树查看：**
- 可以看到整个应用的 Widget 树结构
- 点击任意 Widget，模拟器中会高亮显示对应的界面元素
- 可以查看每个 Widget 的属性、大小、位置等

**布局调试：**
- 点击 **Toggle Debug Paint** 按钮，可以看到所有 Widget 的边界
- 点击 **Toggle Platform** 切换 Android/iOS 预览
- 点击 **Toggle Performance Overlay** 查看性能信息

**实时修改：**
- 在 Inspector 中选中 Widget
- 可以实时查看和修改属性
- 修改后立即在模拟器中看到效果

---

## 📐 界面文件说明

### 首页 (home_screen.dart)

这是上传账单的主界面，包含：
- 文件选择按钮
- 上传进度显示
- 上传历史记录

**关键代码位置：**
```dart
// 文件选择按钮
ElevatedButton(
  onPressed: _pickFile,
  child: Text('选择文件'),
)

// 上传按钮
ElevatedButton(
  onPressed: _uploadFile,
  child: Text('上传'),
)
```

### 设置页 (settings_screen.dart)

这是 API 密钥管理界面，包含：
- API 密钥输入框
- 保存按钮
- 服务器地址配置

**关键代码位置：**
```dart
// API 密钥输入框
TextField(
  controller: _apiKeyController,
  decoration: InputDecoration(
    labelText: 'API 密钥',
  ),
)
```

---

## 🎯 实战演练：修改界面并实时预览

### 示例 1：修改应用标题

1. 打开 `lib/main.dart`
2. 找到：
```dart
MaterialApp(
  title: 'Flutter Demo',
  ...
)
```
3. 修改为：
```dart
MaterialApp(
  title: '小狙的账单助手',
  ...
)
```
4. 保存并热重载，标题立即更新！

### 示例 2：修改按钮颜色

1. 打开 `lib/screens/home_screen.dart`
2. 找到按钮代码：
```dart
ElevatedButton(
  onPressed: _pickFile,
  child: Text('选择文件'),
)
```
3. 修改为：
```dart
ElevatedButton(
  onPressed: _pickFile,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,  // 修改背景色
    foregroundColor: Colors.white, // 修改文字色
  ),
  child: Text('选择文件'),
)
```
4. 保存并热重载，按钮颜色立即改变！

### 示例 3：修改文字大小

1. 找到任意 Text Widget：
```dart
Text('上传账单')
```
2. 修改为：
```dart
Text(
  '上传账单',
  style: TextStyle(
    fontSize: 24,        // 字体大小
    fontWeight: FontWeight.bold,  // 加粗
    color: Colors.blue,  // 颜色
  ),
)
```
3. 保存并热重载，文字样式立即更新！

---

## 🖼️ 界面预览截图位置

运行应用后，你可以在模拟器中截图：
1. 点击模拟器右侧工具栏的 **📷 Screenshot** 按钮
2. 截图会自动保存到桌面

---

## 🚀 推荐的开发流程

1. **启动模拟器**（只需启动一次）
2. **运行应用**（`Shift + F10`）
3. **修改代码**
4. **保存文件**（`Ctrl + S`）
5. **热重载**（`Ctrl + \`）
6. **立即看到效果！**

**整个过程只需 1-2 秒，比传统 Android 开发快 10 倍以上！**

---

## 💡 提示

### Flutter 的优势

- **热重载**：修改代码后 1-2 秒即可看到效果
- **跨平台**：同一套代码可以运行在 Android 和 iOS
- **声明式 UI**：代码即界面，所见即所得
- **丰富的 Widget**：Material Design 和 Cupertino 风格

### 为什么没有传统的可视化设计器？

Flutter 采用 **代码优先** 的设计理念：
- 代码比拖拽更精确、更灵活
- 热重载让你能立即看到效果
- 代码更容易版本控制和团队协作
- 实际上比可视化设计器更高效！

---

## 🎬 快速开始

```bash
# 1. 打开项目
# Android Studio → Open → D:\My_Website\App\android-app

# 2. 安装依赖
flutter pub get

# 3. 启动模拟器
# Device Manager → 点击 ▶️

# 4. 运行应用
# 点击顶部工具栏的 ▶️ Run 按钮

# 5. 开始开发！
# 修改代码 → 保存 → 热重载 → 看到效果！
```

---

## 📞 需要帮助？

- Flutter 官方文档：https://flutter.dev/docs
- Flutter 中文网：https://flutter.cn
- Flutter Widget 目录：https://flutter.dev/docs/development/ui/widgets

---

**现在就打开 Android Studio，启动模拟器，开始可视化开发吧！** 🎉
