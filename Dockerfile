FROM debian:9.5-slim
ADD entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install curl -y
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
