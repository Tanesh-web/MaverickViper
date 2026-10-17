# Stage 1: Build Maverick Viper WAR package using Maven & Temurin JDK 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Cache Maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code and build production WAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Production runtime with Apache Tomcat 10.1 (Jakarta EE 10 / Servlet 6.0)
FROM tomcat:10.1-jdk21-temurin

LABEL maintainer="Maverick Viper NPTEL Platform"

# Clean out default Tomcat sample apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR to ROOT (so http://domain/ works directly) and MaverickViper (so /MaverickViper/ works too)
COPY --from=build /app/target/MaverickViper*.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=build /app/target/MaverickViper*.war /usr/local/tomcat/webapps/MaverickViper.war

# Create dynamic port binding script for Render / Railway / Cloud providers
RUN printf '#!/bin/sh\n\
PORT="${PORT:-8080}"\n\
echo "Configuring Tomcat on port $PORT..."\n\
sed -i "s/port=\\"8080\\"/port=\\"$PORT\\"/g" /usr/local/tomcat/conf/server.xml\n\
exec catalina.sh run\n' > /usr/local/tomcat/bin/entrypoint.sh && \
    chmod +x /usr/local/tomcat/bin/entrypoint.sh

EXPOSE 8080

CMD ["/usr/local/tomcat/bin/entrypoint.sh"]
