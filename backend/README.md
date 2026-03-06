# A股个人自用量化投研分析系统 V5.1
## 合规声明
本系统永久无任何实盘交易执行、委托下单、自动交易功能，所有内容均为量化投研理论研究与辅助参考，不构成任何投资建议，历史表现不代表未来收益，证券投资有风险，实盘决策需用户自主负责。本系统仅限个人自用，严禁对外提供服务、商用运营、二次分发。

## 项目介绍
本系统是针对A股个人自用的量化投研分析系统，适配阿里云2核2G轻量应用服务器+宝塔Linux面板环境，采用全开源免费技术栈，实现了从数据采集、因子计算、策略引擎、风控体系、前端可视化的全链路闭环，解决回测与实盘收益偏差、资金效率低、策略失效回撤、交易纪律缺失四大核心痛点。

## 技术栈
### 后端
- Python 3.12+
- FastAPI 0.100+
- Uvicorn 0.23+
- Pandas 2.2+
- NumPy 1.26+
- SQLAlchemy 2.0+
- Redis 5.0+
- AkShare 1.10+
- Tushare 1.2+
- Baostock 0.8+
- Psutil 5.9+
- Scikit-learn 1.3+
- XGBoost 2.0+

### 前端
- React 18+
- TypeScript 5.0+
- ECharts 5.5+
- Ant Design 5.17+

## 部署说明
### 宝塔面板部署
1. 服务器环境：阿里云2核2G轻量应用服务器，CentOS 7+，宝塔Linux面板
2. 安装基础环境：Nginx 1.24、MariaDB 10.6、Redis 7.0、Python 3.12
3. 上传项目代码到/www/wwwroot/a_quant_system
4. 执行部署脚本：bash deploy/baota_deploy.sh
5. 配置Nginx反向代理，指向FastAPI服务的8000端口

### Docker Compose部署
1. 安装Docker与Docker Compose
2. 执行docker-compose up -d
3. 访问http://服务器IP:8000即可进入系统

