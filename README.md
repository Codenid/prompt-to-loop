# Prompt to Loop

> **¿Qué pasaría si el LLM no se detuviera después de su primera respuesta?**

**Prompt to Loop** es un proyecto educativo para explorar uno de los patrones fundamentales detrás de los sistemas de IA agénticos: **Looping**.

En una interacción tradicional con un LLM tenemos:

```mermaid
flowchart LR
    A[Prompt] --> B[LLM]
    B --> C[Respuesta]
```

El modelo genera una respuesta y termina.

Pero **generar una respuesta no significa haber alcanzado el objetivo**.

Con Looping introducimos un mecanismo diferente:

```mermaid
flowchart TD
    A[Objetivo] --> B[LLM]
    B --> C[Acción]
    C --> D[Entorno]
    D --> E[Observación]
    E --> F[Evaluación]

    F -->|Objetivo alcanzado| G[Fin]
    F -->|Objetivo no alcanzado| H[Feedback]
    H --> B
```

El sistema deja de depender exclusivamente de la primera respuesta del modelo y comienza a trabajar iterativamente hasta alcanzar un **criterio de éxito verificable**.

---

# ¿Por qué Looping?

Los LLM son buenos generando propuestas, pero una propuesta puede ser:

- incorrecta;
- incompleta;
- inválida;
- subóptima;
- imposible de ejecutar;
- aparentemente correcta, pero incapaz de cumplir el objetivo.

En el Prompting tradicional el flujo normalmente termina después de generar la respuesta:

```mermaid
flowchart LR
    A[Usuario] --> B[Prompt]
    B --> C[LLM]
    C --> D[Respuesta]
    D --> E[Fin]
```

Looping introduce algo fundamental:

**evidencia sobre el resultado obtenido.**

```mermaid
flowchart TD
    A[Objetivo] --> B[LLM]
    B --> C[Propuesta]
    C --> D[Ejecutar]
    D --> E[Observar resultado]
    E --> F{¿Cumple el objetivo?}

    F -->|Sí| G[Fin]
    F -->|No| H[Generar Feedback]
    H --> B
```

Ahora el sistema puede responder una pregunta mucho más importante:

> **¿La respuesta realmente consiguió el resultado esperado?**

Si la respuesta es `No`, puede utilizar lo observado para volver a intentarlo.

---

# Del Prompt al Objetivo

El cambio conceptual más importante de este proyecto es pasar de:

> "Genera una mejor solución."

a definir explícitamente:

```text
Objetivo:
Alcanzar X resultado.

Restricciones:
- debe ser válido;
- debe preservar determinadas condiciones;
- debe superar una métrica definida.

Condición de salida:
terminar cuando se alcance el objetivo
o cuando se llegue al máximo de intentos.
```

Esto introduce varios elementos fundamentales:

| Concepto | Responsabilidad |
|---|---|
| **Objetivo (Goal)** | Define qué queremos conseguir |
| **Acción (Action)** | Intenta conseguir el objetivo |
| **Observación (Observation)** | Obtiene evidencia del resultado |
| **Evaluación (Evaluation)** | Determina si el intento fue exitoso |
| **Feedback** | Alimenta el siguiente intento |

El ciclo empieza a tomar esta forma:

```mermaid
flowchart LR
    A[Intento] --> B[Observación]
    B --> C[Evaluación]
    C --> D[Feedback]
    D --> E[Siguiente intento]
    E --> B
```

Repetir un prompt varias veces no es necesariamente Looping.

El valor aparece cuando **el resultado de un intento modifica inteligentemente el siguiente**.

---

# La Demo

Para demostrar el patrón utilizamos un problema fácil de ejecutar y verificar:

> **Optimización de una consulta SQL.**

SQL funciona especialmente bien para esta demostración porque permite pasar de una afirmación subjetiva:

> "Esta query parece mejor."

a evidencia objetiva:

```text
¿La query ejecuta?             ✓ / ✗
¿Devuelve el mismo resultado?  ✓ / ✗
¿Mejora el rendimiento?        ✓ / ✗
¿Alcanzó el objetivo?          ✓ / ✗
```

Por ejemplo:

```python
TARGET_IMPROVEMENT = 0.10
MAX_ITERATIONS = 5
```

Esto establece:

- mejora objetivo: **10 %**;
- máximo de intentos: **5**.

---

# Caso de uso

La demo utiliza un escenario simplificado de **tarjetas de crédito**.

```mermaid
erDiagram
    CUSTOMERS ||--o{ CARDS : posee
    CARDS ||--o{ TRANSACTIONS : realiza

    CUSTOMERS {
        bigint customer_id
        string customer_name
        string segment
    }

    CARDS {
        bigint card_id
        bigint customer_id
        string card_type
        string status
    }

    TRANSACTIONS {
        bigint transaction_id
        bigint card_id
        date transaction_date
        decimal amount
        string transaction_status
    }
```

El dataset sintético contiene aproximadamente:

