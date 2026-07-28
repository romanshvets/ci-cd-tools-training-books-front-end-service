# USE THE FOLLOWING COMMAND TO CHANGE THE DEFAULT SERVER PORT (WHICH IS 80) AND :
# docker run -e BOOKS_FRONT_SERVER_PORT=8090 -p 8090:8090 %image name%

# BUILD STAGE
FROM node:22-alpine AS books-service-build

WORKDIR /app

COPY package.json package-lock.json ./
RUN ["npm", "ci"]

COPY index.html vite.config.js ./
COPY src ./src
RUN ["npm", "run", "build"]

# RUNTIME STAGE
FROM nginx:1.31.3

ENV NGINX_PORT=9876

COPY ./nginx/default.conf.template /etc/nginx/templates/default.conf.template

#RUN sed -i "s/%SERVER_PORT%/${BOOKS_FRONT_SERVER_PORT:-85}/g" /etc/nginx/conf.d/default.conf

COPY --from=books-service-build /app/dist/index.html /usr/share/nginx/html/
COPY --from=books-service-build /app/dist/assets /usr/share/nginx/html/assets/

EXPOSE ${BOOKS_FRONT_SERVER_PORT}



#$ cat Dockerfile
 ## USE THE FOLLOWING COMMAND TO CHANGE THE DEFAULT SERVER PORT (WHICH IS 8080):
 ## docker run -e BOOKS_BACK_SERVER_PORT=9097 -p 8080:9097 %image name%
 #
 ## BUILD STAGE
 #FROM gradle:jdk17-alpine AS books-service-build
 #
 #WORKDIR /app
 #
 #COPY gradlew build.gradle ./
 #COPY gradle ./gradle
 #RUN ["./gradlew", "dependencies", "--no-daemon"]
 #
 #COPY src ./src
 #RUN ["./gradlew", "build", "--no-daemon"]
 #
 ## RUNTIME STAGE
 #FROM eclipse-temurin:17-jre-alpine
 #
 #ENV SERVER_PORT=${BOOKS_BACK_SERVER_PORT:-8080}
 #
 #WORKDIR /app
 #
 #COPY --from=books-service-build --exclude=*-plain.jar /app/build/libs/*.jar ./app.jar
 #
 #EXPOSE ${SERVER_PORT}
 #
 #CMD ["java", "-jar", "./app.jar"]

#FROM httpd:2.4-alpine
 #
 #COPY --from=books-service-build /app/dist/index.html /usr/local/apache2/htdocs/
 #COPY --from=books-service-build /app/dist/assets /usr/local/apache2/htdocs/assets
 #
 #COPY config/httpd.conf /usr/local/apache2/conf/httpd.conf
 #
 #RUN ["httpd", "-t"]
 #
 #EXPOSE 8585