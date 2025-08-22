from fastapi import FastAPI
from prometheus_client import Counter, generate_latest
from starlette.responses import Response

app = FastAPI()

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    from metrics import REQUEST_COUNT
    return Response(generate_latest(REQUEST_COUNT), media_type="text/plain")
