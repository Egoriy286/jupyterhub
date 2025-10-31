FROM ubuntu:22.04

# Устанавливаем системные пакеты
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    python3-pip \
    libgl1-mesa-glx \
    xvfb \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Создаём пользователя fenics заранее
RUN useradd -m -s /bin/bash -G sudo fenics && \
    echo "fenics ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Устанавливаем Miniconda для пользователя fenics
USER fenics
WORKDIR /home/fenics

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /home/fenics/miniconda3 && \
    rm /tmp/miniconda.sh && \
    /home/fenics/miniconda3/bin/conda init bash

ENV PATH=/home/fenics/miniconda3/bin:$PATH
ENV CONDA_PREFIX=/home/fenics/miniconda3

# Принимаем условия использования conda
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Создаём conda-окружения с FEniCS (указываем версию 0.7.3 для dolfinx)
RUN conda create -n fenicsx -c conda-forge python=3.10 fenics-dolfinx=0.7.3 mpich pyvista meshio jupyter ipykernel -y && \
    conda create -n fenicsx-complex -c conda-forge python=3.10 fenics-dolfinx=0.7.3 petsc=*=complex* mpich pyvista meshio jupyter ipykernel -y && \
    conda create -n fenics-legacy -c conda-forge python=3.10 fenics mshr mpich jupyter ipykernel pytz -y

# Устанавливаем Jupyter kernels для каждого окружения
RUN /bin/bash -c "source /home/fenics/miniconda3/bin/activate fenicsx && python -m ipykernel install --user --name=fenicsx --display-name='FEniCSx 0.7.3 (real)'" && \
    /bin/bash -c "source /home/fenics/miniconda3/bin/activate fenicsx-complex && python -m ipykernel install --user --name=fenicsx-complex --display-name='FEniCSx 0.7.3 (complex)'" && \
    /bin/bash -c "source /home/fenics/miniconda3/bin/activate fenics-legacy && python -m ipykernel install --user --name=fenics-legacy --display-name='FEniCS Legacy'"

# Устанавливаем дополнительные библиотеки в base окружение
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    notebook \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas

# Создаём рабочую директорию
USER root
RUN mkdir -p /workspace && chown -R fenics:fenics /workspace

# Переключаемся обратно на пользователя fenics
USER fenics
WORKDIR /workspace

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab
CMD ["/home/fenics/miniconda3/bin/jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=", "--NotebookApp.password=", "--NotebookApp.allow_origin=*"]
