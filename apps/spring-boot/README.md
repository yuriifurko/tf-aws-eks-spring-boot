Spring Boot Metrics
===

[String Boot Initilization](https://start.spring.io)

### Check status

```
curl -sS --location 'http://localhost:8080/actuator/health' | jq

curl -sS --location 'http://hello-world-dev-lb-controller-1641609581.us-east-1.elb.amazonaws.com/spring-boot/' | jq
```

### Get metrics

```
curl -sS --location 'http://localhost:8080/actuator/metrics' | jq
curl -sS --location 'http://localhost:8080/actuator/metrics/process.cpu.usage' | jq
```

### Grafana Dashboard

[JVM (Micrometer)](https://grafana.com/grafana/dashboards/4701-jvm-micrometer/)

### Dependency-check

```bash
dependency-check -f ALL -s src --data dataDirectoryPath=".db"
```

### SonarQube analazing

```bash
mvn clean verify sonar:sonar \
    -Dsonar.projectName=spring-boot \
    -Dsonar.projectKey=spring-boot \
    -Dsonar.branch.name=develop \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login="" \
    -Dsonar.dependencyCheck.htmlReportPath=dependency-check-report.html
```