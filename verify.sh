#!/bin/bash

# 快速验证 POC 项目的完整性

echo "🔍 验证 POC 项目结构..."
echo ""

# 检查必要文件
files=(
    "backend/pom.xml"
    "backend/src/main/java/com/example/backend/Application.java"
    "backend/src/main/java/com/example/backend/controller/ApiController.java"
    "backend/src/main/resources/application.yml"
    "src/index.html"
    "src/app.js"
    "src-tauri/Cargo.toml"
    "src-tauri/src/main.rs"
    "src-tauri/tauri.conf.json"
    "build.sh"
    "dev.sh"
    "package.sh"
    "README.md"
)

all_ok=true

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "��� $file"
    else
        echo "❌ $file (缺失)"
        all_ok=false
    fi
done

echo ""

if $all_ok; then
    echo "🎉 项目结构完整！"
    echo ""
    echo "下一步："
    echo "1. 确保安装了 Java 21, Maven, Rust, Tauri CLI"
    echo "2. 运行 ./dev.sh 启动开发模式"
    echo "3. 或运行 ./package.sh 打包应用"
else
    echo "⚠️  项目结构不完整，请检查缺失的文件"
fi
