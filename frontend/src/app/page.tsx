import styles from "./page.module.css";
import MapView from "../components/map-view/map-view";

export default function HomePage() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <MapView />
      </main>
    </div>
  );
}
