# 第一阶段：下载阶段
FROM --platform=$BUILDPLATFORM alpine:latest AS downloader

# 安装必要工具
RUN apk add --no-cache curl jq

# 定义目标架构变量 (由 Docker 自动填充)
ARG TARGETARCH

WORKDIR /downloads

# 下载最新版 cloudflared
RUN case "${TARGETARCH}" in \
        "amd64") ARCH="amd64" ;; \
        "arm64") ARCH="arm64" ;; \
        "arm")   ARCH="arm" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -L -o cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}" && \
    chmod +x cloudflared

# 下载最新版 sing-box
RUN case "${TARGETARCH}" in \
        "amd64") S_ARCH="amd64" ;; \
        "arm64") S_ARCH="arm64" ;; \
        "arm")   S_ARCH="armv7" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | jq -r .tag_name | sed 's/v//') && \
    curl -L "https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/sing-box-${VERSION}-linux-${S_ARCH}.tar.gz" -o sing-box.tar.gz && \
    tar -xzf sing-box.tar.gz --strip-components=1 && \
    mv sing-box /downloads/sing-box && \
    chmod +x /downloads/sing-box

# 第二阶段：最终运行镜像
FROM --platform=$BUILDPLATFORM alpine:latest

# 安装基础运行时依赖 (如 ca-certificates 用于 SSL)
RUN apk add --no-cache ca-certificates tzdata

# 从下载阶段拷贝程序
COPY --from=downloader /downloads/cloudflared /usr/local/bin/cloudflared
COPY --from=downloader /downloads/sing-box /usr/local/bin/sing-box

# 验证安装
RUN cloudflared --version && sing-box version

# 设置工作目录
WORKDIR /etc/sing-box

# 默认启动指令 (你可以根据需求修改)
CMD ["sing-box", "run"]
