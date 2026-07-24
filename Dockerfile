# BUILD STAGE
FROM node:22-alpine AS books-service-build

WORKDIR /app

COPY package.json package-lock.json ./
RUN ["npm", "ci"]

COPY index.html vite.config.js ./
COPY src ./src
RUN ["npm", "run", "build"]

# RUNTIME STAGE
FROM httpd:2.4-alpine

COPY --from=books-service-build /app/dist/index.html /usr/local/apache2/htdocs/
COPY --from=books-service-build /app/dist/assets /usr/local/apache2/htdocs/assets

COPY config/httpd.conf /usr/local/apache2/conf/httpd.conf

RUN ["httpd", "-t"]

EXPOSE 8585