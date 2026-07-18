---
name: serving
description: >
  Shipping a model — batch scoring jobs and online endpoints. Carries: the batch-first bias (a
  scheduled scoring job beats an endpoint whenever latency isn't a stated requirement), the
  endpoint shape (load the model ONCE at startup from the registry alias `models:/<name>@champion`
  — never per-request), training-serving skew prevention (import the SAME preprocessing module
  training used; never reimplement it), input validation at the boundary (schema mirrors
  training-time assumptions; reject, don't coerce), export paths (ONNX/TorchScript with an
  output-parity check), model version stamped into every prediction, prediction logging wired
  BEFORE launch (the `monitoring` precondition), and latency/throughput basics (batching,
  workers, timeouts). Load when deploying, building an inference endpoint or batch scorer, or
  exporting a model. Triggers: deploy, serve, serving, endpoint, inference API, FastAPI, batch
  scoring, ONNX, TorchScript, export the model, latency, throughput, real-time prediction,
  production, ship the model.
---

# serving — the model meets traffic

> On-demand: load this at deploy time (P6→P7). Which model ships is the registry's alias
> (`tracking-mlflow`), promotion is governed (`model-governance` + decision log), and the moment
> it serves, `monitoring` takes over — this skill is the mechanics between those: the scoring
> path itself. Endpoint auth and what may be logged are `security`/`data-governance` calls.

## First decision: batch beats online until proven otherwise
If predictions are consumed on a cadence (daily scores, nightly QC reports), ship a **scheduled
batch job**: score → write to a table/file → done. No service to keep alive, trivial retries,
easy backfills, and monitoring is just reading the output table. Build an online endpoint only
when a stated latency requirement exists — it's an operational liability you now own 24/7.

## The endpoint shape (when online is justified)
```python
app = FastAPI()

@app.on_event("startup")
def load():                                        # ONCE, at startup — never per-request
    app.state.model = mlflow.pyfunc.load_model(f"models:/{NAME}@champion")
    app.state.version = resolve_version(NAME)      # pin what actually loaded

class Item(BaseModel):                             # the boundary contract
    ...                                            # fields + ranges the TRAINING data assumed

@app.post("/predict")
def predict(item: Item):
    x = preprocess(item)                           # THE training preprocess module, imported
    y = app.state.model.predict(x)
    return {"prediction": y, "model_version": app.state.version}

@app.get("/health")
def health(): return {"ok": True, "model_version": app.state.version}
```
- **Validate at the boundary; reject, don't coerce.** Out-of-range values, unknown categories,
  wrong image sizes → 422 with a reason. Silent coercion turns bad inputs into confident wrong
  predictions.
- **`model_version` rides in every response** — without it, `monitoring`'s logs can't attribute
  drift to a rollout, and incident debugging is archaeology.

## Training–serving skew: the #1 silent killer
The serving path **imports** the training preprocessing (the same `src/<pkg>` functions —
resize/normalize/encode), it never reimplements it. Two implementations *will* diverge (one
resize interpolation flag is enough) and the model quietly degrades with no error anywhere.
Test it: one fixture through the training path and the serving path must produce identical
tensors (add it to the `testing` suite).

## Export (when the runtime can't carry torch)
ONNX / TorchScript export is fine — with a **parity check as a gate**: run N fixtures through
the original and the exported model; max output delta must be ~float tolerance. An export
without a parity check is a different model with the same name. Pin the exported artifact to
its source run (`data-dvc` + run id).

## Launch checklist
Prediction logging wired (inputs sampled, outputs, version — `monitoring` is unbootable
without it) · load basics set deliberately (worker count, request timeout, batch size; measure
p95 under realistic load, don't guess) · rollback = moving the registry alias back (rehearse it
once) · shadow/canary before full traffic (per `monitoring`).
