# USE THE FOLLOWING COMMAND TO CHANGE THE DEFAULT SERVER PORT (WHICH IS 80) AND THE DEFAULT API ENDPOINT (WHICH IS http://host.docker.internal:8080/api):
# docker run -d -e BOOKS_BACK_API_URL=http://host.docker.internal:8080/api -e BOOKS_FRONT_SERVER_PORT=80 -p 80:80 books-front-service:latest

# BUILD STAGE
FROM node:22-alpine AS books-service-build

WORKDIR /app

COPY package.json package-lock.json ./
RUN ["npm", "ci"]

COPY index.html vite.config.js ./
COPY src ./src
RUN ["npm", "run", "build"]

#RUN sed -i "s/%SERVER_PORT%/${BOOKS_FRONT_SERVER_PORT:-85}/g" /etc/nginx/conf.d/default.conf

# RUNTIME STAGE
FROM nginx:1.31.3

ENV BOOKS_FRONT_SERVER_PORT=${BOOKS_FRONT_SERVER_PORT:-80}
ENV BOOKS_BACK_API_URL=${BOOKS_BACK_API_URL:-http://host.docker.internal:8080/api}

COPY ./nginx/default.conf.template /etc/nginx/templates/default.conf.template

COPY --from=books-service-build /app/dist/index.html /usr/share/nginx/html/
COPY --from=books-service-build /app/dist/assets /usr/share/nginx/html/assets/

EXPOSE ${BOOKS_FRONT_SERVER_PORT}