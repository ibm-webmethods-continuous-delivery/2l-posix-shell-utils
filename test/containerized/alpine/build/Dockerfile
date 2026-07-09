ARG __from_img=alpine:3.23
FROM ${__from_img}

# Add a user and group to run the container
ARG __gid=1001
ARG __gname=dev
ARG __uid=1001
ARG __uname=dev
ARG __user_home=/home/${__uname}

# Install multiple shells for comprehensive testing
RUN apk add --no-cache --update \
      bash \
      busybox \
      coreutils \
      curl \
      dash \
      findutils \
      shadow \
    && curl -sSL https://raw.githubusercontent.com/kward/shunit2/refs/heads/master/shunit2 \
        -o /usr/local/bin/shunit2 \
    && chmod +x /usr/local/bin/shunit2

# Create user and group
RUN addgroup -g ${__gid} ${__gname} \
    && adduser -u ${__uid} -G ${__gname} -h ${__user_home} -s /bin/sh -D ${__uname} \
    && mkdir -p ${__user_home} \
    && chown ${__uname}:${__gname} ${__user_home} \
    && chmod 755 ${__user_home}

USER ${__uname}
WORKDIR ${__user_home}

# Verify available shells
RUN echo "Available shells:" \
    && ls -la /bin/*sh* \
    && echo "---" \
    && echo "Bash version:" && bash --version | head -1 \
    && echo "Dash version:" && dash --version 2>&1 | head -1 || echo "dash version not available" \
    && echo "Busybox ash version:" && busybox ash --help 2>&1 | head -1 || echo "busybox ash version not available"
