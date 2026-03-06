export type CompanyFeatureProperties = {
  companyId: string;
  companyName: string;
  jobCount: number;
  salaryMin: number;
  salaryMax: number;
  city: string;
  state: string;
};

export type GeoJSONPointFeature = {
  type: "Feature";
  id?: string;
  geometry: {
    type: "Point";
    coordinates: [number, number];
  };
  properties: CompanyFeatureProperties;
};

export type GeoJSONFeatureCollection = {
  type: "FeatureCollection";
  features: GeoJSONPointFeature[];
};

export type MapBounds = {
  minLng: number;
  minLat: number;
  maxLng: number;
  maxLat: number;
};