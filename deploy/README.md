# 数据服务部署（方案 B：服务器定时从 Gitee 拉取）

两个容器：`sync`（定时 git pull）+ `web`（Caddy 静态服务 + 自动 HTTPS）。
数据源仍是 git 仓库（GitHub 为主，Gitee 为国内镜像），服务器只做同步与分发。

## 前置

1. 阿里云轻量应用服务器（≥3 个月包年，同时作为 App 备案接入载体）
2. 域名已解析到服务器 IP（如 `holidays.example.com`）
3. Gitee 已导入本仓库（Gitee 仓库页 → 强制同步 即可更新镜像）
4. 服务器安全组放行 80/443

## 部署步骤

```bash
# 1. 安装 Docker（阿里云内网源）
curl -fsSL https://get.docker.com | sh
sudo systemctl enable --now docker

# 2. （国内建议）配置镜像加速：阿里云控制台 → 容器镜像服务 → 镜像加速器，
#    把地址写入 /etc/docker/daemon.json 后 systemctl restart docker

# 3. 拉取本目录并启动
git clone https://gitee.com/yourname/StatusbarCalender.git
cd StatusbarCalender/deploy

# 4. 修改 Caddyfile 里的域名为你的域名
# 5. （可选）覆盖默认仓库地址 / 拉取间隔
#    echo "REPO_URL=https://gitee.com/yourname/StatusbarCalender.git" > .env
#    echo "PULL_INTERVAL=6h" >> .env

docker compose up -d

# 6. 验证
curl https://holidays.example.com/StatusbarCalendar/Resources/holidays.json
```

## 数据更新链路

```
改 holidays.json → git push（GitHub）→ Gitee 仓库页点"强制同步"
  → 服务器 sync 容器 ≤6h 内自动 pull → Caddy 即刻对外提供新数据
  → app 24h 内自动拉取 / 用户手动"检查更新"立即生效
```

## 迁移

新服务器：装 Docker → 拷贝本目录 → `docker compose up -d`。
首次启动自动重新 clone，证书由 Caddy 自动重新申请，无需搬运数据。

## 运维

```bash
docker compose logs -f sync     # 看同步日志（每次成功更新有时间戳）
docker compose exec sync sh     # 进容器排查
docker compose restart sync     # 立即触发一轮拉取前的等待重置
```

## 以后多个 App

仓库根按 app 分目录（本仓库即 `/StatusbarCalendar/Resources/...`），
Caddyfile 加子域名块指向同一 `root`，或复用同一路径前缀，无需新服务器。
