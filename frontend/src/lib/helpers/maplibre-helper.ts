
import { LngLatBounds } from "maplibre-gl";

import { MapBounds } from "../types/map-view-types";

export function toBoundsObject(bounds: LngLatBounds): MapBounds {
  const sw = bounds.getSouthWest();
  const ne = bounds.getNorthEast();

  return {
    minLng: sw.lng,
    minLat: sw.lat,
    maxLng: ne.lng,
    maxLat: ne.lat,
  };
}
