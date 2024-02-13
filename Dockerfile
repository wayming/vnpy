# For more information, please refer to https://aka.ms/vscode-docker-python
FROM ubuntu:latest

# Install tools
RUN apt update
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install wget locales -y
RUN apt install libgl1-mesa-glx libegl1 libglib2.0-0 libxkbcommon0 libdbus-1-3 -y
# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

ENV TZ=Australia/Brisbane

# Install pip requirements and vnpy
WORKDIR /app
COPY . /app
RUN bash install.sh

# # Creates a non-root user with an explicit UID and adds permission to access the /app folder
# # For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
ARG USERNAME=appuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "setup.py"]
