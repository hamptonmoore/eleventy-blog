FROM nginx:1.17.10-alpine as npmpackages
RUN apk add --update nodejs npm
WORKDIR /app
COPY package.json .
RUN npm install


FROM nginx:1.17.10-alpine
RUN apk add --update nodejs npm
WORKDIR /app
COPY --from=npmpackages /app /app
COPY . .
RUN npm run build
RUN rm -r /usr/share/nginx/html/
RUN cp /app/_site/ /usr/share/nginx/html/ -r

EXPOSE 80