import { Activity, BatteryCharging, CalendarDays, HardDrive, Rocket, Wifi } from "lucide-react";

const stats = [
  { label: "Network", value: "Connected", icon: Wifi },
  { label: "Power", value: "Balanced", icon: BatteryCharging },
  { label: "Storage", value: "74% free", icon: HardDrive },
  { label: "Session", value: "Wayland", icon: Activity },
];

function Dashboard({ onOpenLauncher }) {
  return (
    <section className="panel dashboard-panel">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">Today</p>
          <h1>Good workspace</h1>
        </div>
        <button className="primary-action" type="button" onClick={onOpenLauncher}>
          <Rocket size={18} />
          <span>Launch</span>
        </button>
      </div>

      <div className="focus-strip">
        <CalendarDays size={22} />
        <div>
          <strong>Build review</strong>
          <span>10:30 to 11:00</span>
        </div>
      </div>

      <div className="stat-grid">
        {stats.map((item) => {
          const Icon = item.icon;
          return (
            <article className="stat-tile" key={item.label}>
              <Icon size={22} />
              <span>{item.label}</span>
              <strong>{item.value}</strong>
            </article>
          );
        })}
      </div>
    </section>
  );
}

export default Dashboard;
