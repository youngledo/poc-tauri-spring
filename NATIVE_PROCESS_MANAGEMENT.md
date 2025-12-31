# Native Image 进程管理指南

## 核心区别

使用 Native Image 后,您的 Spring Boot 应用不再是 Java 进程,而是**原生操作系统进程**。

### Java 工具 vs 系统工具对比

| 功能 | Java (JAR) | Native Image |
|------|-----------|--------------|
| **列出进程** | `jps` | `ps aux \| grep src-spring` |
| **进程信息** | `jcmd <pid> VM.info` | `ps -p <pid> -o ...` |
| **查看端口** | `netstat` + jps | `lsof -iTCP -sTCP:LISTEN` |
| **内存分析** | `jstat -gc`, `jmap` | `ps -o rss,vsz` |
| **线程信息** | `jstack` | `ps -M -p <pid>` |
| **停止进程** | `kill` (都一样) | `kill` |
| **GC 统计** | `jstat -gcutil` | ❌ 不适用 (无GC) |
| **堆转储** | `jmap -dump` | ❌ 不适用 |
| **JMX 监控** | JConsole, VisualVM | ❌ 不可用 |

## 实际运行数据

当前 POC 项目的 Native Image 进程:

```
PID: 3139
内存占用: 43.95 MB (RSS)
运行时间: 3分钟+
监听端口: 8080
启动时间: 0.073秒
```

## 使用管理脚本

我们提供了 `manage_native.sh` 脚本来简化管理:

### 查看进程状态
```bash
./manage_native.sh status
```

输出:
```
✅ Native Image 进程运行中

进程信息:
  PID  PPID  %CPU %MEM    RSS      VSZ ELAPSED COMMAND
 3139  3042   0.0  0.3  45008 468979904   03:22 /path/to/src-spring

实际内存占用 (RSS): 43.95 MB

监听端口:
src-spring  3139 huangxiao   10u  IPv6 ... TCP *:8080 (LISTEN)
```

### 查看内存使用
```bash
./manage_native.sh memory
```

### 列出所有进程
```bash
./manage_native.sh list
```

### 对比 Native vs JVM
```bash
./manage_native.sh compare
```

### 实时监控
```bash
./manage_native.sh watch
```

### 停止进程
```bash
./manage_native.sh kill
```

## 手动命令参考

### 1. 查找进程

#### 使用 ps
```bash
ps aux | grep src-spring
```

#### 使用 pgrep
```bash
pgrep -fl src-spring
```

#### 按端口查找
```bash
lsof -iTCP:8080 -sTCP:LISTEN
```

### 2. 查看进程详情

```bash
# 基本信息
ps -p <PID> -o pid,ppid,%cpu,%mem,rss,vsz,etime,command

# 内存详情
ps -p <PID> -o pid,rss,vsz,pmem

# 线程信息 (macOS)
ps -M -p <PID>

# 线程信息 (Linux)
ps -T -p <PID>
```

### 3. 监控实时资源

```bash
# 实时 CPU 和内存
top -pid <PID>

# 持续监控
watch -n 2 "ps -p <PID> -o %cpu,%mem,rss,vsz,command"
```

### 4. 查看网络连接

```bash
# 监听的端口
lsof -iTCP -sTCP:LISTEN -n -P | grep <PID>

# 所有网络连接
lsof -i -n -P | grep <PID>

# netstat ��式
netstat -anp | grep <PID>
```

### 5. 停止进程

```bash
# 温和停止 (SIGTERM)
kill <PID>

# 强制停止 (SIGKILL)
kill -9 <PID>

# 按名称停止
pkill src-spring

# 按端口停止
lsof -ti:8080 | xargs kill
```

## 不可用的 Java 工具

以下 Java 工具**不能**用于 Native Image:

### ❌ jps
```bash
# 不会显示 Native Image 进程
jps -l
```

Native Image 不是 Java 进程,jps 找不到它。

**替代方案:**
```bash
ps aux | grep src-spring
pgrep -fl src-spring
./manage_native.sh list
```

### ❌ jcmd
```bash
# 无法连接到 Native Image
jcmd <PID> VM.info
```

Native Image 没有 JVM,无法接受 jcmd 命令。

**替代方案:**
```bash
ps -p <PID> -o pid,ppid,%cpu,%mem,rss,vsz,etime
./manage_native.sh status
```

### ❌ jstat
```bash
# Native Image 没有 GC 统计
jstat -gc <PID>
jstat -gcutil <PID>
```

Native Image 使用不同的 GC (Serial GC),不支持 jstat。

**替代方案:**
- 查看内存: `ps -p <PID> -o rss,vsz`
- 监控: Spring Boot Actuator 的 `/actuator/metrics/jvm.memory.*`

### ❌ jmap
```bash
# 无法生成堆转储
jmap -dump:format=b,file=heap.hprof <PID>
jmap -heap <PID>
```

**替代方案:**
- ���建时添加: `-H:+AllowVMInspection`
- 使用 GraalVM 的 native-image-inspect 工具

