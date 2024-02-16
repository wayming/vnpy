# For more information, please refer to https://aka.ms/vscode-docker-python
FROM ubuntu:latest

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install tools
RUN apt update
RUN apt install python3 -y
RUN apt install python3-pip -y
# RUN apt install tzdata -y
RUN apt install kmod mesa-utils libgl1-mesa-dri -y
RUN apt install libgl1-mesa-glx libegl1 libglib2.0-0 libxkbcommon0 libdbus-1-3 libxkbcommon-x11-0 -y
RUN apt-get install libxcb1 libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-shape0 -y

ENV TZ=Australia/Brisbane
# Set the timezone to Australia/Brisbane (replace with your desired timezone)
# RUN ln -fs /usr/share/zoneinfo/Australia/Brisbane /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Chinese support
RUN apt install wget locales -y && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
RUN apt-get update && apt-get install -y fonts-wqy-zenhei
ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN:zh
ENV LC_ALL zh_CN.UTF-8

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
    && usermod -aG video $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install gateways and strategy
RUN pip install gateways/vnpy_ctp
RUN pip install strategy/vnpy_ctastrategy 
RUN pip install strategy/vnpy_ctabacktester 
RUN pip install database/vnpy_sqlite
RUN pip install gateways/vnpy_ib/ib_tws
RUN pip install gateways/vnpy_ib

USER $USERNAME

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "run.py"]
