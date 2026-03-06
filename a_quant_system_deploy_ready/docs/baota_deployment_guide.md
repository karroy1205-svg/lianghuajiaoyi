# A股个人自用量化投研分析系统宝塔面板部署说明
## 一、环境要求
- 服务器：阿里云 2 核 2G 轻量应用服务器（Ubuntu 22.04 LTS）
- 面板：宝塔 Linux 面板 7.9+
- 网络：服务器需开放 80、443、8000、8001 端口
## 二、部署步骤
### 1. 环境初始化
1. 登录宝塔面板，进入「软件商店」，安装以下软件：
    - Python 项目管理器（3.9 + 版本）
    - Nginx
    - PostgreSQL（或 MySQL，需修改数据库配置）
    - Redis
2. 安装 Python 依赖：
    - 打开宝塔面板的「Python 项目管理器」，创建新的 Python 环境（3.9 版本）
    - 进入环境的终端，执行：
        ```bash
        pip install -r requirements.txt
        ```
### 2. 项目部署
1. 上传项目文件：
    - 下载提供的系统压缩包，解压后通过宝塔面板的「文件」功能上传到 /www/wwwroot 目录
    - 重命名项目目录为`a_quant_system_deploy_ready`
2. 配置数据库：
    - 进入宝塔面板的「数据库」，创建新的数据库（如`a_quant_db`）
    - 修改`backend/1_config/settings.py`中的数据库配置：
        ```python
        DATABASE_CONFIG = {
            "url": "postgresql://用户名:密码@localhost:5432/a_quant_db",
            "pool_size": 5,
            "max_overflow": 10,
            "pool_pre_ping": True,
            "pool_recycle": 300
        }
        ```
3. 初始化数据库：
    - 进入项目目录的终端，执行：
        ```bash
        python backend/12_database/init_db.py
        ```
### 3. Nginx 配置
1. 进入宝塔面板的「网站」，添加新网站：
    - 域名：填写你的服务器域名或 IP
    - 根目录：/www/wwwroot/a_quant_system_deploy_ready/frontend
    - 配置反向代理：
        - 代理名称：API 服务
        - 目标 URL：http://127.0.0.1:8000
        - 代理路径：/api/
        - 新增 WebSocket 代理：
            - 目标 URL：http://127.0.0.1:8001
            - 代理路径：/ws/
            - 开启 WebSocket 支持
2. 配置伪静态（适配前端路由）：
    - 在站点配置窗口，点击左侧「伪静态」
    - 将以下规则复制到输入框中（仅保留前端路由规则，API和WebSocket代理已在反向代理中配置，无需重复配置，避免冲突）：
        ```nginx
        location / {
          try_files $uri $uri/ /index.html;
        }
        ```
    - 点击「保存」，规则自动生效
3. 保存配置并重启 Nginx
### 4. 启动服务
1. 启动 API 服务：
    - 进入项目目录的终端，执行：
        ```bash
        nohup python backend/10_api_gateway/main.py > api.log 2>&1 &
        ```
2. 启动 WebSocket 服务：
    - 执行：
        ```bash
        nohup python backend/11_websocket/websocket_server.py > ws.log 2>&1 &
        ```
3. 查看服务状态：
    - 执行`ps aux | grep python`查看服务是否正常运行
### 5. 访问系统
- 访问你的服务器域名或 IP，即可进入系统
- 系统默认提供 Swagger 文档，访问`http://你的域名/api/docs`可查看 API 接口说明
## 三、注意事项
1. 系统严格遵循合规要求，无任何实盘交易功能，所有内容仅供投研参考，不构成投资建议
2. 建议定期备份数据库和项目文件
3. 如遇服务异常，可查看 api.log 和 ws.log 日志文件排查问题
4. 服务器需保持稳定运行，建议开启宝塔面板的监控功能，及时处理异常情况
5. 伪静态配置仅需保留前端路由规则，不要添加API和WebSocket的代理配置，否则会和反向代理的配置冲突，导致Nginx启动失败