### ❌ jstack
```bash
# 无法获取线程转储
jstack <PID>
```

**替代方案:**
```bash
# Linux
kill -3 <PID>  # 发送 SIGQUIT
cat /proc/<PID>/stack

# macOS
lldb -p <PID> -o "thread backtrace all" -o "quit"
```

### ❌ JConsole / VisualVM
这些图形化 JMX 工具无法连接到 Native Image。

**替代方案:**
- Spring Boot Actuator HTTP 端点
- Prometheus + Grafana 监控
- 系统工具: `top`, `htop`, `Activity Monitor`

## 监控和诊断

### 使用 Spring Boot Actuator

Native Image 完全支持 Actuator 端点:

```bash
# 健康检查
curl http://localhost:8080/actuator/health

# 内存指标
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# 线程信息
curl http://localhost:8080/actuator/metrics/jvm.threads.live

# HTTP 统计
curl http://localhost:8080/actuator/metrics/http.server.requests
```

### 系统级监控

```bash
# 资源使用
top -pid <PID>

# I/O 统计
iostat 1

# 网络连接
lsof -i -n -P | grep <PID>

# 文件描述符
lsof -p <PID> | wc -l
```

### 性能分析

#### Linux: perf
```bash
# CPU 分析
perf record -p <PID> -g -- sleep 10
perf report

# 系统调用
strace -p <PID>
```

#### macOS: Instruments
```bash
# 时间分析
instruments -t "Time Profiler" -p <PID>

# 内存分析
instruments -t "Allocations" -p <PID>
```

## 实际对比示例

### JAR 方式
```bash
$ jps -l
12345 com.example.Application

$ jcmd 12345 VM.info
12345:
java.vm.version: 25.0.1+12-LTS
java.vm.name: OpenJDK 64-Bit Server VM
java.vm.info: mixed mode

$ ps -p 12345 -o rss
  RSS
151840  # ~148 MB
```

### Native Image 方式
```bash
$ jps -l
# (空 - 找不到进程)

$ ps aux | grep src-spring
user  3139  0.0  0.3  45008  src-spring

$ ps -p 3139 -o rss
  RSS
45008   # ~44 MB (节省70%内存!)
```

## 调试 Native Image

### 启用调试符号

编译时添加调试信息:

```xml
<buildArgs>
    <buildArg>-H:+SourceLevelDebug</buildArg>
    <buildArg>-g</buildArg>
</buildArgs>
```

### 使用 GDB/LLDB 调试

```bash
# Linux
gdb -p <PID>

# macOS
lldb -p <PID>
```

### 启用 JFR (Java Flight Recorder)

```xml
<buildArgs>
    <buildArg>--enable-monitoring=jfr</buildArg>
</buildArgs>
```

运行时:
```bash
./src-spring -XX:StartFlightRecording=filename=recording.jfr
```

## 最佳实践

### 1. 监控策略

- ✅ 使用 Spring Boot Actuator 端点
- ✅ 集成 Prometheus + Grafana
- ✅ 使用系统监控工具 (top, htop)
- ❌ 不要依赖 JMX 监控

### 2. 问题诊断

- ✅ 检查应用日志
- ✅ 使用 Actuator 的 health 和 metrics
- ✅ 系统工具: strace, lsof, netstat
- ❌ 不要尝试使用 jcmd, jstack

### 3. 性能分析

- ✅ 使用原生分析器: perf (Linux), Instruments (macOS)
- ✅ 应用层指标: Micrometer + Actuator
- ✅ 启用 JFR 支持
- ❌ Java Profilers 不可用

### 4. 进程管理

- ✅ 使用我们的 `manage_native.sh` 脚本
- ✅ 标准信号: SIGTERM, SIGKILL
- ✅ 优雅关闭通过 Actuator: `/actuator/shutdown`
- ✅ 进程监控用 systemd/launchd

## 总结

| 方面 | JAR | Native Image |
|------|-----|--------------|
| **进程类型** | Java 进程 | 原生进程 |
| **工具生态** | jps, jcmd, jstat | ps, top, lsof |
| **内存占用** | ~150MB | ~44MB (70%↓) |
| **启动时间** | ~2秒 | ~0.07秒 (97%↓) |
| **监控** | JMX + Actuator | Actuator only |
| **调试** | Java debugger | GDB/LLDB |
| **分析** | Java Profilers | 原生 Profilers |

**核心理念**: Native Image 让 Java 应用表现得像 C/Go 应用,使用相同的系统工具进行管理。

## 快速参考卡片

```bash
# 进程管理快捷命令
alias native-ps='ps aux | grep src-spring'
alias native-status='./manage_native.sh status'
alias native-kill='./manage_native.sh kill'

# 替换 Java 工具
jps         →  ps aux | grep src-spring
jcmd        →  ./manage_native.sh status
jstat -gc   →  ./manage_native.sh memory
jmap        →  不可用
jstack      →  ps -M (macOS) / ps -T (Linux)
```
