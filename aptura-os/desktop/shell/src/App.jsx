import { useMemo, useState } from "react";
import {
  Bell,
  Command,
  LayoutDashboard,
  Monitor,
  Palette,
  Search,
  Settings,
  ShieldCheck,
  Sparkles,
  SunMoon,
} from "lucide-react";
import Dashboard from "./components/Dashboard.jsx";
import AppLauncher from "./components/AppLauncher.jsx";
import QuickSettings from "./components/QuickSettings.jsx";
import NotificationCenter from "./components/NotificationCenter.jsx";
import WorkspaceOverview from "./components/WorkspaceOverview.jsx";
import SettingsCenter from "./components/SettingsCenter.jsx";
import UpdateStatus from "./components/UpdateStatus.jsx";
import WelcomeWizard from "./components/WelcomeWizard.jsx";
import { apps } from "./services/systemStatus.js";

const tabs = [
  { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
  { id: "launcher", label: "Launcher", icon: Command },
  { id: "workspaces", label: "Spaces", icon: Monitor },
  { id: "settings", label: "Settings", icon: Settings },
  { id: "welcome", label: "Welcome", icon: Sparkles },
];

function App() {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [query, setQuery] = useState("");
  const [theme, setTheme] = useState("dark");
  const [accent, setAccent] = useState("#18a999");

  const filteredApps = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    if (!normalized) return apps;
    return apps.filter((app) => {
      return [app.name, app.category, app.command].some((value) =>
        value.toLowerCase().includes(normalized),
      );
    });
  }, [query]);

  return (
    <main className="flow-root" data-theme={theme} style={{ "--accent": accent }}>
      <aside className="flow-sidebar" aria-label="Aptura Flow navigation">
        <div className="brand">
          <img src="/aptura-mark.svg" alt="" />
          <div>
            <strong>Aptura</strong>
            <span>Flow</span>
          </div>
        </div>

        <nav className="tab-list">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                className={activeTab === tab.id ? "active" : ""}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                title={tab.label}
              >
                <Icon size={20} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </nav>

        <div className="trust-card">
          <ShieldCheck size={20} />
          <span>No telemetry</span>
        </div>
      </aside>

      <section className="flow-main">
        <header className="topbar">
          <label className="search-box">
            <Search size={18} />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search apps, files, settings"
            />
          </label>

          <div className="topbar-actions">
            <button type="button" title="Notifications" onClick={() => setActiveTab("dashboard")}>
              <Bell size={19} />
            </button>
            <button
              type="button"
              title="Theme"
              onClick={() => setTheme((current) => (current === "dark" ? "light" : "dark"))}
            >
              <SunMoon size={19} />
            </button>
            <button
              type="button"
              title="Accent"
              onClick={() => setAccent((current) => (current === "#18a999" ? "#e66f51" : "#18a999"))}
            >
              <Palette size={19} />
            </button>
          </div>
        </header>

        <div className="content-grid">
          {activeTab === "dashboard" && (
            <>
              <Dashboard onOpenLauncher={() => setActiveTab("launcher")} />
              <QuickSettings />
              <UpdateStatus />
              <NotificationCenter />
            </>
          )}

          {activeTab === "launcher" && <AppLauncher apps={filteredApps} query={query} />}
          {activeTab === "workspaces" && <WorkspaceOverview />}
          {activeTab === "settings" && <SettingsCenter theme={theme} setTheme={setTheme} accent={accent} setAccent={setAccent} />}
          {activeTab === "welcome" && <WelcomeWizard />}
        </div>
      </section>
    </main>
  );
}

export default App;
