# Базовый образ с DOLFINx
FROM dolfinx/dolfinx:v0.7.3

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

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

# Создаем пользователя fenicsx (если не существует)
RUN useradd -m -s /bin/bash -G sudo fenicsx || true && \
    echo "fenicsx ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Даем полный доступ к /workspace
    chown -R fenicsx:fenicsx /workspace && \
    chmod -R 777 /workspace

# Настраиваем ipyparallel для работы с MPI
RUN ipython profile create --parallel --profile=mpi

# Настраиваем права доступа
RUN chmod -R 777 /workspace && \
    mkdir -p /home/fenicsx/.jupyter && \
    chown -R fenicsx:fenicsx /home/fenicsx

# Копируем конфигурацию Jupyter для пользователя fenicsx с base_url
RUN mkdir -p /home/fenicsx/.jupyter && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.base_url = '/fenicsx/'" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = False" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/fenicsx/.jupyter/jupyter_lab_config.py && \
    chown -R fenicsx:fenicsx /home/fenicsx/.jupyter

# Переключаемся на пользователя fenicsx
USER fenicsx

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab от пользователя fenicsx
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--base-url=/fenicsx/"]

