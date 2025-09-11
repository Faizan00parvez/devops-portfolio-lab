# Multi-stage build for a Java Spring Boot API

# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY users-api/pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline
COPY users-api/src ./src
RUN mvn -q -e -B -DskipTests package

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
ENV USER=appuser
RUN addgroup -S $USER && adduser -S $USER -G $USER
WORKDIR /app
COPY --from=build /src/target/*jar /app/app.jar
USER $USER
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]