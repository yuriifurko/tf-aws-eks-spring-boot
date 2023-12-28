#FROM maven:3.8.5-openjdk-18

FROM maven:3.8.7-openjdk-18-slim

COPY custom-metrics-demo-0.0.1-SNAPSHOT.jar /app/custom-metrics-demo-0.0.1-SNAPSHOT.jar

CMD [ "java", "-jar", "/app/custom-metrics-demo-0.0.1-SNAPSHOT.jar" ]