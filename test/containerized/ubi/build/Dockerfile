ARG __from_img=registry.access.redhat.com/ubi8/ubi-minimal:latest
FROM ${__from_img}

# Add a user and group to run the container # keep the ids consistent across tests
ARG __gid=1001
ARG __gname=dev
ARG __uid=1001
ARG __uname=dev
ARG __user_home=/home/${__uname}

# Install bash and tools for testing
RUN microdnf install -y \
    bash \
    findutils \
    shadow-utils \
    && microdnf clean all \
    && mkdir -p /usr/local/bin \
    && curl -sSL https://raw.githubusercontent.com/kward/shunit2/refs/heads/master/shunit2 \
        -o /usr/local/bin/shunit2 \
    && chmod +x /usr/local/bin/shunit2

RUN groupadd -g ${__gid} ${__gname} \
    && useradd -u ${__uid} -g ${__gname} ${__uname} \
    && mkdir -p /home/${__uname} \
    && chown ${__uname}:${__gname} /home/${__uname} \
    && chmod 755 /home/${__uname}
USER ${__uname}

# Set the working directory
WORKDIR /home/${__uname}

# Verify available shells and their linkage
RUN echo "Available shells:" && \
    ls -la /bin/*sh* && \
    echo "---" && \
    echo "Default /bin/sh points to: $(readlink -f /bin/sh)" && \
    echo "Bash version:" && bash --version | head -1