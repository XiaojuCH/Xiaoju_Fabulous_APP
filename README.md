<<<<<<< HEAD
# 小居处账单助手 Android 应用

## 功能介绍

这是一个用于自动上传微信/支付宝账单到小居处网站的 Android 应用。

### 主要功能

1. **一键上传**
   - 手动选择账单文件上传
   - 支持 XLSX 和 CSV 格式
   - 自动识别微信/支付宝账单

2. **自动监听**（开发中）
   - 后台监听 Download 文件夹
   - 检测到新账单自动上传
   - 上传成功后通知

3. **上传历史**
   - 查看上传记录
   - 显示上传统计（成功/失败/跳过）

4. **设置**
   - API 密钥管理
   - 自动上传开关
   - 通知设置

---

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **UI**: Material Design 3
- **网络**: http package
- **文件操作**: file_picker, path_provider
- **本地存储**: shared_preferences

---

## 开发计划

### 第一阶段：基础功能（MVP）
- [x] 项目初始化
- [ ] API 密钥设置页面
- [ ] 文件选择和上传功能
- [ ] 上传结果显示

### 第二阶段：自动化
- [ ] 后台文件监听服务
- [ ] 自动上传功能
- [ ] 通知推送

### 第三阶段：完善
- [ ] 上传历史记录
- [ ] 统计图表
- [ ] 设置页面优化

---

## 安装说明

### 开发环境

1. 安装 Flutter SDK
2. 克隆项目
3. 运行 `flutter pub get`
4. 连接 Android 设备或启动模拟器
5. 运行 `flutter run`

### 用户安装

1. 下载 APK 文件
2. 允许安装未知来源应用
3. 安装并打开应用
4. 设置 API 密钥
5. 开始使用

---

## API 接口

应用使用以下 API 接口：

### 账单上传接口

**URL**: `https://www.xiaojuch.com/api/bill-import.php`

**方法**: POST

**请求头**:
```
X-API-Key: 你的API密钥
```

**请求体**:
- `bill_type`: 账单类型（wechat/alipay/auto）
- `bill_file`: 账单文件（multipart/form-data）

**响应示例**:
```json
{
  "success": true,
  "message": "导入完成",
  "data": {
    "total": 50,
    "imported": 45,
    "skipped": 5,
    "errors": []
  }
}
```

---

## 权限说明

应用需要以下权限：

- **存储权限**: 读取 Download 文件夹中的账单文件
- **网络权限**: 上传文件到服务器
- **通知权限**: 显示上传结果通知
- **后台运行权限**: 自动监听文件变化

---

## 常见问题

### Q: 如何获取 API 密钥？
A: 登录小居处网站 → 消费记录页面 → API 密钥管理 → 生成新密钥

### Q: 支持哪些账单格式？
A: 支持微信账单（XLSX）和支付宝账单（CSV）

### Q: 自动上传功能如何工作？
A: 应用会在后台监听 Download 文件夹，检测到新的账单文件时自动上传

### Q: 上传失败怎么办？
A: 检查网络连接、API 密钥是否正确、文件格式是否支持

---

## 更新日志

### v1.0.0 (开发中)
- 初始版本
- 基础上传功能
- API 密钥管理

---

## 开源协议

MIT License

---

## 联系方式

如有问题或建议，请访问：https://www.xiaojuch.com
=======
# Xiaoju_Fabulous_APP
A Fabulous App OWN by Xiaoju
>>>>>>> 780cb17c1d586e93dea53fb1a4f67ffda3dd8839
