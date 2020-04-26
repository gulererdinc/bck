# Image path
FROM alpine:3.10

# Create and Set the working directory
WORKDIR /app

# Copy required files
COPY app/ /app

# Install and set requirements
RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache postgresql-client lftp openssh-client bash && \
    rm -rf /var/cache/apk/* && \
    chmod g=u /etc/passwd && \
    /bin/mkdir -p /app/postgres-files &&\
    /bin/chmod -R 777 /app &&\
    /bin/sed -i 's/^#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config

# Run entrypoint
CMD ["./entrypoint.sh"]
