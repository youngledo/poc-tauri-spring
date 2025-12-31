#!/bin/bash

echo "🚀 启动 Tauri + Spring Boot Native Image POC (开发模式)..."
echo ""

# 检查 native binary 是否存在
if [ ! -f "backend/target/src-spring" ]; then
    echo "❌ 未找到 native binary"
    echo "请先运行: ./build_native.sh"
    exit 1
fi

echo "🔧 启动 Tauri 开发模式..."
echo "   - 后端会自动启动在 http://localhost:8080"
echo "   - 前端会在 Tauri 窗口中打开"
echo "   - 使用 Native Image (启动速度极快!)"
echo ""

# 复制 native binary 到 debug 目录
mkdir -p src-tauri/target/debug
cp backend/target/src-spring src-tauri/target/debug/src-spring
chmod +x src-tauri/target/debug/src-spring

cd src-tauri

# 检查是否安装了全局 Tauri CLI
if command -v cargo-tauri &> /dev/null; then
    echo "使用全局 Tauri CLI..."
    cargo tauri dev
else
    echo "使用 cargo run..."
    cargo run
fi
