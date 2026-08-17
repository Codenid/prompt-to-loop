# Prompt to Loop

> From prompting to looping: building your first AI agent.

Este proyecto demuestra de forma práctica la evolución desde una interacción tradicional basada en **prompts** hacia un sistema basado en **loops**, donde el modelo puede proponer una solución, ejecutarla, observar el resultado, recibir feedback y volver a intentarlo hasta alcanzar un objetivo.

La demo utiliza un caso sencillo de **optimización de consultas SQL sobre transacciones de tarjetas de crédito**.

El objetivo no es construir un optimizador SQL para producción, sino entender el patrón fundamental detrás de muchos sistemas agentic:

```text
Goal
 ↓
LLM
 ↓
Action
 ↓
Observation
 ↓
Evaluation
 ↓
Retry / Done
```

---

## Roadmap

El proyecto evolucionará progresivamente en tres niveles:

| Nivel | Implementación | Objetivo |
|---|---|---|
| Basic | Python + Loop manual | Entender Prompting → Looping |
| Advanced | State + Tools + PostgreSQL | Construir un agente explícito |
| Pro | LangGraph | Orquestar el agente con un runtime |

Actualmente:

> **Basic — disponible**

---

# Basic — SQL Optimization Loop

## Caso de uso

Trabajaremos con un escenario simplificado de tarjetas de crédito:

```text
Customers
    │
    ▼
Cards
    │
    ▼
Transactions
```

El dataset sintético contiene aproximadamente:

| Tabla | Registros |
|---|---:|
| Customers | 100K |
| Cards | 150K |
| Transactions | 20M |

La consulta busca responder:

> ¿Cuáles son los clientes Premium con mayor consumo aprobado durante 2025, considerando transacciones superiores al importe promedio del año?

La query inicial funciona correctamente, pero contiene oportunidades de optimización.

---

## Prompting vs Looping

### Prompting

En el enfoque tradicional:

```text
SQL
 ↓
LLM
 ↓
Optimized SQL
```

El modelo genera una respuesta, pero no sabe si realmente:

- la query funciona;
- mantiene el mismo resultado;
- mejora el rendimiento.

### Looping

En esta demo agregamos un ciclo de ejecución y evaluación:

```text
              ┌──────────────────┐
              │                  │
              ▼                  │
Goal → LLM → SQL → Execute → Evaluate
                              │
                         ┌────┴────┐
                         │         │
                       Retry      Done
                         │
                         └─────────┘
```

Cada iteración:

1. genera una propuesta;
2. ejecuta la query;
3. valida que el resultado sea equivalente;
4. mide el rendimiento;
5. compara contra el objetivo;
6. utiliza el resultado como feedback;
7. vuelve a intentarlo si es necesario.

---

# Stack

La versión Basic utiliza únicamente:

- Python
- Jupyter Notebook
- DuckDB
- Ollama
- Mistral
- OpenAI Python SDK

No utiliza:

- LangChain
- LangGraph
- Docker
- PostgreSQL
- agentes múltiples

Esto es intencional.

El objetivo es entender primero **cómo funciona el loop** antes de introducir frameworks de orquestación.

---

# Arquitectura Basic

```text
Jupyter Notebook
       │
       ▼
     Python
       │
       ├───────────────┐
       │               │
       ▼               ▼
    DuckDB         OpenAI SDK
                       │
                       ▼
                 Ollama Local
                       │
                       ▼
                    Mistral
```

Ollama expone el modelo local mediante una API compatible con OpenAI.

Esto permite utilizar el patrón:

```python
from openai import OpenAI
```

manteniendo el modelo ejecutándose localmente.

---

# Estructura del proyecto

```text
prompt-to-loop/
│
├── README.md
├── requirements.txt
├── setup.ps1
├── .gitignore
│
├── data/
│
├── notebooks/
│   └── 01_sql_loop_basic.ipynb
│
└── prompts/
    └── optimize_sql.txt
```

La base DuckDB y el dataset se generan localmente al ejecutar el notebook.

---

# Quick Start

## 1. Prerrequisitos

Necesitas tener instalado:

### Python

Recomendado:

```text
Python 3.11+
```

Verifica:

```bash
python --version
```

### Ollama

Verifica:

```bash
ollama --version
```

---

## 2. Descargar Mistral

Verifica primero los modelos disponibles:

```bash
ollama list
```

Si `mistral` no aparece:

```bash
ollama pull mistral
```

Prueba el modelo:

```bash
ollama run mistral
```

Si responde correctamente, Ollama está listo.

---

## 3. Clonar el repositorio

```bash
git clone <repository-url>
cd prompt-to-loop
```

---

## 4. Configurar el entorno

### Windows

Ejecuta:

