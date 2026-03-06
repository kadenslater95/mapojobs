from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

from backend.schema import JobSearchResponse

app = FastAPI(title="MapoJobs API")

# Dev-only CORS. Lock this down later.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, bool]:
    return {"ok": True}


@app.get("/api/jobs/search", response_model=JobSearchResponse)
def search_jobs(
    min_lng: float = Query(...),
    min_lat: float = Query(...),
    max_lng: float = Query(...),
    max_lat: float = Query(...),
):
    """
    Stub endpoint for the current map bounds.
    For now, ignore the bbox and return a few hard-coded features.
    Later this is where you will:
    - validate bbox / zoom level
    - check cache / DB
    - query aggregated job data
    - return GeoJSON
    """

    stub = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "id": "company-1",
                "geometry": {
                    "type": "Point",
                    "coordinates": [-94.5786, 39.0997],  # Kansas City-ish
                },
                "properties": {
                    "companyId": "company-1",
                    "companyName": "Acme Software",
                    "jobCount": 12,
                    "salaryMin": 95000,
                    "salaryMax": 140000,
                    "city": "Kansas City",
                    "state": "MO",
                },
            },
            {
                "type": "Feature",
                "id": "company-2",
                "geometry": {
                    "type": "Point",
                    "coordinates": [-94.8191, 38.8814],  # Olathe-ish
                },
                "properties": {
                    "companyId": "company-2",
                    "companyName": "Prairie Data",
                    "jobCount": 7,
                    "salaryMin": 85000,
                    "salaryMax": 125000,
                    "city": "Olathe",
                    "state": "KS",
                },
            },
            {
                "type": "Feature",
                "id": "company-3",
                "geometry": {
                    "type": "Point",
                    "coordinates": [-94.6708, 38.9822],  # Overland Park-ish
                },
                "properties": {
                    "companyId": "company-3",
                    "companyName": "Mapo Logistics",
                    "jobCount": 4,
                    "salaryMin": 70000,
                    "salaryMax": 105000,
                    "city": "Overland Park",
                    "state": "KS",
                },
            },
        ],
    }

    return stub