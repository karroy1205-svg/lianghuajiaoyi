#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
A股个人自用量化投研分析系统 - 后端服务入口
"""
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api_gateway.routes import router as api_router
from compliance_core.compliance_middleware import ComplianceMiddleware
from config.settings import API_CONFIG, PROJECT_NAME

# 创建FastAPI应用
app = FastAPI(
    title=PROJECT_NAME,
    description="A股个人自用量化投研分析系统 - 后端API服务",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# 【修复1：正确的中间件顺序】CORS中间件必须放在所有自定义中间件前面
# 添加CORS跨域中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=API_CONFIG["allow_origins"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 添加合规中间件（放在CORS后面）
app.add_middleware(ComplianceMiddleware)

# 注册API路由
app.include_router(api_router, prefix="/api")

# 健康检查接口
from fastapi.responses import PlainTextResponse
@app.get("/api/health")
async def health_check():
    return PlainTextResponse(content="A股量化投研系统服务运行正常")

# 启动应用
if __name__ == "__main__":
    uvicorn.run(
        app,
        host=API_CONFIG["host"],
        port=API_CONFIG["port"],
        reload=False,
        workers=1
    )

# 用于gunicorn启动的入口
application = app