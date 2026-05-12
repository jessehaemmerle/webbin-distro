import { Bluetooth, Gauge, Moon, RefreshCw, Volume2, Wifi, Zap } from "lucide-react";
import { quickActions } from "../services/systemStatus.js";

const icons = {
  wifi: Wifi,
  bluetooth: Bluetooth,
  vpn: Gauge,
  theme: Moon,
  updates: RefreshCw,
  power: Zap,
};

function QuickSettings() {
  return (
    <section className="panel">
      <div className="panel-heading compact">
        <div>
          <p className="eyebrow">Controls</p>
          <h2>Quick settings</h2>
        </div>
      </div>

      <div className="quick-grid">
        {quickActions.map((action) => {
          const Icon = icons[action.id] ?? Gauge;
          return (
            <button className={action.active ? "quick-toggle active" : "quick-toggle"} type="button" key={action.id}>
              <Icon size={18} />
              <span>{action.label}</span>
              <small>{action.value}</small>
            </button>
          );
        })}
      </div>

      <div className="slider-row">
        <Volume2 size={18} />
        <input aria-label="Volume" type="range" min="0" max="100" defaultValue="64" />
      </div>
    </section>
  );
}

export default QuickSettings;
