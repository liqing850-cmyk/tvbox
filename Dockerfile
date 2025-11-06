FROM 2011820123/tvbox:latest

# 假设原 entrypoint 是 /app/update.sh 或类似，添加 auth 逻辑
COPY entrypoint-fix.sh /entrypoint-fix.sh
RUN chmod +x /entrypoint-fix.sh
ENTRYPOINT ["/entrypoint-fix.sh"]
