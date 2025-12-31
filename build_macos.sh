#!/bin/bash

echo "🍎 构建 macOS 安装包..."
echo ""

# 检查操作系统
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: 此脚本只能在 macOS 上运行"
    exit 1
fi

# 选择构建模式
echo "选择构建模式:"
echo "  1) JAR 模式 (需要用户安装 Java)"
echo "  2) Native Image 模式 (推荐,无需 Java)"
echo ""
read -p "请选择 [1/2]: " choice

case $choice in
    1)
        echo ""
        echo "📦 构建 JAR 版本..."
        cd backend
        mvn clean package -DskipTests
        if [ $? -ne 0 ]; then
            echo "❌ JAR 构建失败"
            exit 1
        fi
        cd ..

        # 复制 JAR 到 Tauri 资源目录
        mkdir -p src-tauri/target/release
        cp backend/target/src-spring.jar src-tauri/target/release/

        echo "✅ JAR 构建完成"
        BUILD_TYPE="jar"
        ;;
    2)
        echo ""
        echo "📦 构建 Native Image 版本..."

        # 检查 GraalVM
        if ! command -v native-image &> /dev/null; then
            echo "❌ 错误: 未找到 GraalVM native-image"
            echo "请先运行: sdk use java 21-graal"
            exit 1
        fi

        # 构建 Native Image
        ./build_native.sh
        if [ $? -ne 0 ]; then
            echo "❌ Native Image 构建失败"
            exit 1
        fi

        echo "✅ Native Image 构建完成"
        BUILD_TYPE="native"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "🔨 开始构建 macOS 安装包..."
echo ""

cd src-tauri

# 构建 Tauri 应用
cargo tauri build

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 构建成功!"
    echo ""
    echo "📦 生成的安装包:"
    echo ""

    # 查找生成的文件
    DMG=$(find target/release/bundle/dmg -name "*.dmg" 2>/dev/null | head -1)
    APP=$(find target/release/bundle/macos -name "*.app" 2>/dev/null | head -1)

    if [ -n "$DMG" ]; then
        SIZE=$(du -h "$DMG" | cut -f1)
        echo "  💿 DMG 镜像: $DMG"
        echo "     大小: $SIZE"
        echo ""
    fi

    if [ -n "$APP" ]; then
        SIZE=$(du -sh "$APP" | cut -f1)
        echo "  📱 应用包: $APP"
        echo "     大小: $SIZE"
        echo ""
    fi

    echo "📊 构建信息:"
    echo "  模式: $BUILD_TYPE"
    if [ "$BUILD_TYPE" = "native" ]; then
        echo "  后端: Native Image (无需 Java)"
        BINARY_SIZE=$(du -h ../backend/target/src-spring | cut -f1)
        echo "  二进制大小: $BINARY_SIZE"
    else
        echo "  后端: JAR (需要 Java 21+)"
        JAR_SIZE=$(du -h ../backend/target/src-spring.jar | cut -f1)
        echo "  JAR 大小: $JAR_SIZE"
    fi

    echo ""
    echo "💡 安装说明:"
    if [ -n "$DMG" ]; then
        echo "  1. 双击 DMG 文件"
        echo "  2. 将应用拖到 Applications 文件夹"
        echo "  3. 从启动台�� Applications 启动"
    fi

    if [ "$BUILD_TYPE" = "jar" ]; then
        echo ""
        echo "⚠️  注意: JAR 模式需要用��安装 Java 21 或更高版本"
    else
        echo ""
        echo "✨ Native Image 模式无需用户安装任何依赖!"
    fi

else
    echo ""
    echo "❌ 构建失败"
    exit 1
fi
