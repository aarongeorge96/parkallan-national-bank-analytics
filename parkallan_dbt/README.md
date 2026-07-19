\# Parkallan dbt Project



This is the dbt Core transformation layer for the Parkallan National Bank Retail Analytics Platform.



\*\*For full project documentation\*\* — architecture, data model, testing strategy, business insights, and setup instructions — see the \[root README](../README.md).



\## Quick reference



```bash

dbt run             # build all staging, intermediate, and mart models

dbt run --select staging.\*        # build just the staging layer

dbt run --select marts.\*          # build just the marts layer

dbt test             # run all 100 schema tests

dbt test --select staging.\*       # run just staging tests (71)

dbt test --select marts.\*         # run just mart tests (29)

dbt docs generate \&\& dbt docs serve   # generate and view the auto-documentation site

```



\## Layer summary



| Layer | Models | Purpose |

|---|---|---|

| `models/staging/` | 7 | 1:1 cleaned/renamed raw tables, tested for quality |

| `models/intermediate/` | 4 | Reusable business logic, computed once |

| `models/marts/` | 9 | BI-ready tables, one per business question, tested for grain and relationships |

