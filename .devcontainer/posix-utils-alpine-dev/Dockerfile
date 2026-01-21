ARG __alpine_version=3.23
FROM alpine:${__alpine_version}

# Alpine packages versions: https://pkgs.alpinelinux.org/
ARG __curl_version
ARG __git_version
ARG __mandoc_version
ARG __shellcheck_version
ARG __shfmt_version
ARG __shunit2_version

ARG __gid=1001
ARG __gname=dev
ARG __uid=1001
ARG __uname=dev
ARG __user_home=/home/${__uname}

RUN apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache \
      curl \
      git \
      mandoc \
      shellcheck \
      shfmt \
      shunit2 \
    && addgroup -g ${__gid} ${__gname} \
    && adduser -u ${__uid} -G ${__gname} -D -h ${__user_home} ${__uname}

# minimal healthcheck, we do not really need it here
HEALTHCHECK CMD exit 0

USER ${__uname}
