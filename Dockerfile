# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.209.6/containers/javascript-node/.devcontainer/base.Dockerfile

# [Choice] Node.js version (use -bullseye variants on local arm64/Apple Silicon): 16, 14, 12, 16-bullseye, 14-bullseye, 12-bullseye, 16-buster, 14-buster, 12-buster
ARG VARIANT="16-bullseye"

FROM node:${VARIANT}

# ARG SSH_PRIVATE_KEY

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends jq libsecret-1-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /root/.gnupg /tmp/library-scripts


RUN mkdir -p /home/node/.ssh && chown -R node:node /home/node/.ssh
# COPY joplin /home/node/.ssh/id_rsa

# RUN touch /home/node/.ssh/id_rsa &&  echo ${SSH_PRIVATE_KEY} > /home/node/.ssh/id_rsa

RUN su node -c "touch /home/node/.ssh/known_hosts"
RUN su node -c "ssh-keyscan github.com >> /home/node/.ssh/known_hosts"

# 安装 joplin
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org
RUN su node -c "NPM_CONFIG_PREFIX=~/.joplin-bin cnpm install -g joplin hexo-cli "

# RUN rm /home/node/.ssh/id_rsa

# FROM node:${VARIANT}

# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends jq libsecret-1-dev \
#     && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /root/.gnupg /tmp/library-scripts

# RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

# COPY --from=source /home/node/.joplin-bin /home/node/.joplin-bin

RUN ln -s /home/node/.joplin-bin/bin/joplin /usr/bin/joplin
RUN ln -s /home/node/.joplin-bin/bin/hexo /usr/bin/hexo

VOLUME [ "/home/node/.config"]

# RUN mkdir -p /home/node/.ssh && chown -R node:node /home/node/.ssh
# RUN su node -c "touch /home/node/.ssh/known_hosts"
# RUN su node -c "ssh-keyscan github.com >> /home/node/.ssh/known_hosts"

ENV SYNC_TARGET 9
ENV SYNC_PATH ''
ENV SYNC_USERNAME ''
ENV SYNC_PASSWORD ''
ENV BLOG_REPOSITORY ''
ENV GIT_USER 'ytianxia6'
ENV GIT_EMAIL 'ytianxia6@gmail.com'
ENV SYNC_TIME_INTERVAL '5m'

COPY entrypoint.sh /usr/local/bin
RUN ["chmod", "+x", "/usr/local/bin/entrypoint.sh"]
# RUN ln -s /usr/local/bin/entrypoint.sh .

USER node
WORKDIR /home/node/.config

# RUN su node -c "npm install -g joplin"


ENTRYPOINT ["/usr/local/bin/entrypoint.sh" ]

