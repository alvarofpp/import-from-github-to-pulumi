FROM alpine:3.21.2

# Set environment variables
ENV HOME=/root

# Arguments for user customization
ARG USERNAME=infra
ARG USER_UID=1000
ARG GROUP_ID=$USER_UID
ARG GROUP_NAME=$USERNAME

# Install packages
RUN apk --no-cache add findutils  \
    curl \
    bash-completion \
    jq \
    envsubst

# Directory to save resources files
RUN mkdir -p /opt/resources
RUN mkdir -p /opt/templates
COPY ./templates/* /opt/templates/

# Adds shell commands
COPY ./commands/* /usr/bin/

# Create user and configure permissions
RUN addgroup --gid $GROUP_ID $GROUP_NAME \
    && adduser --disabled-password --home /home/$USERNAME --uid $USER_UID --ingroup $GROUP_NAME $USERNAME \
    && apk add --no-cache sudo \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the new user
USER $USERNAME
WORKDIR /home/$USERNAME

# Entrypoint
ENTRYPOINT ["docker-entrypoint"]
