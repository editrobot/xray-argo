# 第一阶段：下载阶段
FROM --platform=$BUILDPLATFORM alpine:latest AS downloader

# 安装必要工具
RUN apk add --no-cache curl jq unzip

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

# 下载最新版 xray
RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  ARCH="64" ;; \
        "linux/arm64")  ARCH="arm64-v8a" ;; \
        "linux/arm/v7") ARCH="arm32-v7a" ;; \
        "linux/s390x")  ARCH="s390x" ;; \
        *) ARCH="64" ;; \
    esac && \
    VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | jq -r .tag_name | sed 's/v//') && \
    curl -L "https://github.com/XTLS/Xray-core/releases/download/v${VERSION}/Xray-linux-${ARCH}.zip" -o xray.zip && \
    mkdir -p tmp/xray && \
    unzip xray.zip -d tmp/xray
    
# 第二阶段：最终运行镜像
FROM --platform=$BUILDPLATFORM alpine:latest

# 安装基础运行时依赖 (如 ca-certificates 用于 SSL)
RUN apk add --no-cache ca-certificates tzdata bash

# 从下载阶段拷贝程序
COPY --from=downloader /downloads/cloudflared /usr/local/bin/cloudflared
COPY --from=downloader /downloads/tmp/xray/xray /usr/local/bin/xray
COPY --from=downloader /downloads/tmp/xray/*.dat /usr/local/share/xray/
RUN chmod +x /usr/local/bin/xray


# 设置工作目录
WORKDIR /etc/xray-argo
ENV TZ=Asia/Shanghai
COPY entrypoint.sh /etc/xray-argo
RUN chmod +x /etc/xray-argo/entrypoint.sh
ENTRYPOINT [ "/etc/xray-argo/entrypoint.sh" ]
