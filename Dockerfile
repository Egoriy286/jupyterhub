# Базовый образ с dolfinx (Python 3.10)
FROM dolfinx/dolfinx:v0.7.3

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Установка JupyterHub и необходимых пакетов
RUN apt-get update && apt-get install -y \
    python3-pip \
    npm \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

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

# Создание пользователей
RUN for i in $(seq 1 13); do \
      user=$(echo "Aiyyna Danil Dima Egoriy Erkhan Ilianna Mark Nurgun Zhang Arsen Alexander Student" | cut -d' ' -f${i}); \
      pass="student${i}"; \
      useradd -m -s /bin/bash "$user"; \
      echo "$user:$pass" | chpasswd; \
    done

# Создание рабочей директории
WORKDIR /workspace
RUN chmod -R 777 /workspace

# Открываем порт JupyterHub
EXPOSE 8000

# Настраиваем запуск JupyterHub
CMD ["jupyterhub", "--ip=0.0.0.0", "--port=8000"]
