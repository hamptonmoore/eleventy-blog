FROM nginx:1.17.10-alpine
RUN apk add --update nodejs npm
RUN npm install -g @11ty/eleventy

COPY . /app

WORKDIR /app

RUN npm install

RUN eleventy  .
RUN rm -r /usr/share/nginx/html/
RUN cp /app/_site/ /usr/share/nginx/html/ -r

EXPOSE 80