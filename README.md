---
language:
- ar
tags:
- hassaniya
- mauritania
- dialect
task_categories:
- translation
- text-generation
license: mit
---
# AI for RIM: Hassaniya Dialect Datasets 🇲🇷

This repository contains open-source datasets designed for training and fine-tuning Large Language Models (LLMs) on the **Hassaniya** dialect of Mauritania.

## Datasets

The repository currently hosts two primary datasets in JSONL format, ready for LLM training:

### 1. Translation Dataset (`ar_to_hs_translation.jsonl`)
*   **Content**: Parallel corpus of Standard Arabic to Hassaniya translation pairs.
*   **Size**: ~4,430 pairs.
*   **Format**: Chat-style structure suitable for instruction tuning.
    ```json
    {"messages": [{"role": "user", "content": "Translate the following to Hassaniya: ..."}, {"role": "model", "content": "..."}]}
    ```

### 2. Customer Support Dataset (`hassaniya_customer_support.jsonl`)
*   **Content**: Multi-turn customer support conversations entirely in Hassaniya.
*   **Size**: ~594 conversation turns.
*   **Format**: System, User, and Assistant role structure.
    ```json
    {"messages": [{"role": "system", "content": "..."}, {"role": "user", "content": "..."}, {"role": "model", "content": "..."}]}
    ```

## Goals

The goal of this project is to build foundational resources for Hassaniya NLP and AI, making advanced language technologies accessible to the Mauritanian community.

## Upcoming

*   **Hassaniya Text Normalization Tool**: A standardized tool for normalizing Hassaniya text is currently in development and will be released soon.

## Acknowledgements

Special thanks to **Dr. Ahmed Oumar** for his invaluable guidance, mentorship, and support in making this project possible.
