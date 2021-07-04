# AnalyticsLogger
docker build -t analyticslogger:v1 -f Dockerfile .
docker run -d -p 8080:80 analyticslogger:v1 sh