# FEniCSx Docker Images (dolfinx v0.7.3)

Docker-образы для работы с **FEniCSx (dolfinx v0.7.3)**, собранные на основе официального образа  
`dolfinx/dolfinx:v0.7.3`.

Репозиторий содержит две версии:
- **real** — вычисления с вещественными числами
- **complex** — вычисления с комплексными числами

Образы опубликованы в **GitHub Container Registry (GHCR)**.

---

## Базовый образ

- `dolfinx/dolfinx:v0.7.3`
- Python + MPI + PETSc + UFL + Basix
- Готов для HPC и MPI-запусков

---

## Доступные образы

### 🔹 Real (вещественная арифметика)

```bash
docker pull ghcr.io/egoriy286/fenicsx-real:main
```

### 🔹 Complex (комплексная арифметика)

```bash
docker pull ghcr.io/egoriy286/fenicsx-complex:main
```

---

# Быстрый старт

### Запуск интерактивной сессии

```bash
docker run -it --rm ghcr.io/egoriy286/fenicsx-real:main bash
```
или для complex-версии:
```bash
docker run -it --rm ghcr.io/egoriy286/fenicsx-complex:main bash
```

---

# ⚠️ Важное предупреждение

## ❗ Графический вывод не поддерживается

В образах **отсутствуют библиотеки** для графического вывода, включая:

- Xvfb

- OpenGL / Mesa

- GUI-зависимости ParaView

Это означает:

- ❌ Нельзя запускать ParaView с GUI внутри контейнера
- ❌ Нельзя использовать pyvista.Plotter(show=True)
- ✅ Можно сохранять результаты в файлы (.xdmf, .vtu, .pvd)
- ✅ Можно визуализировать результаты вне контейнера (например, в ParaView на хосте)

# Рекомендованный workflow визуализации

1. В контейнере сохранить результаты:
```python
from dolfinx.io import XDMFFile

with XDMFFile(comm, "result.xdmf", "w") as xdmf:
    xdmf.write_mesh(mesh)
    xdmf.write_function(u)
```
2. Открыть файл `result.xdmf` в ParaView на хост-системе

---
# Назначение образов

- Численное моделирование PDE
- MPI-расчёты
- Запуск в CI / HPC / серверной среде
- Использование без GUI

--- 

# Лицензия

Используются лицензии исходных проектов:
- FEniCSx
- PETSc
- dolfinx
Дополнительные слои образа — см. репозиторий.
