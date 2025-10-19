# Build stage
FROM maven:3.9-eclipse-temurin-17-focal as builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-jammy

# Create PKCS12 truststore from system CA certificates
RUN keytool -importkeystore \
        -srckeystore /opt/java/openjdk/lib/security/cacerts \
        -srcstoretype JKS \
        -srcstorepass changeit \
        -destkeystore /tmp/tsl-ssl-truststore.p12 \
        -deststoretype PKCS12 \
        -deststorepass digidoc4j-password \
        -noprompt

WORKDIR /app
COPY --from=builder /app/siva-parent/siva-webapp/target/siva-webapp-*-exec.jar app.jar

ENV SIVA_TSL_LOADER_SSLTRUSTSTOREPATH=file:/tmp/tsl-ssl-truststore.p12
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
