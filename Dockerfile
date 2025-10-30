# Базовый образ с DOLFINx
FROM dolfinx/dolfinx:v0.7.3

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Устанавливаем необходимые пакеты и FEniCS Legacy
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:fenics-packages/fenics \
    && apt-get update \
    && apt-get install fenics -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Обновляем pip и устанавливаем Jupyter Lab и дополнительные библиотеки
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas \
    meshio \
    pyvista \
    ipyparallel

# Создаем пользователя fenics (если не существует)
RUN useradd -m -s /bin/bash -G sudo fenics || true && \
    echo "fenics ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Даем полный доступ к /workspace
    chown -R fenics:fenics /workspace && \
    chmod -R 777 /workspace

# Настраиваем ipyparallel для работы с MPI
RUN ipython profile create --parallel --profile=mpi

# Настраиваем права доступа
RUN chmod -R 777 /workspace && \
    mkdir -p /home/fenics/.jupyter && \
    chown -R fenics:fenics /home/fenics

# Копируем конфигурацию Jupyter для пользователя fenics
RUN mkdir -p /home/fenics/.jupyter && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = False" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    chown -R fenics:fenics /home/fenics/.jupyter

# Переключаемся на пользователя fenics
USER fenics

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab от пользователя fenics
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888"]
