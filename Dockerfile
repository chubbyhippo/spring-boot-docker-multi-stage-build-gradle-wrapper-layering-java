FROM bellsoft/liberica-openjdk-alpine:17 AS builder
WORKDIR application
COPY gradle gradle
COPY gradlew gradlew
COPY build.gradle.kts build.gradle.kts
RUN sed -i 's/\r$//' gradlew # For windows os
RUN ./gradlew dependencies
COPY src src
RUN ./gradlew bootJar
RUN java -Djarmode=layertools -jar build/libs/*.jar extract

FROM bellsoft/liberica-openjre-alpine:17
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]