FROM swift:latest

RUN apt-get update && apt-get install nginx nano -y
RUN mkdir /app && mkdir /app/repo
RUN cd /app/repo && git clone https://github.com/motorbit/AnalyticsLogger.git
RUN cd /app/repo/AnalyticsLogger && swift build -c release
RUN cp /app/repo/AnalyticsLogger/.build/release/AnalyticsLogger /app
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
RUN cp /app/repo/AnalyticsLogger/nginx.conf /etc/nginx/sites-available/default
EXPOSE 80