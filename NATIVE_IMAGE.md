# Spring Boot Native Image 使用指南

本项目支持两种后端运行方式:
1. **JAR 方式** (传统方式,需要 JVM)
2. **Native Image 方式** (本地二进制,无需 JVM,推荐)

## 🚀 为什么使用 Native Image?

### 性能对比

| 指标 | JAR 方式 | Native Image 方式 |
|------|---------|------------------|
| 启动时间 | ~2秒 | **~0.05秒** (40倍提速) |
| 内存占用 | ~150MB | **~30MB** (减少80%) |
| 打包大小 | ~25MB jar + 用户需安装JVM | **~60MB** 独立可执行文件 |
| 运行时依赖 | 需要 Java 21+ | **无需任何依赖** |

### 优势
- ✅ **启动速度极快** - 毫秒级启动
- ✅ **内存占用小** - 适合资源受限环境
- ✅ **零依赖部署** - 用户无需安装 Java
- ✅ **更安全** - 静态编译,减少攻击面
- ✅ **更好的用户体验** - Tauri 应用立即可用

## 📋 前置要求

### 1. 安装 GraalVM

使用 SDKMAN 安装(推荐):

```bash
# 安装 SDKMAN (如果还没有)
curl -s "https://get.sdkman.io" | bash

# 安装 GraalVM for Java 21
sdk install java 21-graal

# 设置为当前使用的 Java 版本
sdk use java 21-graal

# 验证安装
java -version
```

应该看到类似输出:
```
java version "21.0.x" 2024-xx-xx
Java(TM) SE Runtime Environment Oracle GraalVM 21.0.x+x.1 (build 21.0.x+x-jvmci-xx.x-bxx)
```

### 2. 安装 native-image 工具

```bash
gu install native-image
```

验证安装:
```bash
native-image --version
```

## 🔨 构建 Native Image

### 方式一: 使用构建脚本(推荐)

```bash
./build_native.sh
```

这个脚本会:
1. 检查 GraalVM 环境
2. 使用 Maven 编译 Native Image
3. 自动复制到 Tauri 目录
4. 显示构建结果和文件大小

构建时间: 首次约 2-3 分钟(后续会更快)

### 方式二: 手动构建

```bash
cd backend
mvn -Pnative clean package -DskipTests
```

生成的 native binary 位于: `backend/target/src-spring`

## 🎯 运行 Native Image 版本

### 开发模式

```bash
./dev_native.sh
```

### 直接运行 native binary

```bash
cd backend/target
./src-spring
```

启动后访问: http://localhost:8080

## 🔄 JAR vs Native Image 对比

### 使用 JAR 版本
```bash
./dev.sh                    # 开发模式
java -jar backend/target/src-spring.jar  # 直接运行
```

### 使用 Native Image 版本
```bash
./dev_native.sh             # 开发模式
./backend/target/src-spring # 直接运行
```

## 📦 Tauri 打包

### 打包 JAR 版本(需要用户安装 Java)
```bash
cd src-tauri
cargo tauri build
```

### 打包 Native Image 版本(推荐,无需 Java)
```bash
# 1. 先构建 native image
./build_native.sh

# 2. 打包
cd src-tauri
cargo tauri build
```

打包后的应用会自动优先使用 Native Image(如果存在),否则回退到 JAR。

## 🎨 Rust 代码自动检测

我们的 Rust 代码会自动检测并选择最佳运行方式:

```rust
let child = if native_binary.exists() {
    // 优先使用 Native Image (无需 JVM)
    Command::new(&native_binary).spawn()
} else if jar_file.exists() {
    // 回退到 JAR (需要 JVM)
    Command::new("java").arg("-jar").arg(&jar_file).spawn()
}
```

## ⚙️ 高级配置

### 调整 Native Image 编译参数

编辑 `backend/pom.xml` 中的 `native` profile:

```xml
<buildArgs>
    <buildArg>--no-fallback</buildArg>
    <buildArg>-H:+ReportExceptionStackTraces</buildArg>
    <!-- 添加更多参数 -->
    <buildArg>-H:+StaticExecutableWithDynamicLibC</buildArg>
    <buildArg>-H:ResourceConfigurationFiles=resource-config.json</buildArg>
</buildArgs>
```

常用参数:
- `--no-fallback` - 禁止回退到 JVM
- `-H:+ReportExceptionStackTraces` - 详细的错误堆栈
- `-O3` - 最高优化级别
- `-H:+StaticExecutableWithDynamicLibC` - 静态链接(Linux)

### 添加反射配置

如果遇到反射相关错误,创建 `backend/src/main/resources/META-INF/native-image/reflect-config.json`:

```json
[
  {
    "name": "com.example.YourClass",
    "methods": [{"name": "<init>", "parameterTypes": [] }]
  }
]
```

## 🐛 故障排除

### 问题 1: native-image 命令未找到
```bash
gu install native-image
```

### 问题 2: 编译时内存不足
增加 Maven 内存:
```bash
export MAVEN_OPTS="-Xmx4g"
mvn -Pnative clean package
```

### 问题 3: 运行时缺少动态库
检查依赖:
```bash
ldd backend/target/src-spring  # Linux
otool -L backend/target/src-spring  # macOS
```

### 问题 4: 反射或资源访问错误
运行 agent 收集配置:
```bash
java -agentlib:native-image-agent=config-output-dir=src/main/resources/META-INF/native-image \
  -jar target/src-spring.jar
```

## 📊 性能测试

### 测试启动时间

JAR 方式:
```bash
time java -jar backend/target/src-spring.jar --server.port=8081
```

Native Image 方式:
```bash
time ./backend/target/src-spring --server.port=8081
```

### 测试内存占用

```bash
# JAR
ps aux | grep "src-spring.jar"

# Native Image
ps aux | grep "src-spring"
```

## 🎯 生产环境推荐

对于 MyStudio App 项目,我们强烈推荐使用 Native Image 方式:

1. **用户体验更好** - 应用启动瞬间完成
2. **部署更简单** - 无需要求用户安装 Java
3. **资源占用更少** - 适合多实例运行
4. **安全性更高** - 静态编译,减少运行时漏洞

唯一的代价是编译时间较长(2-3分钟),但这只在开发构建时发生一次。

## 📚 相关文档

- [Spring Boot Native Image 官方文档](https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html)
- [GraalVM Native Image 参考](https://www.graalvm.org/latest/reference-manual/native-image/)
- [Tauri Sidecar 文档](https://tauri.app/v1/guides/building/sidecar)
