# Prompt to Loop

Proyecto educativo para entender la evolución desde **Prompting** hacia **Looping** y sistemas agentic.

La idea central es simple:

```text
Prompting
Prompt → LLM → Response

Looping
Goal → Action → Observation → Evaluation → Retry / Done
```

El proyecto está diseñado para avanzar progresivamente desde implementaciones simples y transparentes hasta arquitecturas más estructuradas con herramientas de orquestación.

## Roadmap

| Nivel    | Objetivo                                     | Estado          |
| -------- | -------------------------------------------- | --------------- |
| Basic    | Entender Prompting → Looping con Python puro | ✅ Disponible    |
| Advanced | Incorporar State, Tools y evaluación técnica | 🚧 Próximamente |
| Pro      | Implementar el flujo con LangGraph           | 📌 Planeado     |

## 01 — Basic

El primer laboratorio utiliza un caso de optimización SQL sobre un escenario simplificado de tarjetas de crédito.

El sistema intenta optimizar una consulta mediante un ciclo:

```text
Goal
 ↓
LLM
 ↓
SQL Candidate
 ↓
Execute
 ↓
Validate
 ↓
Benchmark
 ↓
Goal achieved?
 ├── No → Feedback → Retry
 └── Yes → Done
```

Stack:

* Python
* Jupyter Notebook
* DuckDB
* Ollama
* Mistral
* OpenAI-compatible API

Consulta la documentación específica en:

```text
01-basic/README.md
```

## Filosofía del proyecto

El objetivo no es esconder el comportamiento del agente detrás de frameworks.

Primero construimos manualmente:

```text
Loop
State
Feedback
Evaluation
Stop Conditions
```

y luego evolucionamos hacia herramientas que permiten administrar estos patrones de forma más estructurada.

## Uso

Clona el repositorio:

```bash
git clone https://github.com/Codenid/prompt-to-loop.git
cd prompt-to-loop
```

Luego ingresa al laboratorio:

```bash
cd 01-basic
```

y sigue las instrucciones de su `README.md`.

## Disclaimer

Este proyecto tiene fines educativos.

No ejecutes SQL generado por modelos de lenguaje directamente sobre bases de datos productivas sin controles adecuados de permisos, validación, seguridad, observabilidad y gobierno.
