bind = '0.0.0.0:8000'
user = 'www'
workers = 2
threads = 2
backlog = 512
chdir = '/www/wwwroot/a_quant_system_deploy_ready/backend'
access_log_format = '%(t)s %(h)s %(p)s %(r)s %(s)s %(M)s %(L)s %(f)s %(a)s'
loglevel = 'info'
# 核心：必须用UvicornWorker适配FastAPI
worker_class = 'uvicorn.workers.UvicornWorker'
errorlog = '/www/wwwroot/a_quant_system_deploy_ready/backend/logs/error.log'
accesslog = '/www/wwwroot/a_quant_system_deploy_ready/backend/logs/access.log'
pidfile = '/www/wwwroot/a_quant_system_deploy_ready/backend/logs/投研后端.pid'