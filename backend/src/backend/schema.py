from typing import Literal
from pydantic import BaseModel


class CompanyProperties(BaseModel):
    companyId: str
    companyName: str
    jobCount: int
    salaryMin: int
    salaryMax: int
    city: str
    state: str


class PointGeometry(BaseModel):
    type: Literal["Point"] = "Point"
    coordinates: tuple[float, float]  # [lng, lat]


class CompanyFeature(BaseModel):
    type: Literal["Feature"] = "Feature"
    id: str
    geometry: PointGeometry
    properties: CompanyProperties


class JobSearchResponse(BaseModel):
    type: Literal["FeatureCollection"] = "FeatureCollection"
    features: list[CompanyFeature]