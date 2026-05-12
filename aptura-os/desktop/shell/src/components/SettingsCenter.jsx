import { Check, Moon, Palette, Shield, Sun } from "lucide-react";
import { settingsSections } from "../services/systemStatus.js";

const accents = ["#18a999", "#e66f51", "#f0b35a", "#5d8aa8", "#4f9d69"];

function SettingsCenter({ theme, setTheme, accent, setAccent }) {
  return (
    <section className="panel wide-panel">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">Control</p>
          <h1>Settings</h1>
        </div>
        <Shield size={24} />
      </div>

      <div className="settings-layout">
        <nav className="settings-list" aria-label="Settings sections">
          {settingsSections.map((section) => (
            <button type="button" key={section}>{section}</button>
          ))}
        </nav>

        <div className="settings-detail">
          <section>
            <h2>Appearance</h2>
            <div className="segmented">
              <button className={theme === "light" ? "selected" : ""} type="button" onClick={() => setTheme("light")}>
                <Sun size={17} />
                <span>Light</span>
              </button>
              <button className={theme === "dark" ? "selected" : ""} type="button" onClick={() => setTheme("dark")}>
                <Moon size={17} />
                <span>Dark</span>
              </button>
            </div>
          </section>

          <section>
            <h2>Accent</h2>
            <div className="swatches">
              {accents.map((color) => (
                <button
                  key={color}
                  type="button"
                  title={color}
                  className={accent === color ? "selected" : ""}
                  style={{ background: color }}
                  onClick={() => setAccent(color)}
                >
                  {accent === color ? <Check size={16} /> : null}
                </button>
              ))}
            </div>
          </section>

          <section className="settings-card">
            <Palette size={20} />
            <div>
              <strong>Theme package</strong>
              <span>aptura-branding 0.1.0</span>
            </div>
          </section>
        </div>
      </div>
    </section>
  );
}

export default SettingsCenter;
