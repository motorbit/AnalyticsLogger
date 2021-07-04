FROM swift:latest

RUN apt-get update && apt-get install nginx nano -y
RUN mkdir /app && mkdir /app/repo && cd /app/repo
RUN git clone https://github.com/motorbit/AnalyticsLogger.git && swift build -c release
RUN cp /app/repo/AnalyticsLogger/.build/release/AnalyticsLogger /app
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
RUN cp /app/repo/AnalyticsLogger/nginx.conf /etc/nginx/sites-available/default
RUN nginx
RUN /app/AnalyticsLogger 37.57.72.201


EXPOSE 80