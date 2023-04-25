FROM --platform=$BUILDPLATFORM python:3.8-slim-bullseye

USER root
WORKDIR /root

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y install nodejs && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoclean && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove

COPY requirements.txt .
RUN pip install --no-cache-dir -U pip
RUN pip install --no-cache-dir -r requirements.txt

COPY .jupyter_config.py .

RUN mkdir -p .jupyter/lab/user-settings/@jupyterlab
WORKDIR /root/.jupyter/lab/user-settings/@jupyterlab
RUN mkdir apputils-extension && mkdir filebrowser-extension

WORKDIR /root/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
# set dark mode as default for jupyterlab
RUN echo '{ "theme":"JupyterLab Dark" }' > themes.jupyterlab-settings
# remove annoying news feed popup
RUN echo '{ "fetchNews":"false" }' > notification.jupyterlab-settings

WORKDIR /root/.jupyter/lab/user-settings/@jupyterlab/filebrowser-extension
# only show file names in filebrowser
RUN echo '{ "showLastModifiedColumn":false }' > browser.jupyterlab-settings

ENTRYPOINT [ "jupyter-lab", "--allow-root", "-y", "--no-browser", "--autoreload", "--ip=0.0.0.0", "--port=8000", "--port-retries=0" ]
CMD [ "--config=/root/.jupyter_config.py", "--log-level=50" ]
