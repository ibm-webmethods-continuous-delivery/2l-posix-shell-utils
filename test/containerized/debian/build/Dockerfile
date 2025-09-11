ARG __from_img=debian:stable-slim
FROM ${__from_img}

# Add a user and group to run the container
ARG __gid=888
ARG __gname=dev
ARG __uid=888
ARG __uname=dev
ARG __user_home=/home/${__uname}

# Install multiple shells for comprehensive testing
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    dash \
    findutils \
    && curl -sSL https://raw.githubusercontent.com/kward/shunit2/refs/heads/master/shunit2 \
        -o /usr/local/bin/shunit2 \
    && chmod +x /usr/local/bin/shunit2 \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g ${__gid} ${__gname} \
    && useradd -u ${__uid} -g ${__gname} -d ${__user_home} -m -s /bin/sh ${__uname} \
    && mkdir -p ${__user_home} \
    && chown ${__uname}:${__gname} ${__user_home} \
    && chmod 755 ${__user_home}

USER ${__uname}
WORKDIR ${__user_home}

# Verify available shells and their linkage
RUN echo "Available shells:" && \
    ls -la /bin/*sh* && \
    echo "---" && \
    echo "Default /bin/sh points to: $(readlink -f /bin/sh)" && \
    echo "Bash version:" && bash --version | head -1 && \
    echo "Dash version:" && dash -c 'echo "Dash shell"' 2>&1 || echo "dash version not available"
