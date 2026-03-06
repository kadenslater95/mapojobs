import type { GeoJSONFeatureCollection, MapBounds } from "../types/map-view-types";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

export async function fetchJobsForBounds(
  bounds: MapBounds
): Promise<GeoJSONFeatureCollection> {
  if (!API_BASE_URL) {
    throw new Error("NEXT_PUBLIC_API_BASE_URL is not configured");
  }

  const params = new URLSearchParams({
    min_lng: String(bounds.minLng),
    min_lat: String(bounds.minLat),
    max_lng: String(bounds.maxLng),
    max_lat: String(bounds.maxLat),
  });

  const response = await fetch(`${API_BASE_URL}/api/jobs/search?${params.toString()}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error(`Backend request failed: ${response.status}`);
  }

  const data = (await response.json()) as GeoJSONFeatureCollection;
  return data;
}
