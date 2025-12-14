FROM cirrusci/flutter:stable

WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖
RUN flutter pub get

# 构建 APK
RUN flutter build apk --release

# 输出 APK 位置
CMD ["ls", "-lh", "build/app/outputs/flutter-apk/"]