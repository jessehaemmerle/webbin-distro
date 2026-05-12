const apps = [
  { name: "Files", category: "Work", command: "nautilus", key: "FI" },
  { name: "Terminal", category: "System", command: "gnome-terminal", key: "TE" },
  { name: "Settings", category: "System", command: "gnome-control-center", key: "SE" },
  { name: "Install Aptura OS", category: "System", command: "pkexec calamares", key: "IN" },
  { name: "Firefox ESR", category: "Web", command: "firefox-esr", key: "FX" },
  { name: "Aptura Flow", category: "System", command: "aptura-flow --dashboard", key: "AF" },
];

const metrics = [
  ["0", "Telemetry events"],
  ["13", "Debian base"],
  ["5", "Flow surfaces"],
];

const updates = [
  ["Security", "Debian security channel ready", "100%"],
  ["System", "Aptura local packages installed", "72%"],
  ["Firmware", "Manual review recommended", "35%"],
];

const settings = [
  ["Appearance", "Dark interface, Aptura wallpaper, teal accent"],
  ["Privacy", "Recent file history disabled by default"],
  ["Updates", "Unattended security updates prepared"],
  ["Installer", "Calamares with Debian-compatible GRUB settings"],
];

const view = document.querySelector("#view");
const search = document.querySelector("#search");
const navButtons = [...document.querySelectorAll("[data-view]")];

function card(title, body) {
  return `<section class="panel"><h2>${title}</h2><p>${body}</p></section>`;
}

function renderDashboard() {
  view.innerHTML = `
    <section class="hero-band">
      <div>
        <h1>Aptura Flow</h1>
        <p>System dashboard for Aptura OS with launcher, update state, settings, and first-run surfaces.</p>
      </div>
      <button class="action-button" type="button" data-jump="launcher">Open Launcher</button>
    </section>
    <section class="metric-grid">
      ${metrics.map(([value, label]) => `<div class="metric"><strong>${value}</strong><span>${label}</span></div>`).join("")}
    </section>
    <section class="panel-grid">
      ${card("System", "GNOME Shell base with Aptura-owned defaults and package integration.")}
      ${card("Installer", "Bootloader configuration is aligned with Debian GRUB and BIOS/UEFI partition modes.")}
      ${card("Branding", "Wallpaper, icons, Plymouth, login surfaces, and GRUB menu metadata ship as package assets.")}
    </section>
  `;
}

function renderLauncher() {
  const term = search.value.trim().toLowerCase();
  const filtered = apps.filter((app) => [app.name, app.category, app.command].join(" ").toLowerCase().includes(term));
  view.innerHTML = `
    <section class="hero-band">
      <div>
        <h1>Launcher</h1>
        <p>${filtered.length} app entries</p>
      </div>
      <span class="tag">System app</span>
    </section>
    <section class="app-list">
      ${filtered.map((app) => `
        <article class="app-row">
          <div class="app-icon">${app.key}</div>
          <div>
            <h3>${app.name}</h3>
            <code>${app.command}</code>
          </div>
          <span class="tag">${app.category}</span>
        </article>
      `).join("") || card("No Results", "No matching app entries.")}
    </section>
  `;
}

function renderUpdates() {
  view.innerHTML = `
    <section class="hero-band">
      <div>
        <h1>Updates</h1>
        <p>Package channels and system readiness at a glance.</p>
      </div>
      <button class="action-button secondary" type="button" data-jump="settings">Review Settings</button>
    </section>
    <section class="panel-grid">
      ${updates.map(([title, body, value]) => `
        <section class="panel">
          <h2>${title}</h2>
          <p>${body}</p>
          <div class="progress" aria-label="${title} readiness"><span style="--value: ${value}"></span></div>
        </section>
      `).join("")}
    </section>
  `;
}

function renderSettings() {
  view.innerHTML = `
    <section class="hero-band">
      <div>
        <h1>Settings</h1>
        <p>Aptura defaults that are installed with the desktop package set.</p>
      </div>
      <span class="tag">Aptura 0.1</span>
    </section>
    <section class="panel-grid">
      ${settings.map(([title, body]) => card(title, body)).join("")}
    </section>
  `;
}

function renderWelcome() {
  view.innerHTML = `
    <section class="hero-band">
      <div>
        <h1>Welcome</h1>
        <p>Aptura OS is ready for installation, package testing, and desktop iteration.</p>
      </div>
      <button class="action-button" type="button" data-jump="updates">Check Updates</button>
    </section>
    <section class="panel-grid">
      ${card("Base", "Debian Stable with Aptura packages layered through the local image build.")}
      ${card("Flow", "A packaged dashboard opens from the desktop shell and application launcher.")}
      ${card("Identity", "Aptura branding is installed through Debian packages instead of ad-hoc live hooks.")}
    </section>
  `;
}

const renderers = {
  dashboard: renderDashboard,
  launcher: renderLauncher,
  updates: renderUpdates,
  settings: renderSettings,
  welcome: renderWelcome,
};

function setView(name) {
  const next = renderers[name] ? name : "dashboard";
  navButtons.forEach((button) => button.classList.toggle("active", button.dataset.view === next));
  window.location.hash = next;
  renderers[next]();
}

navButtons.forEach((button) => {
  button.addEventListener("click", () => setView(button.dataset.view));
});

search.addEventListener("input", () => {
  if (window.location.hash === "#launcher") {
    renderLauncher();
  }
});

view.addEventListener("click", (event) => {
  const jump = event.target.closest("[data-jump]");
  if (jump) setView(jump.dataset.jump);
});

window.addEventListener("hashchange", () => setView(window.location.hash.slice(1)));

setView(window.location.hash.slice(1) || "dashboard");
