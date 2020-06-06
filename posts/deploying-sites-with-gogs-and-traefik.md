---
title: Deploying Sites with Gogs
description: Using Gogs to automatically push updated versions of a website to a nginx docker container
date: 2020-05-03
layout: layouts/post.njk
---
`This is an updated version of an old blog post on my site back in 2018. While I do not use gogs anymore and have a different deploy system, I have updated this to make it more readable and more efficent. That being said since I currently do not use gogs so this method has not been tested but *should* continue to work.`

To start gogs must have its data volume placed somewhere on disk, for this example it is placed at `/var/gogs` on the host system. Next a post-receive must be setup on the repo, it should look something along the lines of this.
```
git --work-tree=/data/serve/hampton.pw/ --git-dir=/data/git/gogs-repositories/herohamp/hampton.pw.git checkout -f
```
Make sure to change the second argument `--git-dir` to match the location of the gogs repo. What this does is it makes it so that the git repo is copied to the location `/data/serve/hampton.pw` on each git commit. Now that the data is at an easy to access place we need to do something with it. For this the base `nginx` docker container will be used due to it's simplicity. With it a volume can just be made to the container's path `/usr/share/nginx/html` and it will serve the contents. To do this a simple docker-compose was put together. Yours should look similar just make sure to update the location of the gogs data.
```
nginx:
    image: nginx:1.17.10-alpine
    volumes:
      - /var/gogs/serve/hampton.pw:/usr/share/nginx/html
```
The same thing can be done with the following docker run command.
```
docker run -v /var/gogs/serve/hampton.pw:/usr/share/nginx/html -d nginx:1.17.10-alpine
```
The Traefik labels allows for Traefik to automatically deploy the site for me with https. This works because nginx docker image will just serve to the client whatever the current contents of its local `/usr/share/nginx/html` which in this case is mapped to the hosts folder `/var/gogs/serve/hampton.pw`. In actual deployment of this and other sites I would suggest using something like [Traefik](https://docs.traefik.io/) as a proxy in front of the nginx containers.
