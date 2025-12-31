#!/bin/bash

# Native Image 进程管理脚本

PROCESS_NAME="src-spring"

case "$1" in
    "list"|"ls")
        echo "=== Native Image 进程列表 ==="
        echo ""
        ps aux | head -1
        ps aux | grep "$PROCESS_NAME" | grep -v grep
        echo ""
        ;;

    "status")
        PID=$(pgrep -f "$PROCESS_NAME" | head -1)
        if [ -z "$PID" ]; then
            echo "❌ 没有运行中的 $PROCESS_NAME 进程"
            exit 1
        fi

        echo "✅ Native Image 进程运行中"
        echo ""
        echo "进程信息:"
        ps -p $PID -o pid,ppid,%cpu,%mem,rss,vsz,etime,command
        echo ""

        RSS=$(ps -p $PID -o rss= | awk '{print $1/1024}')
        echo "实际内存占用 (RSS): ${RSS} MB"
        echo ""

        echo "监听端口:"
        lsof -iTCP -sTCP:LISTEN -n -P | grep $PID || echo "  无"
        ;;

    "memory"|"mem")
        PID=$(pgrep -f "$PROCESS_NAME" | head -1)
        if [ -z "$PID" ]; then
            echo "❌ 没有运行中的进程"
            exit 1
        fi

        echo "=== 内存使���详情 (PID: $PID) ==="
        echo ""
        ps -p $PID -o pid,rss,vsz,pmem,command | \
        awk 'NR==1 {print $0; next}
             {printf "%s\t%.2f MB (RSS)\t%.2f MB (VSZ)\t%s%%\t%s\n",
              $1, $2/1024, $3/1024, $4, $5}'
        ;;

    "threads")
        PID=$(pgrep -f "$PROCESS_NAME" | head -1)
        if [ -z "$PID" ]; then
            echo "❌ 没有运行中的进程"
            exit 1
        fi

        echo "=== 线程信息 (PID: $PID) ==="
        echo ""
        ps -M -p $PID | head -20
        ;;

    "ports")
        echo "=== 监听端口 ==="
        echo ""
        lsof -iTCP -sTCP:LISTEN -n -P | grep "$PROCESS_NAME" || echo "没有监听端口"
        ;;

    "kill")
        PID=$(pgrep -f "$PROCESS_NAME" | head -1)
        if [ -z "$PID" ]; then
            echo "❌ 没有运行中的进程"
            exit 1
        fi

        echo "🛑 停止进程 PID: $PID"
        kill $PID
        sleep 1

        if pgrep -f "$PROCESS_NAME" > /dev/null; then
            echo "⚠️  进程未响应,强制终止..."
            kill -9 $PID
        fi

        echo "✅ 进程已停止"
        ;;

    "compare")
        echo "=== Native Image vs JVM 对比 ==="
        echo ""

        # 查找Native Image进程
        NATIVE_PID=$(pgrep -f "src-spring" | head -1)
        # 查找JVM进程 (如果有)
        JVM_PID=$(jps -l 2>/dev/null | grep "Application" | awk '{print $1}')

        if [ ! -z "$NATIVE_PID" ]; then
            echo "📦 Native Image 进程:"
            RSS=$(ps -p $NATIVE_PID -o rss= | awk '{printf "%.2f", $1/1024}')
            ETIME=$(ps -p $NATIVE_PID -o etime=)
            echo "   PID: $NATIVE_PID"
            echo "   内存: ${RSS} MB"
            echo "   运行时间: $ETIME"
            echo "   类型: 原生二进制"
        else
            echo "📦 Native Image: 未运行"
        fi

        echo ""

        if [ ! -z "$JVM_PID" ]; then
            echo "☕ JVM 进程:"
            RSS=$(ps -p $JVM_PID -o rss= | awk '{printf "%.2f", $1/1024}')
            ETIME=$(ps -p $JVM_PID -o etime=)
            echo "   PID: $JVM_PID"
            echo "   内存: ${RSS} MB"
            echo "   运行时间: $ETIME"
            echo "   类型: Java虚拟机"
        else
            echo "☕ JVM 进程: 未运行"
        fi

        echo ""
        echo "💡 提示: Native Image 通常比 JVM 节省 60-80% 内存"
        ;;

    "watch")
        echo "=== 实时监控 Native Image 进程 (按 Ctrl+C 退出) ==="
        echo ""
        watch -n 2 "ps aux | grep src-spring | grep -v grep | grep -v watch"
        ;;

    *)
        cat << EOF
Native Image 进程管理工具

用法: $0 <command>

命令:
  list, ls        列出所有 Native Image 进程
  status          显示进程详细状态
  memory, mem     显示内存使用情况
  threads         显示线程信息
  ports           显示监听的端口
  kill            停止进程
  compare         对比 Native Image vs JVM
  watch           实时监控进程

示例:
  $0 status       # 查看进程状态
  $0 memory       # 查看内存占用
  $0 compare      # 对比 Native vs JVM

对比传统 Java 工具:
  jps             →  $0 list
  jcmd <pid> VM.info  →  $0 status
  jstat -gc       →  不适用 (Native Image无GC统计)
  jmap -heap      →  $0 memory

注意: Native Image 是原生进程,���支持 jps、jcmd 等 Java 工具
EOF
        ;;
esac
