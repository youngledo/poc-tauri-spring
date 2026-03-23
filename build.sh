#!/bin/bash

# Tauri + Spring Boot POC - 构建脚本

set -e

echo "🚀 开始构建 Tauri + Spring Boot POC..."

# 1. 构建 Spring Boot 后端
echo ""
echo "📦 步骤 1/2: 构建 Spring Boot 后端..."
cd backend
mvn clean package -DskipTests
echo "✅ Spring Boot 后端构建完成"

# 2. 构建 Tauri 应用
echo ""
echo "📦 步骤 2/2: 构建 Tauri 应用..."
cd ..
cd src-tauri
cargo build --release
echo "✅ Tauri 应用构建完成"

echo ""
echo "🎉 构建完成！"
echo ""
echo "可执行文件位置："
echo "  macOS: src-tauri/target/release/tauri-spring-poc"
echo ""
