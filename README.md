# 🛸 node-argo

[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Node.js Version](https://img.shields.io/badge/Node-16%2B-green.svg?style=flat-square)](https://nodejs.org/)
[![Xray-core](https://img.shields.io/badge/Core-Xray-orange.svg?style=flat-square)](https://github.com/XTLS/Xray-core)
[![Cloudflare](https://img.shields.io/badge/Network-Cloudflare_Argo-f38020.svg?style=flat-square)](https://www.cloudflare.com/products/argo-smart-routing/)

**node-argo** is a lightweight, automated proxy solution driven by Node.js. It seamlessly orchestrates **Xray-core** and **Cloudflare Argo Tunnel** to provide a secure, high-speed network bridge that bypasses firewalls without the need for a public IP or open inbound ports.

---

## 💡 The Core Concept

The project acts as a **control plane** written in Node.js to manage the lifecycle of the underlying binaries:

1.  **Binary Management**: Automatically fetches and verifies the correct `xray` and `cloudflared` binaries for your specific OS/Architecture.
2.  **Traffic Tunneling**: Xray handles protocol encapsulation (VLESS/VMess/Trojan), while Cloudflare Argo Tunnel creates a secure outbound-only connection to the Cloudflare Edge.
3.  **NAT Traversal**: Works perfectly behind CGNAT or strict firewalls by utilizing Cloudflare's global network as a reverse proxy.

---

## ✨ Key Features

* **🌍 Public-IP Free**: No need to configure port forwarding or DDNS. If you can reach Cloudflare, you can be reached.
* **🛡️ Stealth & Security**: Your origin server remains hidden. All traffic is masked as standard HTTPS/WSS through Cloudflare's infrastructure.
* **🚀 PaaS Ready**: Optimized for deployment on platforms like Render, Railway, Zeabur, or any containerized environment.
* **🔄 Self-Healing**: Built-in Node.js monitor that automatically restarts the tunnel or core process upon failure.
* **🛠️ Zero Configuration**: Smart defaults allow you to get up and running with just a few environment variables.
