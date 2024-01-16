FROM curlimages/curl:8.2.1 AS download
ARG OTEL_AGENT_VERSION="1.32.0"
RUN curl --silent --fail -L "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_AGENT_VERSION}/opentelemetry-javaagent.jar" \
    -o "$HOME/opentelemetry-javaagent.jar"

FROM maven:3.8.7-openjdk-18-slim AS build
ADD . /build
RUN cd /build && mvn install -DskipTests

FROM openjdk:18.0.2.1-jdk-slim
COPY --from=build /build/target/*.jar /app.jar
COPY --from=download /home/curl_user/opentelemetry-javaagent.jar /opentelemetry-javaagent.jar

CMD ["java", \
  "-javaagent:/opentelemetry-javaagent.jar", \
  "-Dotel.service.name=spring-boot", \
  "-jar", "/app.jar" \
]