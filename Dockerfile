# -------------------------------------------------------------
# - DOCKERFILE
# - AUTOR: @DevSoft eam
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

# 1. Copiar las herramientas de empaquetado de Gradle
COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle gradle.properties ./

# 2. Descargar dependencias en caché (Truco de velocidad para Docker)
# Ejecuta un build vacío para cachear las librerías sin recompilar código mutado
RUN ./gradlew dependencies --no-daemon || true

# 3. Copiar el código fuente del proyecto
COPY src/ src/

# 4. Compilar y empaquetar la aplicación omitiendo pruebas unitarias para el artefacto final
RUN ./gradlew bootJar --no-daemon -x test

# 5. Extraer las capas del JAR para optimizar el almacenamiento en Docker
WORKDIR /build/extracted
RUN java -Djarmode=layertools -jar /build/build/libs/*.jar extract

# ==========================================
# FASE 2: Entorno de Ejecución (Runtime Stage)
# ==========================================
FROM eclipse-temurin:25-jre-alpine AS runner
WORKDIR /app

# 1. Crear un usuario de sistema sin privilegios para mitigar exploits de seguridad
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REVISION

# Informacion de la persona que mantiene la imagen
LABEL org.opencontainers.image.created=$BUILD_DATE \
	  org.opencontainers.image.authors="@DevSoft team" \
	  org.opencontainers.image.url="https://github.com/wortiz1027/dvdrental/blob/main/Dockerfile" \
	  org.opencontainers.image.documentation="" \
	  org.opencontainers.image.source="https://github.com/wortiz1027/dvdrental/blob/main/Dockerfile" \
	  org.opencontainers.image.version=$BUILD_VERSION \
	  org.opencontainers.image.revision=$BUILD_REVISION \
	  org.opencontainers.image.vendor="Seguros Alfa | https://www.devsoft.com.co/" \
	  org.opencontainers.image.licenses="" \
	  org.opencontainers.image.title="Backend para la gestion de renta de dvds" \
	  org.opencontainers.image.description="Componente encargado de gestionar la informacion de la renta de dvds"

# 2. Copiar cada capa del JAR de forma independiente desde la fase de compilación
# Esto permite que si cambias una clase, Docker solo actualice la mini-capa de la aplicación (application)
COPY --from=builder /build/extracted/dependencies/ ./
COPY --from=builder /build/extracted/spring-boot-loader/ ./
COPY --from=builder /build/extracted/snapshot-dependencies/ ./
COPY --from=builder /build/extracted/application/ ./

# 3. Configuración de variables de entorno críticas para Alta Concurrencia
ENV JAVA_OPTS="-XX:+UseZGC -XX:+ZGenerational -XX:+UnlockDiagnosticVMOptions -XX:+IdleTuningGcOnIdle -Dfile.encoding=UTF-8"

# 4. Exponer los puertos de los tres protocolos de entrada que utilizaremos
EXPOSE 8080 9090 50051

# 5. Lanzar la aplicación usando el cargador nativo de capas de Spring Boot
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
