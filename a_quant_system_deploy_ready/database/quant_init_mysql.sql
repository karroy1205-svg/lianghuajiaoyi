-- ==============================================
-- A股量化投研系统数据库初始化SQL（MySQL适配版）
-- 适用于MySQL 8.0+
-- ==============================================

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    risk_level INT DEFAULT 1 -- 风险等级 1-保守 2-稳健 3-激进
);

-- 创建策略表
CREATE TABLE IF NOT EXISTS strategies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL, -- 策略类型：multi_factor, event_driven, industry_rotation, defensive
    parameters JSON NOT NULL, -- 策略参数
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    user_id INT REFERENCES users(id)
);

-- 创建信号表
CREATE TABLE IF NOT EXISTS signals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stock_code VARCHAR(20) NOT NULL,
    stock_name VARCHAR(100) NOT NULL,
    signal_type VARCHAR(20) NOT NULL, -- buy, sell, hold
    strategy_id INT REFERENCES strategies(id),
    factor_scores JSON NOT NULL, -- 因子得分
    confidence FLOAT NOT NULL, -- 置信度 0-1
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT TRUE
);

-- 创建风控表
CREATE TABLE IF NOT EXISTS risk_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL, -- 风控类型：stop_loss, drawdown, circuit_breaker
    message TEXT NOT NULL,
    level VARCHAR(20) NOT NULL, -- warning, error, critical
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved BOOLEAN DEFAULT FALSE,
    user_id INT REFERENCES users(id)
);

-- 创建回测结果表
CREATE TABLE IF NOT EXISTS backtest_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    strategy_id INT REFERENCES strategies(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_return FLOAT NOT NULL,
    annual_return FLOAT NOT NULL,
    max_drawdown FLOAT NOT NULL,
    sharpe_ratio FLOAT NOT NULL,
    win_rate FLOAT NOT NULL,
    trades_count INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parameters JSON NOT NULL
);

-- 创建持仓表
CREATE TABLE IF NOT EXISTS positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(id),
    stock_code VARCHAR(20) NOT NULL,
    stock_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    avg_price FLOAT NOT NULL,
    open_date DATE NOT NULL,
    close_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- 创建交易记录表
CREATE TABLE IF NOT EXISTS trade_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(id),
    stock_code VARCHAR(20) NOT NULL,
    stock_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL, -- buy, sell
    quantity INT NOT NULL,
    price FLOAT NOT NULL,
    trade_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    position_id INT REFERENCES positions(id),
    strategy_id INT REFERENCES strategies(id)
);

-- 创建因子监控表
CREATE TABLE IF NOT EXISTS factor_monitor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    factor_name VARCHAR(100) NOT NULL,
    ic_value FLOAT NOT NULL,
    ir_value FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT TRUE
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_strategies_user_id ON strategies(user_id);
CREATE INDEX IF NOT EXISTS idx_signals_stock_code ON signals(stock_code);
CREATE INDEX IF NOT EXISTS idx_signals_strategy_id ON signals(strategy_id);
CREATE INDEX IF NOT EXISTS idx_risk_records_user_id ON risk_records(user_id);
CREATE INDEX IF NOT EXISTS idx_backtest_results_strategy_id ON backtest_results(strategy_id);
CREATE INDEX IF NOT EXISTS idx_positions_user_id ON positions(user_id);
CREATE INDEX IF NOT EXISTS idx_positions_stock_code ON positions(stock_code);
CREATE INDEX IF NOT EXISTS idx_trade_records_user_id ON trade_records(user_id);
CREATE INDEX IF NOT EXISTS idx_trade_records_stock_code ON trade_records(stock_code);
CREATE INDEX IF NOT EXISTS idx_factor_monitor_factor_name ON factor_monitor(factor_name);

-- 插入初始数据
-- 插入默认管理员用户（密码：123456，需修改）
INSERT INTO users (username, email, password_hash, risk_level)
VALUES ('admin', 'admin@quant.com', '$2b$12$EixZaYol6T5olgyxV3z3je1j0F6f5Aq1f5Aq1f5Aq1f5Aq1f5Aq1f5Aq1f5Aq1', 2)
ON DUPLICATE KEY UPDATE email=email;

-- 插入默认策略
INSERT INTO strategies (name, description, type, parameters)
VALUES ('默认多因子策略', '基于量价、基本面、资金流因子的多因子策略', 'multi_factor', '{"factors": ["pe_ratio", "roe", "volume_ratio", "money_flow"], "weights": [0.25, 0.25, 0.25, 0.25], "threshold": 0.6}')
ON DUPLICATE KEY UPDATE description=description;
