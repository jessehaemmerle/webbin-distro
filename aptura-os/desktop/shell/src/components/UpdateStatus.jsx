import { Download, ShieldAlert } from "lucide-react";
import { updateState } from "../services/systemStatus.js";

function UpdateStatus() {
  return (
    <section className="panel update-panel">
      <div className="panel-heading compact">
        <div>
          <p className="eyebrow">APT</p>
          <h2>Updates</h2>
        </div>
        <ShieldAlert size={20} />
      </div>

      <div className="update-ring">
        <strong>{updateState.available}</strong>
        <span>ready</span>
      </div>

      <dl className="status-list">
        <div>
          <dt>Security</dt>
          <dd>{updateState.security}</dd>
        </div>
        <div>
          <dt>Checked</dt>
          <dd>{updateState.lastChecked}</dd>
        </div>
        <div>
          <dt>Channel</dt>
          <dd>{updateState.channel}</dd>
        </div>
      </dl>

      <button className="primary-action full" type="button">
        <Download size={18} />
        <span>Review updates</span>
      </button>
    </section>
  );
}

export default UpdateStatus;
