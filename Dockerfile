# Базовый образ dolfinx (Python 3.10)
FROM dolfinx/dolfinx:v0.7.3

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Системные пакеты
RUN apt-get update && apt-get install -y \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Python-пакеты
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyterhub \
    notebook \
    jupyterlab \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas \
    meshio \
    pyvista

# Установка стабильной версии configurable-http-proxy
RUN npm install -g configurable-http-proxy@4.1.2 --unsafe-perm=true --allow-root

# Создание пользователей
RUN set -eux; \
    users="Aiyyna Danil Dima Egoriy Erkhan Ilianna Mark Nurgun Zhang Arsen Alexander Student"; \
    i=1; \
    for user in $users; do \
      useradd -m -s /bin/bash "$user"; \
      echo "$user:student${i}" | chpasswd; \
      i=$((i+1)); \
    done

# Рабочая директория
WORKDIR /workspace
RUN chmod -R 777 /workspace

# Открываем порт JupyterHub
EXPOSE 8000

# Запуск JupyterHub
CMD ["jupyterhub", "--ip=0.0.0.0", "--port=8000"]