## 项目结构
```
a_quant_system/
├── 0_compliance_core/           # 合规管控核心进程
│   ├── __init__.py
│   ├── compliance_lock.py       # 交易功能永久禁用锁
│   ├── content_interceptor.py   # 违规内容实时拦截引擎
│   ├── compliance_logger.py     # 不可篡改合规日志留存
│   └── compliance_middleware.py # 全链路合规中间件
├── 1_config/                    # 全局配置
│   ├── __init__.py
│   ├── settings.py              # 系统核心配置、合规常量、性能阈值
│   ├── risk_constants.py        # 风控硬约束常量、熔断阈值
│   ├── factor_config.py         # Alpha因子库配置、资金分层规则
│   └── strategy_config.py       # 策略矩阵配置、行情适配规则
├── 2_data_center/               # 实盘级数据中台
│   ├── __init__.py
│   ├── data_sources/            # 多数据源接入、冗余切换
│   │   ├── akshare_source.py
│   │   ├── tushare_source.py
│   │   └── baostock_source.py
│   ├── data_cleaner.py          # 数据清洗、交叉校验、异常值剔除
│   ├── data_cache.py            # 三级缓存体系（Redis+本地磁盘+OSS）
│   └── data_validator.py        # 数据质量评分、未来函数防控
├── 3_alpha_engine/              # 独家Alpha因子引擎
│   ├── __init__.py
│   ├── factor_library/          # 108个独家Alpha因子库
│   │   ├── price_volume_factors.py
│   │   ├── fundamental_factors.py
│   │   ├── money_flow_factors.py
│   │   └── risk_control_factors.py
│   ├── factor_orthogonal.py     # 因子正交化处理（PCA）
│   ├── factor_weight.py         # 因子动态权重调整（XGBoost）
│   ├── factor_monitor.py        # 因子衰减监控、失效预警与自动替换
│   └── fund_scale_adapter.py    # 三级资金规模因子池适配
├── 4_strategy_engine/           # 全市场适配多策略组合引擎
│   ├── __init__.py
│   ├── strategy_matrix/         # 6大低相关性核心策略
│   │   ├── multi_factor_strategy.py
│   │   ├── event_driven_strategy.py
│   │   ├── industry_rotation_strategy.py
│   │   └── defensive_strategy.py
│   ├── market_regime_detector.py# 行情环境智能识别
│   ├── strategy_weight.py       # 策略动态权重调整、风险平价配置
│   ├── strategy_circuit_breaker.py # 策略两级熔断与自动替换
│   └── signal_generator.py      # 多因子共振买卖信号生成
├── 5_real_market_fit/           # 实盘环境精准拟合模块
│   ├── __init__.py
│   ├── dynamic_slippage.py      # 全维度动态滑点测算模型
│   ├── impact_cost.py           # 流动性冲击成本精细化测算
│   ├── retail_deviation.py      # 散户交易行为偏差模拟
│   └── trade_capacity_check.py  # 可交易容量前置校验
├── 6_risk_control/              # 全周期独立风控闭环体系
│   ├── __init__.py
│   ├── pre_risk_control.py      # 事前风险防控、压力测试
│   ├── realtime_monitor.py      # 事中动态监控、30秒级响应
│   ├── principal_stop_loss.py   # 初始本金三级刚性止损机制
│   ├── drawdown_control.py      # 账户整体回撤刚性管控
│   ├── strategy_failure_control.py # 策略失效防控全闭环
│   ├── black_swan_response.py   # 黑天鹅与极端行情应急方案
│   └── circuit_breaker.py       # 两级策略强制熔断机制
├── 7_trading_discipline/        # 交易纪律与情绪全流程管控
│   ├── __init__.py
│   ├── pre_prevention.py        # 事前预防体系
│   ├── realtime_intervention.py # 事中实时干预、强制冷静机制
│   ├── review_reinforce.py      # 事后复盘强化体系
│   └── discipline_incentive.py  # 纪律执行积分激励体系
├── 8_backtest_attribution/      # 防过拟合回测与绩效归因模块
│   ├── __init__.py
│   ├── backtest_engine.py       # 回测核心引擎、实盘环境模拟
│   ├── overfit_prevention.py    # 强制过拟合防控机制
│   ├── performance_metrics.py   # 全维度绩效指标计算
│   └── attribution_analysis.py  # 收益与回撤归因分析
├── 9_user_empowerment/          # 小白全生命周期闭环赋能模块
│   ├── __init__.py
│   ├── novice_guide.py          # 3步极简新手引导
│   ├── simulation_trading.py    # 模拟盘强制闭环体系
│   ├── user_profile.py          # 智能用户画像与策略精准匹配
│   ├── logic_visualization.py   # 策略逻辑全可视化数据生成
│   └── education_system.py      # 全周期投研教育陪伴体系
├── 10_api_gateway/              # FastAPI接口网关（全链路合规校验）
│   ├── __init__.py
│   ├── main.py                  # 应用入口、全局中间件注册
│   ├── routers/                 # 路由模块
│   │   ├── data_router.py
│   │   ├── factor_router.py
│   │   ├── strategy_router.py
│   │   ├── signal_router.py
│   │   ├── risk_router.py
│   │   ├── backtest_router.py
│   │   └── user_router.py
│   ├── dependencies.py          # 权限、合规校验依赖
│   ├── schemas.py               # Pydantic数据模型
│   └── exception_handler.py     # 全局异常处理
├── 11_websocket/                # 实时数据推送与告警模块
│   ├── __init__.py
│   ├── ws_manager.py            # WebSocket连接管理、心跳检测
│   ├── push_priority.py         # 推送优先级管控
│   └── alert_sender.py          # 多渠道告警推送
├── 12_database/                 # 数据库ORM模型与初始化
│   ├── __init__.py
│   ├── models.py                # SQLAlchemy ORM模型
│   ├── session.py               # 数据库会话管理
│   └── init.sql                 # 数据库初始化脚本
├── 13_deployment/               # 部署运维与高可用方案
│   ├── supervisor/              # 进程管理配置（6个独立进程）
│   ├── docker/                  # Docker Compose一键部署方案
│   ├── baota_deploy.sh          # 宝塔面板一键部署脚本
│   ├── performance_optimize.sh  # 服务器极致性能优化脚本
│   ├── one_click_fix.py         # 小白一键故障修复脚本
│   └── backup_restore.py        # 自动备份与容灾恢复脚本
├── requirements.txt             # 全开源依赖包（无商用授权）
├── start_processes.py           # 进程统一启动入口
└── README.md                    # 项目文档、合规声明、使用说明
```

## 核心功能
1. **合规管控全链路**：全页面合规声明强制嵌入，违规内容实时拦截，合规日志不可篡改留存
2. **实盘级数据中台**：多数据源交叉校验，三级缓存体系，未来函数防控
3. **独家Alpha因子引擎**：108个独家因子，因子正交化，动态权重调整，因子失效预警
4. **多策略组合引擎**：6大低相关性核心策略，行情环境智能识别，策略动态权重调整
5. **实盘环境拟合**：动态滑点测算，冲击成本测算，散户交易行为偏差模拟
6. **全周期风控闭环**：事前风险防控，事中动态监控，事后熔断机制，本金三级止损
7. **交易纪律管控**：事前预防，事中干预，事后复盘，强制冷静机制
8. **防过拟合回测**：实盘环境模拟，过拟合防控，绩效归因分析
9. **小白赋能体系**：新手引导，模拟盘闭环，策略匹配，投研教育
10. **实时数据推送**：WebSocket实时推送，多渠道告警，优先级管控

## 性能要求
- 交易时段CPU峰值占用≤35%，内存峰值占用≤1GB
- 页面加载时间≤2秒，接口响应时间≤500ms
- 实时数据推送延迟≤2秒
- 全市场选股执行时间≤30秒，单次回测耗时≤10秒

## 运维说明
1. 每日自动备份数据库与项目代码到阿里云OSS
2. 每周检查服务器性能，清理过期日志与缓存
3. 每月更新因子库与策略体系，适配市场环境变化
4. 实时监控数据源状态，数据源失效时自动切换备用数据源
