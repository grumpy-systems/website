---
title: "Emby + Nginx Reverse Proxy"
date: 2021-11-24
tags: ["homelab","how-to","linux"]
---

After some light Google-ing, I couldn't find a simple example for Emby running
behind an Nginx reverse proxy.  I built this config using some boilerplate
config I have and some config snippets from other config examples.

If you're brand new or not sure exactly what you need, it can be a bit confusing
to see older threads with lots of comments and suggestions, and it may be hard
to tell what exactly you need to edit.  I figure this example can be a fairly
simple end-to-end example.

## Config File

Here's the configuration file.  You'll need to edit some things, I'll detail
those below.

```nginx
# Redirect 80 to SSL
server {
    listen 80 default_server;

    return 301 https://emby_url$request_uri;
}

# Forward everything into Emby

server {
    listen 443 ssl default_server;
    server_name emby_url; 
    
    ssl_session_timeout     30m;
    ssl_protocols           TLSv1.2 TLSv1.1 TLSv1;
    ssl_certificate         /etc/ssl/--/ssl.combined;
    ssl_certificate_key     /etc/ssl/--/ssl.key;
    ssl_session_cache       shared:SSL:10m;
        
    
     location / {
        proxy_pass http://127.0.0.1:8080;  

        proxy_set_header Range $http_range;
        proxy_set_header If-Range $http_if_range;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        #Next three lines allow websockets
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Things to Change

There are a few variables you'll need to update for your environment:

* `emby_url` - This is in a few places, and should be the domain name of your
  Emby server.
* `ssl_certificate` and `ssl_certificate_key` - These should point to your SSL
  certificate you'd like Nginx to serve.  You can use a service like
  Let'sEncrypt and CertBot to manage that configuration section for you.
* `default_server` - If you're running multiple servers on the same node, you
  may want to remove this.  This tells Nginx to route requests that don't match
  other server configurations to be served there.
* `127.0.0.1` - This should be the IP or domain name of your Emby server.  In my
  case, this all runs on the same host so I just point it into localhost.

Depending on your setup, a reverse proxy may be needed to accomplish any number
of tasks.  I won't go into detail of what all Nginx can do for Emby, but
hopefully this configuration is a good starting platform for you too.
