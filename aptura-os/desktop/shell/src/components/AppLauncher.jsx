import { ExternalLink, SearchX } from "lucide-react";

function AppLauncher({ apps, query }) {
  return (
    <section className="panel wide-panel">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">Launcher</p>
          <h1>Apps</h1>
        </div>
        <span className="count-pill">{apps.length}</span>
      </div>

      {apps.length === 0 ? (
        <div className="empty-state">
          <SearchX size={26} />
          <span>No match for "{query}"</span>
        </div>
      ) : (
        <div className="app-grid">
          {apps.map((app) => (
            <button className="app-tile" type="button" key={app.name}>
              <span className="app-icon" style={{ background: app.color }}>{app.name.slice(0, 1)}</span>
              <span>
                <strong>{app.name}</strong>
                <small>{app.category}</small>
              </span>
              <ExternalLink size={16} />
            </button>
          ))}
        </div>
      )}
    </section>
  );
}

export default AppLauncher;
