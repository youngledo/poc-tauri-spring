# Tauri + Spring Boot POC

> **让 Spring Boot 应用跑在桌面上**
>
> 演示如何将 Spring Boot 后端与 Tauri 桌面框架集成，将 Java 应用打包成真正的原生桌面应用。

---

## 💡 项目意义

许多团队已有成熟的 **Spring Boot** 应用，但想要提供**桌面应用体验**时面临选择：

| 方案 | 优点 | 缺点 |
|------|------|------|
| **Electron + 后端服务** | 技术成熟 | 需要独立部署后端，体积大 (100MB+) |
| **纯前端桌面应用** | 部署简单 | 无法复用现有 Spring Boot 逻辑 |
| **传统 Java Swing/JavaFX** | Java 技术栈 | UI 开发落后，需重写界面 |
| **Tauri + Spring Boot** | **复用代码，原生体验，小体积** | 需要 Rust 构建环境 |

### 核心价值

1. **零代码迁移** - Spring Boot 应用无需修改
2. **自动进程管理** - Tauri 自动启动/停止后端
3. **原生体验** - 系统 Tray、文件对话框、通知等
4. **小体积** - 相比 Electron 节省约 90% 体积

### 适用场景

- 企业内部工具桌面化
- 已有 Spring Boot 应用，需要离线桌面版
- 需要访问本地文件系统或硬件
- 对应用体积敏感的场景

---

## 🎯 项目目标

- ✅ Tauri 自动启动和管理 Spring Boot 进程
- ✅ 前端通过 HTTP 与 Spring Boot 通信
- ✅ 应用关闭时自动停止后端进程
- ✅ 打包成独立桌面应用（.app/.dmg）

## 📁 项目结构

```
poc-tauri-spring/
├── backend/                    # Spring Boot 后端
│   ├── src/main/java/.../
│   │   ├── Application.java
│   │   └── controller/ApiController.java
│   ├── src/main/resources/
│   │   └── application.yml
│   └── pom.xml
├── src/                        # 前端静态文件
│   ├── index.html
│   └── app.js
├── src-tauri/                  # Tauri 配置
│   ├── src/
│   │   └── main.rs
│   ├── Cargo.toml
│   ├── tauri.conf.json
│   └── icons/icon.png
├── build.sh                    # 构建脚本
├── dev.sh                      # 开发运行脚本
└── README.md
```

## 🛠️ 技术栈

| 组件 | 技术 |
|------|------|
| 后端 | Spring Boot 3.3.3 + Java 21 |
| 前端 | 纯 HTML/CSS/JavaScript |
| 桌面 | Tauri 2.x + Rust |

## 🚀 快速开始

### 前置要求

```bash
java -version          # Java 21+
mvn -version           # Maven 3.6+
rustc --version        # Rust 1.70+
cargo install tauri-cli # Tauri CLI
```

### 开发模式

```bash
./dev.sh
```

- Spring Boot 后端自动启动在 `http://localhost:8080`
- Tauri 窗口打开，显示前端界面
- 前端自动检测后端就绪状态

### 生产构建

```bash
./build.sh
```

**输出**：
- macOS DMG: `src-tauri/target/release/bundle/dmg/`
- macOS APP: `src-tauri/target/release/bundle/macos/`

## 🧪 功能测试

应用启动后：

1. **后端健康检查** - 自动检测，显示"运行中 ✓"
2. **API 测试**
   - `GET /api/hello` - 欢迎消息
   - `GET /api/info` - 系统信息
   - `POST /api/echo` - 回显测试
3. **进程管理** - 关闭窗口，后端自动停止

## 🔧 核心实现

### 后端启动 (Rust)

```rust
// src-tauri/src/main.rs
let child = if native_binary.exists() {
    Command::new(&native_binary).spawn()
} else if jar_file.exists() {
    Command::new("java").arg("-jar").arg(&jar_file).spawn()
};
*state.backend_process.lock().unwrap() = Some(child);
```

### 健康检查 (JavaScript)

```javascript
// src/app.js
async function checkBackendStatus() {
    const maxRetries = 30;
    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await fetch(`${API_BASE}/actuator/health`);
            if (response.ok) return true;
        } catch { await sleep(1000); }
    }
}
```

## 📊 架构

```
┌─────────────────────────────────┐
│       Tauri 桌面应用            │
│  ┌─────────────────────────┐    │
│  │   WebView (前端 UI)     │    │
│  │   HTML + CSS + JS       │    │
│  └───────────┬─────────────┘    │
│              │ HTTP             │
│  ┌───────────▼─────────────┐    │
│  │   Tauri Core (Rust)     │    │
│  │   - 进程管理            │    │
│  └───────────┬─────────────┘    │
│              │                  │
│  ┌───────────▼─────────────┐    │
│  │   Spring Boot 进程       │    │
│  │   - REST API            │    │
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

## ✨ 验证结果

- ✅ 零后端改动
- ✅ 自动进程管理
- ✅ 独立打包
- ✅ 用户体验良好

## 🐛 常见问题

**启动后显示"后端启动超时"**
- 检查 Java 21 是否安装
- 查看控制台日志

**打包后无法运行**
- 确保 `backend/target/src-spring.jar` 存在

**macOS 提示"无法打开应用"**
```bash
xattr -cr /path/to/app
```

## 📚 参考资源

- [Tauri 官方文档](https://tauri.app/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)

---

**MIT License**
