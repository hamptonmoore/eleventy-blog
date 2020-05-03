FROM nginx:1.17.10-alpine as npmpackages
RUN apk add --update nodejs npm
WORKDIR /app
COPY package.json .
RUN npm install

FROM nginx:1.17.10-alpine as builder
RUN apk add --update nodejs npm
WORKDIR /app
COPY --from=npmpackages /app /app
COPY . .
RUN npm run build
RUN rm -r /usr/share/nginx/html/
RUN cp /app/_site/ /usr/share/nginx/html/ -r

FROM nginx:1.17.10-alpine
COPY --from=builder /app/_site/ /usr/share/nginx/html/

EXPOSE 80