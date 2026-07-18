---
name: llm-eval
description: >
  Evaluating LLMs and fine-tunes — task metrics over loss, decontaminated held-out sets, benchmark
  harnesses, and judge discipline. Carries: eval-set decontamination against training data,
  task metrics (exact match / F1 / pass@k — perplexity is not quality), lm-eval-harness for
  standard benchmarks, LLM-as-judge rules (pairwise with position swap; never judge with the tuned
  model or its base family; calibrate the judge against a human-scored sample), golden-prompt
  regression suites, deterministic decoding for evals (temperature 0, seeded, params logged), and
  base-vs-tuned comparison on the same harness. Load when scoring a fine-tune, choosing
  benchmarks, or building an LLM eval loop. Triggers: llm eval, evaluate the fine-tune, benchmark,
  lm-eval-harness, LLM-as-judge, judge model, pass@k, exact match, perplexity, contamination,
  golden prompts, regression suite, win rate, rubric scoring, compare to base model.
---

# llm-eval — measuring LLMs without fooling yourself

**Pinned:** lm-eval (EleutherAI harness) — unpinned · authored 2026-07-18 · run
`/skill-update llm-eval` once the dep is installed

> On-demand: load this when an LLM (usually a `finetune-unsloth` product) needs a number. The CV
> `evaluation` skill's principles carry over — held-out discipline, touch-test-once, error analysis
> over aggregates — but the mechanics differ enough to fail silently if you port them naively.
> Tracking still goes through the active tracker skill; split hygiene is still `datasets`.

## The discipline (what actually goes wrong)
1. **Loss/perplexity is not quality.** Report the task metric a consumer would feel: exact match /
   F1 for extraction, pass@k for code, rubric or win-rate for open-ended generation. Perplexity is
   a training diagnostic, not a deliverable.
2. **Decontaminate before you quote.** Check eval prompts against the SFT set (exact + near-dup,
   e.g. n-gram overlap) and check public benchmarks against the base model's known contamination.
   A fine-tune "beating GPT-x" on prompts it trained on is the LLM lane's leakage.
3. **Evals decode deterministically.** Temperature 0 (or fixed seed + logged sampling params),
   fixed max tokens, fixed stop sequences — logged with the run like any config. A metric that
   moves between identical runs isn't a metric.
4. **Always run the base model on the same harness.** The deliverable is the *delta* — tuned vs
   base under identical prompts/decoding. Without it you can't tell fine-tuning from the base
   model's existing ability.

## Standard benchmarks — lm-eval-harness
`uv add lm-eval`, then e.g.:
```bash
uv run lm_eval --model hf --model_args pretrained=<dir_or_hub_id> \
  --tasks <task1>,<task2> --batch_size auto --seed 1234 --log_samples --output_path eval/
```
`--log_samples` keeps per-item outputs — that's your error-analysis raw material, not just the
headline table. Log the results JSON to the tracker as an artifact.

## Custom / task evals
- Build a **golden-prompt regression suite** for the actual use case: fixed prompts + expected
  behavior (exact answers where checkable; a rubric where not). Version it with the dataset
  (`data-dvc`); run it on every candidate checkpoint like a test suite — regressions on goldens
  block promotion (`tracking-mlflow` registry alias moves are gated on this evidence).
- Grade programmatically wherever possible (parse the answer, compare) — judges are the fallback,
  not the default.

## LLM-as-judge — usable, with controls
- **Pairwise, position-swapped:** judge A-vs-B twice with the order flipped; a verdict that flips
  with position is a tie. Absolute 1–10 scores drift; comparisons are stabler.
- **Independence:** never judge with the model being evaluated, and avoid its own base family
  (self-preference bias). Use a stronger, unrelated model.
- **Calibrate:** hand-score a sample (~50 items) and measure judge–human agreement before trusting
  the judge at scale; report that agreement next to any judge-derived number.

## Gotchas
- **Chat template mismatch at eval time** silently tanks scores exactly like it does in training —
  the harness must apply the same template the fine-tune used.
- **pass@k needs n>k samples** and temperature >0 *for the sampling* — that's the one place
  determinism yields; fix the seed and report n, k, and temperature.
- A tuned model that improves on goldens but regresses on general benchmarks has overfit its SFT
  distribution — report both, decide deliberately (decision log), don't cherry-pick.
