# Dockerfile с Python 3.10, DOLFIN и DOLFINx без conda
FROM dolfinx/dolfinx:v0.7.3

USER root

# Настройка для неинтерактивной установки
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Создаём пользователя fenics заранее
RUN useradd -m -s /bin/bash fenics && \
    echo "fenics ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Установка системных зависимостей для FEniCS legacy
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:fenics-packages/fenics \
    && apt-get update \
    && apt-get install -y \
    fenics \
    && rm -rf /var/lib/apt/lists/*

# Обновляем pip и устанавливаем Jupyter Lab и дополнительные библиотеки
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas \
    meshio \
    pyvista

# Создаём рабочую директорию
USER root
RUN mkdir -p /workspace && chown -R fenics:fenics /workspace
RUN sed -i '/fenics ALL=(ALL) NOPASSWD:ALL/d' /etc/sudoers && \
    echo "fenics ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" >> /etc/sudoers


# Переключаемся обратно на пользователя fenics
USER fenics
WORKDIR /workspace

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--NotebookApp.token='student123'", "--NotebookApp.password='student123'"]
