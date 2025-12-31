#!/bin/bash

echo "🚀 构建 Spring Boot Native Image..."
echo ""

# 检查是否安装了 GraalVM
if ! command -v native-image &> /dev/null; then
    echo "❌ 错误: 未找到 GraalVM native-image 工具"
    echo ""
    echo "请按以下步骤安装:"
    echo "1. 安装 GraalVM:"
    echo "   sdk install java 21-graal"
    echo "   sdk use java 21-graal"
    echo ""
    echo "2. 安装 native-image:"
    echo "   gu install native-image"
    echo ""
    exit 1
fi

echo "✓ GraalVM 环境检测正常"
echo ""

# 进入后端目录
cd backend

echo "📦 开始编译 Native Image (这可能需要几分钟)..."
echo ""

# 使用 native profile 构建
mvn -Pnative clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Native Image 构建成功!"
    echo ""
    echo "📊 文件信息:"
    ls -lh target/src-spring
    echo ""

    # 复制到 Tauri 目录
    echo "📋 复制到 Tauri debug 目录..."
    mkdir -p ../src-tauri/target/debug
    cp target/src-spring ../src-tauri/target/debug/src-spring

    echo ""
    echo "🎉 完成! 可以运行 ./dev_native.sh 启动应用"
else
    echo ""
    echo "❌ 构建失败"
    exit 1
fi
