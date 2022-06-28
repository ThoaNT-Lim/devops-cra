FROM node:13.12.0-alpine AS myapp

WORKDIR /app

COPY package*.json ./

RUN npm install && npm install react-scripts@3.4.1 -g --silent 

COPY . ./

RUN npm run build

FROM nginx:latest
COPY --from=myapp /app/build /usr/share/nginx/html