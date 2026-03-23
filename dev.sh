#!/bin/bash

# Tauri + Spring Boot POC - 开发运行脚本

set -e

echo "🚀 启动 Tauri + Spring Boot POC (开发模式)..."

# 1. 构建 Spring Boot 后端（如果还没有构建）
if [ ! -f "backend/target/src-spring.jar" ]; then
    echo "📦 首次运行，正在构建 Spring Boot 后端..."
    cd backend
    mvn clean package -DskipTests
    cd ..
    echo "✅ Spring Boot 后端构建完成"
fi

# 2. 启动 Tauri 开发模式
echo ""
echo "🔧 启动 Tauri 开发模式..."
echo "   - 后端会自动启动在 http://localhost:8080"
echo "   - 前端会在 Tauri 窗口中打开"
echo ""

cd src-tauri

# 使用全局 tauri-cli (如果已安装)
if command -v cargo-tauri &> /dev/null; then
    cargo tauri dev
else
    echo "未安装 tauri-cli，使用 cargo run..."
    cargo run
fi