| Tabla | Registros |
|---|---:|
| Customers | 100K |
| Cards | 150K |
| Transactions | 20M |

La consulta busca responder:

> **¿Cuáles son los clientes Premium con mayor consumo aprobado durante 2025, considerando transacciones superiores al importe promedio del año?**

La consulta inicial funciona correctamente, pero contiene oportunidades de optimización.

---

# 1. Prompting

Primero ejecutamos el enfoque tradicional.

```mermaid
flowchart LR
    A[SQL Original] --> B[Prompt]
    B --> C[LLM]
    C --> D[SQL Optimizado]
    D --> E[Fin]
```

Le pedimos al modelo:

> Optimiza esta consulta SQL.

El modelo genera una nueva consulta.

El problema es que el proceso termina ahí.

El modelo puede afirmar que optimizó la query sin demostrar que:

- sea válida;
- produzca el mismo resultado;
- sea realmente más rápida.

Una respuesta convincente **no es necesariamente una solución correcta**.

---

# 2. Looping

Ahora agregamos ejecución, observación, evaluación y feedback.

```mermaid
flowchart TD
    A[SQL Original] --> B[Medir Baseline]
    B --> C[Definir Objetivo]
    C --> D[LLM]
    D --> E[SQL Candidato]
    E --> F[Ejecutar]
    F --> G[Validar resultado]
    G --> H[Benchmark]
    H --> I{¿Objetivo alcanzado?}

    I -->|Sí| J[Best Query]
    I -->|No| K[Generar Feedback]
    K --> D
```

Cada iteración sigue el mismo patrón:

```text
Proponer
   ↓
Ejecutar
   ↓
Validar
   ↓
Medir
   ↓
Evaluar
   ↓
Feedback
   ↓
Reintentar
```

El LLM ya no decide por sí mismo si tuvo éxito.

**El entorno proporciona evidencia y el sistema evalúa esa evidencia.**

---

# Cuando el primer intento no es suficiente

Supongamos que obtenemos:

```text
ITERATION 1

Time        : 241 ms
Improvement : 1.61%
Same result : True
```

La consulta funciona y mantiene el resultado.

Pero nuestro objetivo era:

```text
Improvement >= 10%
```

Por lo tanto:

```text
1.61% < 10%

GOAL NOT ACHIEVED
```

El sistema no termina.

Genera feedback y realiza otro intento.

```mermaid
flowchart TD
    A[Iteración 1] --> B[Mejora 1.61%]
    B --> C{Target >= 10%?}
    C -->|No| D[Feedback]
    D --> E[Iteración 2]
    E --> F[Mejora 52.78%]
    F --> G{Target >= 10%?}
    G -->|Sí| H[Goal Achieved]
```

Una segunda iteración podría producir:

```text
ITERATION 2

Time        : 116 ms
Improvement : 52.78%
Same result : True

GOAL ACHIEVED
```

El porcentaje concreto no es lo importante y puede variar según hardware, modelo y condiciones de ejecución.

Lo importante es el comportamiento:

> **El sistema observó que su primer intento no cumplía el objetivo y utilizó esa información para continuar trabajando.**

---

# Los errores también son información

Un LLM puede generar SQL inválido.

Por ejemplo:

```text
Binder Error:
Referenced table not found
```

En una interacción tradicional:

```mermaid
flowchart LR
    A[LLM] --> B[SQL inválido]
    B --> C[Error]
    C --> D[Usuario debe intervenir]
```

Dentro de un Loop:

```mermaid
flowchart TD
    A[LLM] --> B[SQL candidato]
    B --> C[DuckDB]
    C --> D{¿Ejecuta?}

    D -->|Sí| E[Continuar evaluación]
    D -->|No| F[Capturar Error]
    F --> G[Convertir error en Feedback]
    G --> A
```

El error deja de ser únicamente un fallo.

Se convierte en una **observación que puede utilizarse para mejorar el siguiente intento**.

---

# El Loop en Python

Esta primera versión implementa deliberadamente el patrón sin frameworks de agentes.

Conceptualmente:

```python
while not goal_achieved:

    action = llm(...)

    observation = execute(action)

    evaluation = evaluate(observation)

    feedback = build_feedback(evaluation)
```

La implementación real incorpora además:

```mermaid
flowchart TD
    A[LLM] --> B[SQL Candidate]
    B --> C{SQL válido?}

    C -->|No| D[Feedback del error]
    D --> A

    C -->|Sí| E{Mismo resultado?}

    E -->|No| F[Feedback de validación]
    F --> A

    E -->|Sí| G[Benchmark]

    G --> H{Target alcanzado?}

    H -->|No| I[Feedback de performance]
    I --> A

    H -->|Sí| J[Best Query]
```

Esto permite ver directamente los componentes que posteriormente aparecerán en arquitecturas agénticas más sofisticadas.

---

# ¿Esto ya es un agente?

Esta demo se mantiene deliberadamente simple.

Tenemos:

```text
Goal
Action
Observation
Evaluation
Feedback
Loop
Stop Condition
```

