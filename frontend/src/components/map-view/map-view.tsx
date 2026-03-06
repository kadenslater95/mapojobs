"use client";

import { useEffect, useState, useRef } from "react";
import maplibregl from "maplibre-gl";

import { fetchJobsForBounds } from "@/lib/api/jobs-api";
import { toBoundsObject } from "@/lib/helpers/maplibre-helper";
import { GeoJSONFeatureCollection } from "@/lib/types/map-view-types";
import styles from "./map-view.module.css";


const SOURCE_ID = "jobs";
const LAYER_ID = "jobs-dots";

const EMPTY_FEATURE_COLLECTION: GeoJSONFeatureCollection = {
  type: "FeatureCollection",
  features: [],
};


export default function MapView() {
  const mapContainerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasPendingAreaSearch, setHasPendingAreaSearch] = useState(false);

  useEffect(() => {
    if (!mapContainerRef.current || mapRef.current) return;

    const map = new maplibregl.Map({
      container: mapContainerRef.current,
      style: {
        version: 8,
        sources: {
          osm: {
            type: 'raster',
            tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
            tileSize: 256,
            attribution: '&copy; OpenStreetMap contributors'
          }
        },
        layers: [
          { id: 'osm', type: 'raster', source: 'osm' }
        ]
      },
      center: [-94.58, 39.08],
      zoom: 10
    });

    mapRef.current = map;

    map.addControl(new maplibregl.NavigationControl(), "top-right");

    map.on("load", async () => {
      let isFetching = false;

      map.addSource(SOURCE_ID, {
        type: "geojson",
        data: EMPTY_FEATURE_COLLECTION,
      });

      map.addLayer({
        id: LAYER_ID,
        type: "circle",
        source: SOURCE_ID,
        paint: {
          "circle-radius": [
            "interpolate",
            ["linear"],
            ["get", "jobCount"],
            1, 6,
            5, 10,
            10, 14,
            20, 18,
          ],
          "circle-color": "#2563eb",
          "circle-opacity": 0.8,
          "circle-stroke-width": 1,
          "circle-stroke-color": "#ffffff",
        },
      });

      const loadData = async () => {
        if (isFetching) return;

        try {
          isFetching = true;
          setLoading(true);
          setError(null);

          const bounds = toBoundsObject(map.getBounds());
          const data = await fetchJobsForBounds(bounds);

          const source = map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource | undefined;
          source?.setData(data);
          setHasPendingAreaSearch(false);
        } catch (err) {
          const message =
            err instanceof Error ? err.message : "Unknown error loading jobs";
          setError(message);
        } finally {
          isFetching = false;
          setLoading(false);
        }
      };

      await loadData();

      map.on("moveend", () => {
        setHasPendingAreaSearch(true);
      });

      map.on("click", LAYER_ID, (e) => {
        const feature = e.features?.[0];
        if (!feature) return;

        const props = feature.properties as unknown as {
          companyName: string;
          jobCount: number;
          city: string;
          state: string;
          salaryMin: number;
          salaryMax: number;
        };

        new maplibregl.Popup()
          .setLngLat((feature.geometry as GeoJSON.Point).coordinates as [number, number])
          .setHTML(`
            <div style="min-width: 220px; background-color: #ccc; color: #000;">
              <strong>${props.companyName}</strong><br />
              ${props.city}, ${props.state}<br />
              Jobs: ${props.jobCount}<br />
              Salary: $${Number(props.salaryMin).toLocaleString()} - $${Number(props.salaryMax).toLocaleString()}
            </div>
          `)
          .addTo(map);
      });

      map.on("mouseenter", LAYER_ID, () => {
        map.getCanvas().style.cursor = "pointer";
      });

      map.on("mouseleave", LAYER_ID, () => {
        map.getCanvas().style.cursor = "";
      });
    });

    return () => {
      mapRef.current = null;
      map.remove();
    };
  }, []);

  const handleSearchThisArea = async () => {
    const map = mapRef.current;
    if (!map || loading) return;

    try {
      setLoading(true);
      setError(null);

      const bounds = toBoundsObject(map.getBounds());
      const data = await fetchJobsForBounds(bounds);

      const source = map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource | undefined;
      source?.setData(data);
      setHasPendingAreaSearch(false);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Unknown error loading jobs";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  
  return (
    <div className={styles.container}>
      <div ref={mapContainerRef} className={styles.map} />
      {hasPendingAreaSearch ? (
        <button
          type="button"
          className={styles.searchAreaButton}
          onClick={handleSearchThisArea}
          disabled={loading}
        >
          Search This Area
        </button>
      ) : null}
      {loading ? <div className={styles.status}>Loading jobs...</div> : null}
      {error ? <div className={styles.error}>{error}</div> : null}
    </div>
  );
}
