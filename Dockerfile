# -------------------------------------------------------------
# - DOCKERFILE
# - AUTOR: @DevSoft Team
# - FECHA: 21-ulio-2026
# - DESCRIPCION: Docker compose file que permite la
# -              creacion de 1 contendor para el servicio de
# -              renta de dvds
# -------------------------------------------------------------
# -------------------------------------------------------------
# docker build \
#  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
#  --build-arg BUILD_VERSION="2.5.0-RC1" \
#  --build-arg BUILD_REVISION=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown") \
#  -t dvd-rental:latest .
# -------------------------------------------------------------
# escape=\ (backslash)

# ==========================================
# FASE 1: Entorno de Compilación (Build Stage)
# ==========================================
FROM eclipse-temurin:25-jdk-alpine AS builder
WORKDIR /build

COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle gradle.properties ./

RUN ./gradlew dependencies --no-daemon || true

COPY src/ src/

RUN ./gradlew bootJar --no-daemon -x test

WORKDIR /build/extracted
RUN java -Djarmode=layertools -jar /build/build/libs/*.jar extract

# ==========================================
# FASE 2: Entorno de Ejecución (Runtime Stage)
# ==========================================
FROM dhi.io/eclipse-temurin:25-alpine AS runner
WORKDIR /app

# 1. Crear un usuario de sistema sin shell interactiva para mitigar exploits de terminal
RUN addgroup -S spring && adduser -S spring -G spring -h /app -s /sbin/nologin && rm -rf /var/cache/apk/* /lib/apk/db/*

USER spring:spring

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REVISION

# Informacion de la persona que mantiene la imagen
LABEL org.opencontainers.image.created=$BUILD_DATE \
	  org.opencontainers.image.authors="@DevSoft Team" \
	  org.opencontainers.image.url="https://github.com/wortiz1027/dvdrental/blob/main/Dockerfile" \
	  org.opencontainers.image.documentation="" \
	  org.opencontainers.image.source="https://github.com/wortiz1027/dvdrental/blob/main/Dockerfile" \
	  org.opencontainers.image.version=$BUILD_VERSION \
	  org.opencontainers.image.revision=$BUILD_REVISION \
	  org.opencontainers.image.vendor="Develment Software Team | https://www.devsoft.com.co/" \
	  org.opencontainers.image.licenses="" \
	  org.opencontainers.image.title="Backend para la gestion de renta de dvds" \
	  org.opencontainers.image.description="Componente encargado de gestionar la informacion de la renta de dvds"

COPY --from=builder /build/extracted/dependencies/ ./
COPY --from=builder /build/extracted/spring-boot-loader/ ./
COPY --from=builder /build/extracted/snapshot-dependencies/ ./
COPY --from=builder /build/extracted/application/ ./

ENV JAVA_OPTS="-XX:+UseZGC -XX:+ZGenerational -XX:+UnlockDiagnosticVMOptions -Dfile.encoding=UTF-8 -XX:+AlwaysPreTouch -Xss256k"

EXPOSE 8080 9090 50051

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
