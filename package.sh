#!/bin/bash

# Tauri + Spring Boot POC - 打包脚本

set -e

echo "📦 开始打包 Tauri + Spring Boot POC..."

# 1. 构建 Spring Boot 后端
echo ""
echo "步骤 1/2: 构建 Spring Boot 后端..."
cd backend
mvn clean package -DskipTests
echo "✅ Spring Boot 后端构建完成"

# 2. 打包 Tauri 应用
echo ""
echo "步骤 2/2: 打包 Tauri 应用..."
cd ../src-tauri
cargo tauri build
echo "✅ Tauri 应用打包完成"

echo ""
echo "🎉 打包完成！"
echo ""
echo "安装包位置："
echo "  macOS DMG: src-tauri/target/release/bundle/dmg/"
echo "  macOS APP: src-tauri/target/release/bundle/macos/"
echo ""
