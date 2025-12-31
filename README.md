# Tauri + Spring Boot POC

这是一个概念验证 (POC) 项目，演示如何将 **Spring Boot** 后端与 **Tauri** 桌面框架集成，实现真正的桌面应用体验。

## 🎯 项目目标

验证以下技术可行性：

- ✅ Tauri 自动启动和管理 Spring Boot 后端进程
- ✅ 前端通过 HTTP 与 Spring Boot 通信
- ✅ 应用关闭时自动停止后端进程
- ✅ 打包成独立的桌面应用（.app/.dmg）

## 📁 项目结构

```
poc-tauri-spring/
├── backend/                    # Spring Boot 后端
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/example/backend/
│   │       │       ├── Application.java
│   │       │       └── controller/
│   │       │           └── ApiController.java
│   │       └── resources/
│   │           └── application.yml
│   └── pom.xml
├── src/                        # 前端静态文件
│   ├── index.html
│   └── app.js
├── src-tauri/                  # Tauri 配置
│   ├── src/
│   │   └── main.rs            # Rust 主程序（启动 Spring Boot）
│   ├── Cargo.toml
│   ├── tauri.conf.json
│   └── icons/
│       └── icon.png
├── build.sh                    # 构建脚本
├── dev.sh                      # 开发运行脚本
├── package.sh                  # 打包脚本
└── README.md
```

## 🛠️ 技术栈

### 后端
- **Spring Boot** 3.3.3
- **Java** 21
- **Spring Web** - REST API
- **Spring Actuator** - 健康检查

### 前端
- **纯 HTML/CSS/JavaScript** - 最简化前端
- **Fetch API** - HTTP 通信

### 桌面框架
- **Tauri** 1.6 - Rust 桌面应用框架
- **系统原生 WebView** - 渲染前端

## 🚀 快速开始

### 前置要求

确保已安装以下工具：

1. **Java 21+**
   ```bash
   java -version
   ```

2. **Maven 3.6+**
   ```bash
   mvn -version
   ```

3. **Node.js 18+** (用于安装 Tauri CLI)
   ```bash
   node -version
   ```

4. **Rust** (用于构建 Tauri)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   rustc --version
   ```

5. **Tauri CLI**
   ```bash
   cargo install tauri-cli
   ```

### 开发模式运行

```bash
# 克隆或进入项目目录
cd /Users/huangxiao/IdeaProjects/experimental/poc-tauri-spring

# 运行开发模式（会自动构建后端并启动应用）
./dev.sh
```

**预期效果**：
- Spring Boot 后端自动启动在 `http://localhost:8080`
- Tauri 窗口打开，显示前端界面
- 前端自动检测后端就绪状态
- 可以测试 API 调用

### 生产构建

```bash
# 构建项目
./build.sh

# 或直接打包成安装包
./package.sh
```

**输出**：
- macOS DMG: `src-tauri/target/release/bundle/dmg/`
- macOS APP: `src-tauri/target/release/bundle/macos/`

## 🧪 功能测试

应用启动后，你可以测试以下功能：

### 1. 后端健康检查
- 应用启动时自动检测后端状态
- 显示"运行中 ✓"表示后端就绪

### 2. API 测试按钮

**Hello API**
```bash
GET http://localhost:8080/api/hello
```
返回欢迎消息和时间戳

**系统信息 API**
```bash
GET http://localhost:8080/api/info
```
返回应用版本、Java 版本、操作系统信息

**Echo API**
```bash
POST http://localhost:8080/api/echo
Content-Type: application/json

{"message": "Hello Tauri!"}
```
返回输入文本的回显

### 3. 进程管理
- ✅ 关闭 Tauri 窗口，Spring Boot 进程自动停止
- ✅ 无需手动清理后端进程

## 🔧 开发细节

### 后端启动机制

Tauri 的 Rust 代码 (`src-tauri/src/main.rs`) 负责启动 Spring Boot：

```rust
// 启动 Spring Boot jar
let child = Command::new("java")
    .arg("-jar")
    .arg(&jar_path)
    .spawn()
    .expect("Failed to start Spring Boot backend");

// 保存进程句柄，以便后续停止
*state.backend_process.lock().unwrap() = Some(child);
```

### 前端健康检查

前端 JavaScript (`src/app.js`) 会循环检测后端就绪：

```javascript
async function checkBackendStatus() {
    const maxRetries = 30;
    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await fetch(`${API_BASE}/actuator/health`);
            if (response.ok) {
                // 后端就绪
                return true;
            }
        } catch {
            await sleep(1000); // 等待 1 秒后重试
        }
    }
}
```

### 资源打包

Tauri 配置 (`src-tauri/tauri.conf.json`) 将 jar 打包到应用内：

```json
{
  "bundle": {
    "resources": ["../../backend/target/src-spring.jar"]
  }
}
```

## 📊 架构图

```
┌──────────────────────────────────────────┐
│         Tauri 桌面应用                    │
│  ┌────────────────────────────────────┐  │
│  │   WebView (前端 UI)                │  │
│  │  ┌──────────────────────────────┐ │  │
│  │  │  HTML + CSS + JavaScript     │ │  │
│  │  └──────────────────────────────┘ │  │
│  │            │ HTTP 请求            │  │
│  │            ▼                      │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  Tauri Core (Rust)                │  │
│  │  - 窗口管理                        │  │
│  │  - 进程管理 (启动/停止 Spring Boot) │  │
│  │  - 系统集成                        │  │
│  └────────────────────────────────────┘  │
│                │                         │
│                ▼                         │
│  ┌────────────────────────────────────┐  │
│  │  Spring Boot 进程                  │  │
│  │  - REST API (localhost:8080)       │  │
│  │  - 业务逻辑                        │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

## ✨ 核心价值验证

### ✅ 已验证

1. **零后端改动** - Spring Boot 代码完全不变
2. **自动进程管理** - Tauri 自动启动和停止 Spring Boot
3. **独立打包** - 打包成标准的 macOS 应用
4. **用户体验** - 双击启动，像普通桌面应用一样

### 📈 后续可扩展

1. **系统托盘** - 添加托盘图标，最小化到托盘
2. **系统通知** - 使用 Tauri 的通知 API
3. **文件对话框** - 使用 Tauri 的原生文件选择器
4. **全局快捷键** - 注册系统级快捷键
5. **自动更新** - 使用 Tauri 的自动更新机制

## 🐛 常见问题

### 1. 启动后显示"后端启动超时"

**原因**：Spring Boot 启动时间超过 30 秒

**解决**：
- 检查是否安装了 Java 21
- 查看控制台日志查找启动错误
- 增加 `app.js` 中的 `maxRetries` 值

### 2. 打包后无法运行

**原因**：jar 文件路径不正确

**解决**：
- 确保先运行 `./build.sh` 构建后端
- 检查 `backend/target/src-spring.jar` 是否存在

### 3. macOS 提示"无法打开应用"

**原因**：macOS 安全限制

**解决**：
```bash
# 右键点击应用 → 选择"打开"
# 或在终端执行：
xattr -cr /path/to/app
```

## 📝 下一步

基于这个 POC，你可以：

1. **迁移实际项目** - 将你的 MyStudio App 迁移到 Tauri
2. **添加更多功能** - 系统托盘、通知、快捷键等
3. **优化性能** - 使用 jlink 精简 JRE，减小安装包
4. **CI/CD 集成** - 自动化构建和发布流程

## 🤝 参考资源

- [Tauri 官方文档](https://tauri.app/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [架构设计文档](../mystudio_app/docs/Tauri-Architecture-Guide.md)

## 📜 许可证

MIT License

---

**Made with ❤️ for POC**
