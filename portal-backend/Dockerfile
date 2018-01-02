FROM openjdk:8
COPY portal-0.0.1-SNAPSHOT.jar /usr/myapp/portal.jar
COPY application.properties /usr/myapp/config/application.properties
WORKDIR /usr/myapp
CMD ["java", "-jar", "portal.jar"]
