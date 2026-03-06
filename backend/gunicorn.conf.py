bind = '0.0.0.0:8000'
workers = 2
worker_class = 'uvicorn.workers.UvicornWorker'
chdir = '/www/wwwroot/a_quant_system_deploy_ready/backend'
errorlog = './logs/error.log'
accesslog = './logs/access.log'
loglevel = 'info'