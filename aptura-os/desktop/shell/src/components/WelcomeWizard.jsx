import { CheckCircle2, ChevronRight, Languages, LockKeyhole, Palette, Wifi } from "lucide-react";

const steps = [
  { title: "Connect", detail: "Wi-Fi ready", icon: Wifi, complete: true },
  { title: "Language", detail: "English", icon: Languages, complete: true },
  { title: "Privacy", detail: "Local defaults", icon: LockKeyhole, complete: true },
  { title: "Look", detail: "Aptura dark", icon: Palette, complete: false },
];

function WelcomeWizard() {
  return (
    <section className="panel wide-panel">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">First run</p>
          <h1>Welcome</h1>
        </div>
        <button className="primary-action" type="button">
          <span>Start</span>
          <ChevronRight size={18} />
        </button>
      </div>

      <div className="wizard-steps">
        {steps.map((step) => {
          const Icon = step.icon;
          return (
            <article className={step.complete ? "wizard-step complete" : "wizard-step"} key={step.title}>
              <Icon size={22} />
              <div>
                <strong>{step.title}</strong>
                <span>{step.detail}</span>
              </div>
              {step.complete ? <CheckCircle2 size={19} /> : <ChevronRight size={19} />}
            </article>
          );
        })}
      </div>
    </section>
  );
}

export default WelcomeWizard;
