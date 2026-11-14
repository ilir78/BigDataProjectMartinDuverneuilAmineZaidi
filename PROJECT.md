# IMDb Big Data Project

## Team

| Member | Email | GitHub username |
| --- | --- | --- |
| Martin Duverneuil | tinmar.duverneuil78@gmail.com | Ilir78 |
| Amine Zaidi | amine.zaidi@edu.ece.fr | aminezdi |

Group: **Gr.2**.

## Environment

This project uses Docker Compose, Apache Spark 3.5, and Kafka. Spark and its Java runtime run inside the official Spark container. IMDb publishes gzipped TSV files with `\\N` as its null marker; use them only under IMDb's non-commercial terms. The project does not redistribute the dumps.

```powershell
cd outputs/imdb-big-data
Copy-Item .env.example .env
docker compose --profile spark build spark
```

Docker Desktop (Linux containers) is required. Download the current IMDb dumps by running:

```powershell
docker compose --profile spark run --rm --entrypoint python3 spark scripts/download_imdb.py
```

The downloader fetches the seven required files from the official IMDb dataset host and skips files already present.

Run batch preparation and analyses:

```powershell
docker compose --profile spark run --rm spark prepare
docker compose --profile spark run --rm spark explore
docker compose --profile spark run --rm spark enrich
```

After `prepare` and `explore` finish, copy their final CSV outputs into tracked report tables:

```powershell
python scripts/export_report_tables.py
```

Start the local Kafka broker and stream pipeline (Docker required):

```powershell
docker compose up -d kafka
```

In the first terminal, start the Spark consumer. In a second terminal, start the Wikipedia event producer. Keep both running for the required 15–30 minute window:

```powershell
docker compose --profile spark run --rm spark stream
```

```powershell
docker compose --profile spark run --rm --no-deps --entrypoint python3 spark scripts/wikipedia_to_kafka.py
```

After the window, stop the producer with Ctrl+C first, then stop the Spark consumer with Ctrl+C. The project filters English Wikipedia main-namespace edits with film, movie, television, actor, actress, director, cinema, series, or IMDb terms. It checkpoints progress and records per-batch counts in `data/processed/stream_metrics.jsonl`.

Batch outputs are written under `data/processed/` and `reports/results/`; checkpoint files are under `data/checkpoints/`. Keep data, checkpoints, credentials, and `.env` out of Git. Stop Kafka with `docker compose down`.

The enrichment collector uses Wikipedia's public MediaWiki API, supplies a descriptive User-Agent with contact details, caches each collected record, observes a one-second pause per entity, and honors Retry-After on 429/503 responses. Set a real contact address in `.env` before collection. Keep the returned page URL with any reused excerpt for attribution.

## AI tool declaration

Codex (OpenAI) assisted with implementation of project code and this execution guide. AI was not used to write the reasoning or methodological explanations in `REPORT.md`; the assignment prohibits AI-generated report explanations. Team members must write those sections themselves and review every result.

## Git workflow

Create one feature branch per task, push it, and open a pull request. Obtain at least one group-member approval before merging. Do not commit directly to `main`. Record group and member usernames in the top-level `README.md` and submit the repository link by email per the course README.
