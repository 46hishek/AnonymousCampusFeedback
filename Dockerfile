
FROM maven:3.9-eclipse-temurin-24 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

FROM tomcat:10.1-jre24-temurin

ENV JAVA_OPTS="-Xms32m -Xmx160m -XX:MaxMetaspaceSize=96m"

COPY --from=build /app/target/campus-feedback.war /usr/local/tomcat/webapps/campus-feedback.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

FROM maven:3.9-eclipse-temurin-24 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

FROM tomcat:10.1-jre24-temurin

ENV JAVA_OPTS="-Xms32m -Xmx160m -XX:MaxMetaspaceSize=96m"

COPY --from=build /app/target/campus-feedback.war /usr/local/tomcat/webapps/campus-feedback.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