Pero todavía no tenemos capacidades como:

```text
State Management
Tools
Dynamic Routing
Memory
Checkpoints
Human Approval
Observability
Multiple Actions
```

Cuando empezamos a agregar estas capacidades, nuestro simple `while` comienza a convertirse en un pequeño **Agent Runtime**.

Ahí frameworks especializados empiezan a aportar valor.

---

# Evolución del proyecto

El proyecto está diseñado en tres niveles.

```mermaid
flowchart LR
    A["01 — BASIC<br/>Prompt → Loop"] --> B["02 — ADVANCED<br/>Loop → Agent"]
    B --> C["03 — PRO<br/>Agent → Agent Runtime"]
```

## Basic

```mermaid
flowchart TD
    A[Prompt] --> B[Loop]
    B --> C[Feedback]
    C --> D[Evaluation]
    D --> B
```

Objetivo:

> Entender **Looping** sin esconder su funcionamiento detrás de un framework.

---

## Advanced

```mermaid
flowchart TD
    A[Goal] --> B[Agent]
    B --> C[Tools]
    C --> D[State]
    D --> E[Evaluator]

    E -->|Retry| B
    E -->|Done| F[Result]
```

Incorporaremos:

- State;
- Tools;
- PostgreSQL;
- `EXPLAIN ANALYZE`;
- execution plans;
- estimated cost;
- scans;
- cardinalidad;
- índices.

Objetivo:

> Entender qué convierte un simple loop en un **agente**.

---

## Pro

```mermaid
flowchart TD
    A[START] --> B[Agent Node]
    B --> C[Tool Node]
    C --> D[Evaluator Node]

    D -->|Retry| B
    D -->|Success| E[END]
```

Introduciremos **LangGraph** para estructurar:

- State;
- Nodes;
- Edges;
- Conditional Routing;
- Checkpoints;
- Guardrails;
- Human-in-the-loop;
- observabilidad.

Objetivo:

> Entender por qué necesitamos un **Agent Runtime** cuando el loop empieza a crecer.

---

# Stack del Basic

La versión actual utiliza:

- Python
- Jupyter Notebook
- DuckDB
- Ollama
- Mistral
- OpenAI Python SDK

La arquitectura es completamente local:

```mermaid
flowchart LR
    A[Jupyter Notebook] --> B[Python]
    B --> C[DuckDB]
    B --> D[OpenAI SDK]
    D --> E[Ollama]
    E --> F[Mistral]
```

Ollama expone el modelo local mediante una API compatible con OpenAI.

Esto permite mantener una interfaz conocida:

```python
from openai import OpenAI
```

sin depender de un servicio cloud para ejecutar la demo.

---

# Más allá de SQL

SQL es solamente el primer laboratorio.

El patrón puede aplicarse a muchos otros problemas.

| Dominio | Loop |
|---|---|
| Código | Generate → Test → Error → Fix |
| Datos | Transform → Validate → Quality Check → Retry |
| Infraestructura | Generate → Validate → Policy Check → Fix |
| Testing | Generate → Execute → Observe → Improve |
| Seguridad | Analyze → Detect → Remediate → Verify |
| Research | Search → Evaluate → Identify Gaps → Search Again |

Todos comparten una estructura similar:

```mermaid
flowchart TD
    A[Goal] --> B[Action]
    B --> C[Observation]
    C --> D[Evaluation]

    D -->|Continue| E[Feedback]
    E --> B

    D -->|Success| F[Done]
```

Ese patrón es la razón de ser de **Prompt to Loop**.

---

# Principio del proyecto

> **No le pidas simplemente al modelo una mejor respuesta.**
>
> **Dale al sistema un objetivo, una forma de medir su progreso y la capacidad de volver a intentarlo.**

---

# Ejecutar el Basic

La implementación actual se encuentra en:

```text
01-basic/
```

Consulta:

```text
01-basic/README.md
```

para las instrucciones de instalación y ejecución.

El flujo completo de la demo es:

```mermaid
flowchart TD
    A[Clone Repository] --> B[Setup]
    B --> C[Crear Dataset]
    C --> D[Ejecutar Baseline]
    D --> E[Prompting]
    E --> F[Evaluar Prompting]
    F --> G[Looping]
    G --> H[Iteraciones + Feedback]
    H --> I[Best Query]
```

---

# Seguridad y limitaciones

Este proyecto tiene fines educativos.

Permitir que un LLM ejecute acciones introduce riesgos adicionales. En sistemas productivos deben considerarse, entre otros:

- principio de mínimo privilegio;
- sandboxing;
- validación de acciones;
- límites de iteraciones;
- timeouts;
- observabilidad;
- auditoría;
- control de costos;
- Human-in-the-Loop;
- rollback;
- políticas y guardrails.

> **Looping aumenta la autonomía del sistema. También aumenta la necesidad de gobernarlo.**

---

# Licencia

Este proyecto se distribuye bajo la licencia **MIT**.