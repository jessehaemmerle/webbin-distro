import { Bell, CheckCircle2, Info, TriangleAlert } from "lucide-react";
import { notifications } from "../services/systemStatus.js";

const toneIcon = {
  ok: CheckCircle2,
  attention: TriangleAlert,
  neutral: Info,
};

function NotificationCenter() {
  return (
    <section className="panel">
      <div className="panel-heading compact">
        <div>
          <p className="eyebrow">Inbox</p>
          <h2>Notifications</h2>
        </div>
        <Bell size={20} />
      </div>

      <div className="notification-list">
        {notifications.map((item) => {
          const Icon = toneIcon[item.tone];
          return (
            <article className={`notification ${item.tone}`} key={item.id}>
              <Icon size={18} />
              <div>
                <strong>{item.title}</strong>
                <span>{item.body}</span>
              </div>
              <time>{item.time}</time>
            </article>
          );
        })}
      </div>
    </section>
  );
}

export default NotificationCenter;
