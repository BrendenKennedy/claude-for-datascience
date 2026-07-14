# Working against a remote GPU box over SSH

The scaffold's baseline is "NVIDIA GPU, local **or** over SSH". This is the how for the SSH case —
the stable conventions, not per-project config (hosts and paths live in `.env` / `~/.ssh/config`).

## One-time: the host alias
```
# ~/.ssh/config
Host gpu-box
    HostName <ip-or-dns>
    User <user>
    # ForwardAgent yes        # if you git-push from the box
```
Everything below assumes `ssh gpu-box` works without a password (use `ssh-copy-id`).

## Code gets there by git, data by DVC — not rsync
- **Code:** commit/push locally, `git pull` on the box. For quick iteration on *uncommitted* work:
  `rsync -av --exclude-from=.gitignore ./ gpu-box:~/proj/` — the exclude keeps `.venv/`, `data/`,
  and `mlruns/` from traveling.
- **Data:** `dvc pull` **on the box** (see `data-dvc`) — the remote store is the transport. Never
  rsync datasets box-to-box; that forks provenance.
- **Env:** `uv sync --frozen` on the box reproduces the locked env. ARM box? The torch index note
  in `env-uv` applies there, not on your laptop.

## Long runs survive the SSH session: tmux
```bash
ssh gpu-box
tmux new -s train          # ... start the run inside ...
# detach: Ctrl-b d — reattach later: tmux attach -t train
```
A run started on a bare SSH session dies with the connection. Always tmux (or `nohup ... &` at
minimum) for anything longer than a smoke.

## See the UIs from your laptop: port-forward
```bash
ssh -L 5000:localhost:5000 gpu-box   # MLflow UI running on the box → http://localhost:5000
ssh -L 8888:localhost:8888 gpu-box   # Jupyter on the box (see the notebooks skill)
```
Metrics need no forwarding if the tracker is a shared server (or W&B) — only box-local UIs do.

## Sanity checks before blaming the code
`nvidia-smi` (driver up, memory free), then the `env-uv` GPU sanity one-liner
(`uv run python -c "import torch; print(torch.cuda.is_available())"`). Wrong wheel for the
box's CUDA/arch is the most common "GPU not found" — the matrix in `env-uv` resolves it.
