import { Maximize2, Plus } from "lucide-react";
import { workspaces } from "../services/systemStatus.js";

function WorkspaceOverview() {
  return (
    <section className="panel wide-panel">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">Spaces</p>
          <h1>Workspaces</h1>
        </div>
        <button className="icon-label" type="button">
          <Plus size={18} />
          <span>New</span>
        </button>
      </div>

      <div className="workspace-grid">
        {workspaces.map((space) => (
          <article className="workspace-card" key={space.id}>
            <header>
              <strong>{space.name}</strong>
              <Maximize2 size={16} />
            </header>
            <div className="window-stack">
              {space.windows.length === 0 ? (
                <span className="window empty">Empty</span>
              ) : (
                space.windows.map((window) => (
                  <span className="window" key={window}>{window}</span>
                ))
              )}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

export default WorkspaceOverview;
