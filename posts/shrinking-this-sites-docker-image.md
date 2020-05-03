---
title: Shrinking this sites docker image
description: How this sites docker image went from 419MB to 69.1MB
date: 2020-05-03
layout: layouts/post.njk
---

Recently I moved my static [Eleventy](https://www.11ty.dev/) site over to a docker container. This was one of the first docker images I have made in a while so it started inefficient. 
```
FROM nginx:1.17.10-alpine
RUN apk add --update nodejs npm
RUN npm install -g @11ty/eleventy
COPY . /app
WORKDIR /app
RUN npm install
RUN eleventy .
RUN rm -r /usr/share/nginx/html/
RUN cp /app/_site/ /usr/share/nginx/html/ -r
EXPOSE 80
``` 
This docker image resulted in a 419MB final image according and took about 3 minutes to build. There are some obvious issues with this. For instance every-time I change any file it must go through and reinstall all of my node_modules. Secondly, I was installing Eleventy globally while at the same time installing it during the second npm install. 

```
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
```
This build was segmented into two portions, at first it just copied the package.json and run npm install. This means that assuming that the package.json file did not change at all then after the first docker build it would cache the node_modules so that it did not have to install on each build. This shrunk the docker image down to 329MB, which was a little better, but still heavily bloated. After poking around in the docker image I saw the issue, I was keeping the /app folder even though it was not being used anymore.

```
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
```
This is the final image that I ended up with, note how the final layer does not install NPM or NodeJS. This is to save space as at that point the `builder` and `npmpackage` layers have already done everything related to NodeJS. This image only took up 69.1MB which is pretty good considering the compiled version of my site is over 50MB due to various images. The next step in shrinking my site's docker image will be compressing the images down, but that is unrelated to the docker image itself.

EDIT: After compression of all of the images and WaifuCraft resource pack the whole site is 19MB with the image being 39MB