# 快速开始指南

## 📋 前置检查

在开始之前，请确���安装了以下工具：

### 1. 检查 Java
```bash
java -version
# 应该显示 Java 21 或更高版本
```

如果没有安装，请从 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) 或 [OpenJDK](https://adoptium.net/) 下载。

### 2. 检查 Maven
```bash
mvn -version
# 应该显示 Maven 3.6 或更高版本
```

如果没有安装：
```bash
# macOS
brew install maven
```

### 3. 检查 Rust
```bash
rustc --version
# 应该显示 Rust 版本
```

如果没有安装：
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 4. 安装 Tauri CLI
```bash
cargo install tauri-cli
```

## 🚀 运行 POC

### 方式 1: 开发模式（推荐用于测试）

```bash
cd /Users/huangxiao/IdeaProjects/experimental/poc-tauri-spring
./dev.sh
```

这会：
1. 自动构建 Spring Boot 后端（如果还没构建）
2. 启动 Tauri 开发模式
3. 打开应用窗口

**预期效果**：
- 应用窗口打开
- 显示"后端状态：运行中 ✓"
- 可以点击按钮测试 API

### 方式 2: 生产打包

```bash
./package.sh
```

这会：
1. 构建 Spring Boot 后端
2. 构建 Tauri 应用
3. 打包成 macOS 安装包

**输出位置**：
- DMG 安装包: `src-tauri/target/release/bundle/dmg/`
- APP 应用: `src-tauri/target/release/bundle/macos/`

## 🧪 测试功能

应用启动后，你会看到一个漂亮的紫色渐变界面。

### 测试步骤：

1. **等待后端就绪**
   - 应用启动时会自动检测后端状态
   - 当显示"运行中 ✓"时，表示后端已就绪

2. **测试 Hello API**
   - 点击"测试 Hello API"按钮
   - 应该看到返回的 JSON 响应

3. **测试系统信息**
   - 点击"获取系统信息"按钮
   - 查看 Java 版本、操作系统等信息

4. **测试 Echo**
   - 在输入框中输入任意文本
   - 点击"发送 Echo 请求"
   - 查看回显响应

5. **验证进程管理**
   - 关闭应用窗口
   - Spring Boot 进程应该自动停止（不会有残留进程）

## 🐛 故障排查

### 问题：应用启动后一直显示"检查中..."

**原因**：Spring Boot 启���时间较长

**解决**：
1. 打开终端，查看是否有错误日志
2. 检查 8080 端口是否被占用：
   ```bash
   lsof -i :8080
   ```
3. 如果端口被占用，停止占用进程或修改后端端口

### 问题：点击按钮没有响应

**原因**：后端未就绪或网络问题

**解决**：
1. 确认后端状态显示为"运行中 ✓"
2. 打开浏览器开发者工���（F12）查看控制台错误
3. 手动访问 http://localhost:8080/actuator/health 确认后端可访问

### 问题：打包失败

**原因**：缺少依赖或构建工具问题

**解决**：
1. 确保所有前置工具已安装
2. 运行验证脚本：
   ```bash
   ./verify.sh
   ```
3. 查看具体错误信息

## 📊 项目结构说明

```
poc-tauri-spring/
├── backend/              # Spring Boot 后端
│   ├── src/
│   │   └── main/
│   │       ├── java/     # Java 源代码
│   │       └── resources/ # 配置文��
│   └── pom.xml           # Maven 配置
│
├── src/                  # 前端静态��件
│   ├── index.html        # 主界面
│   └── app.js            # 前端逻辑
│
├── src-tauri/            # Tauri 配置
│   ├── src/
│   │   └── main.rs       # Rust 主程序
│   ├── Cargo.toml        # Rust 依赖
│   └── tauri.conf.json   # Tauri 配置
│
├── build.sh              # 构建脚本
├── dev.sh                # 开发运行脚本
├── package.sh            # 打包脚本
├── verify.sh             # 验证脚本
└── README.md             # 详细文档
```

## ✅ 成功标志

如果 POC 运行成功，你应该：

- ✅ 双击图标即可启动应用（无需命令行）
- ✅ 看到独立的应用窗口（不是浏览器标签页）
- ✅ 可以通过按钮调用后端 API
- ✅ 关闭窗口时，后端进程自动停止
- ✅ 可以打包成 .dmg 安装包

## 🎉 下一步

POC 成功后，你可以：

1. **迁移真实项目**
   - 将 MyStudio App 的 Spring Boot 后端集成进来
   - 将 Vue 3 前端替换当前的 HTML

2. **添加更多功能**
   - 系统托盘图标
   - 桌面通知
   - 自动更新

3. **优化性能**
   - 使用 jlink 精简 JRE
   - 优化启动速度

## 📞 获取帮助

- 查看 [README.md](README.md) 了解更多细节
- 查看 [Tauri 官方文档](https://tauri.app/)
- 查看 [架构设计文档](../mystudio_app/docs/Tauri-Architecture-Guide.md)

---

祝你成功！🚀
