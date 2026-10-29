# 独立镜像与安装

Linux 主脚本：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/KUAILESHANGWEI/argosbx/main/argosbx.sh)
```

SAP 安装入口见 [SAP.md](SAP.md)。运行前请检查脚本及上游 GPL-3.0 许可证，并使用受控环境验证；安装可能修改系统、网络配置及服务。

项目的内核文件使用 `argosbx` Release；cloudflared、Cloud Foundry CLI、规则集及证书辅助脚本使用 `dependencies` Release。`Mirror release assets` 工作流每天和手动运行，抓取上游最新 Release 的资产以及运行依赖；同步需要上游可用，已有副本在上游不可用时仍可使用。运行时仍需系统包仓库、网络服务、SAP 或 Cloudflare 等外部服务，无法仅靠仓库保证这些服务可用。