```powershell
.\setup.ps1
```

El script:

```text
crea .venv
    ↓
instala requirements.txt
    ↓
registra el kernel Jupyter
    ↓
SQL Loop Basic
```

No necesitas crear manualmente un entorno Conda.

El entorno `.venv` pertenece exclusivamente a este proyecto y no modifica tus otros entornos Python, Conda o Miniconda.

---

## 5. Abrir el notebook

Abre:

```text
notebooks/01_sql_loop_basic.ipynb
```

Selecciona el kernel:

```text
SQL Loop Basic
```

Si VS Code no muestra inmediatamente el kernel:

```text
Ctrl + Shift + P
```

Ejecuta:

```text
Developer: Reload Window
```

y vuelve a seleccionar el kernel.

---

## 6. Ejecutar la demo

Ejecuta el notebook en orden.

El notebook realizará:

```text
Setup
 ↓
Crear dataset sintético
 ↓
Ejecutar query original
 ↓
Medir baseline
 ↓
Prompting
 ↓
Medir propuesta del LLM
 ↓
Looping
 ↓
Validar + medir + feedback
 ↓
Goal Achieved / Max Iterations
```

---

# Criterio de éxito

El loop utiliza dos condiciones principales.

### Correctitud

La query optimizada debe producir el mismo resultado que la original.

```text
Same Result = True
```

### Performance

Debe alcanzar una mejora mínima configurable.

Ejemplo:

```python
TARGET_IMPROVEMENT = 0.10
MAX_ITERATIONS = 5
```

Esto significa:

```text
Target = 10%
Maximum attempts = 5
```

El loop termina cuando:

```text
Same Result = True
        AND
Improvement >= Target
```

o cuando alcanza el máximo de iteraciones.

---

# Ejemplo de ejecución

Una ejecución puede producir:

```text
==================================================
ITERATION 1
==================================================

Time        : 0.2420 s
Improvement : 1.61%
Same result : True


==================================================
ITERATION 2
==================================================

Time        : 0.1161 s
Improvement : 52.78%
Same result : True

GOAL ACHIEVED
```

El punto importante no es el porcentaje específico obtenido.

Los resultados dependen del hardware, modelo, caché y condiciones de ejecución.

Lo importante es el comportamiento:

```text
Iteration 1
     ↓
Goal not achieved
     ↓
Feedback
     ↓
Iteration 2
     ↓
Evaluate
     ↓
Goal achieved
```

---

# Benchmark

Para reducir el ruido de las mediciones, la demo no utiliza una única ejecución.

Cada query realiza:

```text
Warm-up
   ↓
Multiple executions
   ↓
Median execution time
```

La mediana se utiliza como referencia para comparar las propuestas.

> Esta metodología es suficiente para una demo educativa, pero no debe interpretarse como un benchmark de base de datos para producción.

---

# ¿Por qué DuckDB?

DuckDB permite ejecutar toda la demo localmente sin instalar:

- servidores;
- bases de datos externas;
- contenedores;
- infraestructura adicional.

Esto mantiene el foco en el concepto:

> **Prompting → Looping**

En las siguientes versiones del proyecto utilizaremos PostgreSQL para trabajar con métricas y conceptos más cercanos a optimización SQL real.

---

# Limitaciones del Basic

Esta versión está diseñada para aprendizaje.

No implementa todavía:

- análisis completo de execution plans;
- índices;
- estimated cost;
- buffer analysis;
- state persistente;
- tools;
- observabilidad;
- human approval;
- guardrails avanzados;
- rollback;
- LangGraph.

Estas capacidades aparecerán progresivamente en las versiones **Advanced** y **Pro**.

---

# ¿Qué sigue?

## Advanced

La siguiente versión evolucionará hacia:

```text
Goal
 ↓
Agent
 ↓
Tools
 ├── inspect_schema
 ├── explain_query
 └── benchmark
 ↓
State
 ↓
Evaluator
 ↓
Retry / Done
```

Utilizando PostgreSQL podremos incorporar:

- `EXPLAIN ANALYZE`;
- estimated cost;
- execution plans;
- scans;
- joins;
- cardinalidad;
- índices.

## Pro

Finalmente trasladaremos el mismo patrón a LangGraph:

```text
START
  ↓
Agent Node
  ↓
Tool Node
  ↓
Evaluator Node
  ↓
Conditional Edge
  ├── RETRY
  └── END
```

La idea es simple:

> Primero entendemos el loop. Después entendemos por qué necesitamos un framework para administrarlo.

---

## Disclaimer

Este proyecto tiene fines educativos.

Las queries generadas por un LLM no deben ejecutarse automáticamente sobre bases de datos productivas sin controles adicionales de seguridad, permisos, validación y observabilidad.