// 前端全局脚本文件
class QuantSystem {
    constructor() {
        this.apiBaseUrl = window.QUANT_CONFIG.API_BASE_URL;
        this.wsBaseUrl = window.QUANT_CONFIG.WS_BASE_URL;
        this.init();
    }

    init() {
        this.initWebSocket();
        this.initRequestInterceptor();
    }

    // 初始化WebSocket连接
    initWebSocket() {
        this.ws = new WebSocket(this.wsBaseUrl);
        this.ws.onopen = () => {
            console.log("WebSocket连接成功");
        };
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleWebSocketMessage(data);
        };
        this.ws.onclose = () => {
            console.log("WebSocket连接关闭，5秒后重试");
            setTimeout(() => this.initWebSocket(), 5000);
        };
        this.ws.onerror = (error) => {
            console.error("WebSocket错误:", error);
        };
    }

    // 处理WebSocket消息
    handleWebSocketMessage(data) {
        switch (data.type) {
            case "signal":
                this.handleSignalMessage(data);
                break;
            case "risk":
                this.handleRiskMessage(data);
                break;
            case "log":
                this.handleLogMessage(data);
                break;
            default:
                console.log("未知消息类型:", data);
        }
    }

    // 处理信号消息
    handleSignalMessage(data) {
        console.log("收到策略信号:", data);
        // 可以在这里添加消息提示或者更新页面内容
        this.showMessage(`收到新的策略信号: ${data.stock_code} - ${data.signal_type}`, "info");
    }

    // 处理风控消息
    handleRiskMessage(data) {
        console.log("收到风控告警:", data);
        this.showMessage(`风控告警: ${data.message}`, "warning");
    }

    // 处理日志消息
    handleLogMessage(data) {
        console.log("系统日志:", data);
    }

    // 初始化请求拦截器
    initRequestInterceptor() {
        // 这里可以添加请求拦截器，统一处理请求头、错误等
    }

    // 通用请求方法
    request(url, options = {}) {
        return fetch(`${this.apiBaseUrl}${url}`, {
            headers: {
                "Content-Type": "application/json",
                ...options.headers
            },
            ...options
        }).then(response => {
            if (!response.ok) {
                throw new Error(`请求失败: ${response.status}`);
            }
            return response.json();
        }).catch(error => {
            console.error("请求错误:", error);
            this.showMessage("请求失败，请稍后重试", "error");
            throw error;
        });
    }

    // 消息提示方法
    showMessage(message, type = "info") {
        // 这里可以添加消息提示组件，比如Toast
        console.log(`[${type}] ${message}`);
        // 示例：使用alert，实际项目中可以替换为更美观的提示组件
        alert(`${type === "error" ? "错误" : type === "warning" ? "警告" : "提示"}: ${message}`);
    }
}

// 页面加载完成后初始化系统
document.addEventListener("DOMContentLoaded", () => {
    window.quantSystem = new QuantSystem();
});
