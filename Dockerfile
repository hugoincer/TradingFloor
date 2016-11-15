FROM java:8-alpine
MAINTAINER Your Name <you@example.com>

ADD target/uberjar/tradingfloor.jar /tradingfloor/app.jar

EXPOSE 3000

CMD ["java", "-jar", "/tradingfloor/app.jar"]
