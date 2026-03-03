import styles from "./page.module.css";
import MapView from "./components/map-view";

export default function Home() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <MapView className={styles.map} />
      </main>
    </div>
  );
}
