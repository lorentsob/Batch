import { useState } from "react";

const green = {
  25:  "#F2FAF7",
  50:  "#E0F4EC",
  100: "#B8E5D0",
  200: "#80CEB0",
  300: "#4AB48E",
  400: "#2A9970",
  500: "#1A7D5A",
  600: "#156349",
  700: "#0F4D38",
  800: "#0A3828",
  900: "#061E16",
};
const neutral = {
  0:   "#FFFFFF",
  50:  "#F7F8F7",
  100: "#EDEEED",
  200: "#DCDEDD",
  300: "#BFC2C0",
  400: "#9CA09E",
  500: "#737876",
};

// ─── TOKEN REFERENCE ─────────────────────────────────────────────────────────
const tokens = {
  // Superfici
  "bg/app":          { val: neutral[50],  note: "Sfondo generale dell'app" },
  "bg/card":         { val: neutral[0],   note: "Sfondo card step (tutte)" },
  "bg/header":       { val: green[500],   note: "Header navigazione" },

  // Testi
  "text/primary":    { val: green[800],   note: "Titoli, nomi step" },
  "text/secondary":  { val: neutral[500], note: "Orari, durate, metadati" },
  "text/on-header":  { val: neutral[0],   note: "Testo bianco su header verde" },
  "text/on-header-sub": { val: "rgba(255,255,255,0.65)", note: "Testo secondario su header" },
  "text/on-cta":     { val: neutral[0],   note: "Testo su pulsante primario" },

  // Bordi card
  "border/default":  { val: neutral[200], note: "Bordo card neutro (done, pending)" },
  "border/active":   { val: green[500],   note: "Bordo card step running" },

  // Badge
  "badge/running-bg":   { val: green[500],   note: "" },
  "badge/running-text": { val: neutral[0],   note: "" },
  "badge/done-bg":      { val: green[50],    note: "" },
  "badge/done-text":    { val: green[600],   note: "" },
  "badge/pending-bg":   { val: neutral[100], note: "" },
  "badge/pending-text": { val: neutral[400], note: "" },

  // CTA
  "cta/primary-bg":   { val: green[500], note: "Pulsante Completa / Avvia" },
  "cta/primary-text": { val: neutral[0], note: "" },

  // Progress
  "progress/track": { val: green[50],  note: "" },
  "progress/fill":  { val: green[500], note: "" },
};

// ─── ANNOTATED SCREEN ────────────────────────────────────────────────────────
function Chip({ color, label }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
      <div style={{
        width: 12, height: 12, borderRadius: 3,
        background: color,
        border: "1px solid rgba(0,0,0,0.08)",
        flexShrink: 0,
      }} />
      <code style={{ fontSize: 10, color: neutral[500], fontFamily: "monospace" }}>{label}</code>
    </div>
  );
}

function Annotation({ top, left, right, lines = [], align = "left" }) {
  const isRight = align === "right";
  return (
    <div style={{
      position: "absolute",
      top, left, right,
      display: "flex",
      flexDirection: isRight ? "row-reverse" : "row",
      alignItems: "flex-start",
      gap: 6,
      pointerEvents: "none",
    }}>
      <div style={{
        width: 24, height: 1,
        background: "rgba(26,125,90,0.4)",
        alignSelf: "center",
        flexShrink: 0,
      }} />
      <div style={{
        background: "rgba(255,255,255,0.96)",
        border: `1px solid ${neutral[200]}`,
        borderRadius: 8,
        padding: "5px 8px",
        display: "flex",
        flexDirection: "column",
        gap: 3,
        boxShadow: "0 2px 8px rgba(0,0,0,0.08)",
      }}>
        {lines.map((l, i) => <Chip key={i} color={l.color} label={l.label} />)}
      </div>
    </div>
  );
}

function AnnotatedScreen() {
  return (
    <div style={{ position: "relative", width: 340 }}>
      {/* Phone */}
      <div style={{
        width: 340,
        background: neutral[50],
        borderRadius: 44,
        overflow: "hidden",
        boxShadow: "0 24px 64px rgba(10,56,40,0.20), 0 0 0 1px rgba(0,0,0,0.07)",
        fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
      }}>
        {/* Status bar */}
        <div style={{ background: green[500], padding: "14px 22px 0", display: "flex", justifyContent: "space-between" }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: neutral[0] }}>9:41</span>
          <div style={{ width: 80, height: 26, background: "rgba(0,0,0,0.25)", borderRadius: 99 }} />
          <span style={{ fontSize: 11, color: "rgba(255,255,255,0.6)" }}>●●●</span>
        </div>

        {/* Header */}
        <div style={{ background: green[500], padding: "12px 20px 24px" }}>
          <div style={{ fontSize: 12, color: "rgba(255,255,255,0.6)", marginBottom: 10 }}>‹ Impasti</div>
          <div style={{ fontSize: 24, fontWeight: 700, color: neutral[0], letterSpacing: "-0.02em", marginBottom: 10 }}>Pane di Campagna</div>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <span style={{ background: "rgba(0,0,0,0.25)", color: neutral[0], borderRadius: 99, padding: "4px 12px", fontSize: 12, fontWeight: 700 }}>in corso</span>
            <span style={{ fontSize: 13, color: "rgba(255,255,255,0.65)" }}>Cottura ore 18:30</span>
          </div>
        </div>

        {/* Content */}
        <div style={{ background: neutral[50], padding: "14px 14px 20px" }}>

          {/* Done */}
          {["Autolisi — ore 10:00 · 45 min", "Impasto — ore 10:50 · 30 min"].map(s => {
            const [name, meta] = s.split(" — ");
            return (
              <div key={name} style={{
                background: neutral[0], border: `1px solid ${neutral[200]}`,
                borderRadius: 16, padding: "12px 14px", marginBottom: 8,
                display: "flex", justifyContent: "space-between", alignItems: "center",
              }}>
                <div>
                  <div style={{ fontSize: 15, fontWeight: 600, color: green[800] }}>{name}</div>
                  <div style={{ fontSize: 12, color: neutral[500] }}>{meta}</div>
                </div>
                <span style={{ background: green[50], color: green[600], borderRadius: 99, padding: "3px 10px", fontSize: 11, fontWeight: 600 }}>done</span>
              </div>
            );
          })}

          {/* Running */}
          <div style={{
            background: neutral[0], border: `2px solid ${green[500]}`,
            borderRadius: 16, padding: "12px 14px", marginBottom: 8,
            boxShadow: `0 4px 16px rgba(26,125,90,0.14)`,
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 4 }}>
              <div>
                <div style={{ fontSize: 16, fontWeight: 700, color: green[800] }}>Puntatura</div>
                <div style={{ fontSize: 12, color: neutral[500] }}>ore 13:20 · 2h 30m</div>
              </div>
              <span style={{ background: green[500], color: neutral[0], borderRadius: 99, padding: "3px 10px", fontSize: 11, fontWeight: 700 }}>in corso</span>
            </div>
            <div style={{ height: 4, background: green[50], borderRadius: 99, margin: "10px 0" }}>
              <div style={{ width: "62%", height: "100%", background: green[500], borderRadius: 99 }} />
            </div>
            <div style={{
              background: green[500], color: neutral[0],
              borderRadius: 12, padding: "12px", fontSize: 15,
              fontWeight: 600, textAlign: "center",
            }}>Completa</div>
          </div>

          {/* Pending */}
          {[
            { name: "Preforma", meta: "ore 15:50 · 20 min" },
            { name: "Appretto", meta: "dom 08:00 · finestra 4h" },
            { name: "Cottura",  meta: "dom 12:30 · 18 min" },
          ].map(s => (
            <div key={s.name} style={{
              background: neutral[0], border: `1px solid ${neutral[200]}`,
              borderRadius: 16, padding: "12px 14px", marginBottom: 8,
              display: "flex", justifyContent: "space-between", alignItems: "center",
            }}>
              <div>
                <div style={{ fontSize: 15, fontWeight: 600, color: green[800] }}>{s.name}</div>
                <div style={{ fontSize: 12, color: neutral[500] }}>{s.meta}</div>
              </div>
              <span style={{ background: neutral[100], color: neutral[400], borderRadius: 99, padding: "3px 10px", fontSize: 11, fontWeight: 600 }}>in attesa</span>
            </div>
          ))}
        </div>
      </div>

      {/* Annotations — left */}
      <Annotation top={68} left={-220} lines={[
        { color: green[500], label: "bg/header — green-500" },
        { color: neutral[0], label: "text/on-header — white" },
      ]} />
      <Annotation top={130} left={-200} lines={[
        { color: neutral[0], label: "text/on-header — white" },
        { color: "rgba(255,255,255,0.65)", label: "text/on-header-sub — 65%" },
      ]} />
      <Annotation top={195} left={-200} lines={[
        { color: neutral[50], label: "bg/app — neutral-50" },
        { color: neutral[0], label: "bg/card — white" },
        { color: neutral[200], label: "border/default — neutral-200" },
      ]} />
      <Annotation top={270} left={-180} lines={[
        { color: green[50], label: "badge/done-bg — green-50" },
        { color: green[600], label: "badge/done-text — green-600" },
      ]} />
      <Annotation top={345} left={-220} lines={[
        { color: green[500], label: "border/active — green-500" },
        { color: green[800], label: "text/primary — green-800" },
        { color: neutral[500], label: "text/secondary — neutral-500" },
      ]} />
      <Annotation top={420} left={-220} lines={[
        { color: green[50], label: "progress/track — green-50" },
        { color: green[500], label: "progress/fill — green-500" },
      ]} />
      <Annotation top={460} left={-220} lines={[
        { color: green[500], label: "cta/primary-bg — green-500" },
        { color: neutral[0], label: "cta/primary-text — white" },
      ]} />
      <Annotation top={540} left={-200} lines={[
        { color: neutral[100], label: "badge/pending-bg — neutral-100" },
        { color: neutral[400], label: "badge/pending-text — neutral-400" },
      ]} />
    </div>
  );
}

// ─── RULES ───────────────────────────────────────────────────────────────────
const rules = [
  {
    id: "01",
    title: "Header e navigazione",
    color: green[500],
    items: [
      { element: "Sfondo header", token: "bg/header", val: green[500], hex: "#1A7D5A" },
      { element: "Titolo pagina", token: "text/on-header", val: neutral[0], hex: "#FFFFFF" },
      { element: "Back link, label nav", token: "text/on-header", val: neutral[0], hex: "#FFFFFF", opacity: "60%" },
      { element: "Testo secondario header (data, info)", token: "text/on-header-sub", val: "rgba(255,255,255,0.65)", hex: "white 65%" },
      { element: "Badge in header (\"in corso\")", token: "bg: rgba(0,0,0,0.25) · text: white", val: neutral[0], hex: "overlay scuro" },
    ]
  },
  {
    id: "02",
    title: "Sfondo e layout",
    color: neutral[200],
    items: [
      { element: "Sfondo generale app / lista", token: "bg/app", val: neutral[50], hex: "#F7F8F7" },
      { element: "Sfondo card step (tutti gli stati)", token: "bg/card", val: neutral[0], hex: "#FFFFFF" },
    ]
  },
  {
    id: "03",
    title: "Testi su card (sfondo bianco)",
    color: green[800],
    items: [
      { element: "Nome step (titolo card)", token: "text/primary", val: green[800], hex: "#0A3828" },
      { element: "Orario, durata, metadati", token: "text/secondary", val: neutral[500], hex: "#737876" },
      { element: "Label sezione, overline, placeholder", token: "text/tertiary", val: neutral[400], hex: "#9CA09E" },
    ]
  },
  {
    id: "04",
    title: "Bordi card",
    color: green[500],
    items: [
      { element: "Card step done", token: "border/default", val: neutral[200], hex: "#DCDEDD", note: "1pt" },
      { element: "Card step in attesa", token: "border/default", val: neutral[200], hex: "#DCDEDD", note: "1pt" },
      { element: "Card step running", token: "border/active", val: green[500], hex: "#1A7D5A", note: "2pt" },
    ]
  },
  {
    id: "05",
    title: "Badge status",
    color: green[50],
    items: [
      { element: "\"in corso\" — sfondo", token: "badge/running-bg", val: green[500], hex: "#1A7D5A" },
      { element: "\"in corso\" — testo", token: "badge/running-text", val: neutral[0], hex: "#FFFFFF" },
      { element: "\"done\" — sfondo", token: "badge/done-bg", val: green[50], hex: "#E0F4EC" },
      { element: "\"done\" — testo", token: "badge/done-text", val: green[600], hex: "#156349" },
      { element: "\"in attesa\" — sfondo", token: "badge/pending-bg", val: neutral[100], hex: "#EDEEED" },
      { element: "\"in attesa\" — testo", token: "badge/pending-text", val: neutral[400], hex: "#9CA09E" },
    ]
  },
  {
    id: "06",
    title: "Barra progresso",
    color: green[500],
    items: [
      { element: "Track (sfondo barra)", token: "progress/track", val: green[50], hex: "#E0F4EC" },
      { element: "Fill (riempimento)", token: "progress/fill", val: green[500], hex: "#1A7D5A" },
    ]
  },
  {
    id: "07",
    title: "CTA e pulsanti",
    color: green[500],
    items: [
      { element: "Pulsante primario — sfondo (Completa, Avvia)", token: "cta/primary-bg", val: green[500], hex: "#1A7D5A" },
      { element: "Pulsante primario — testo", token: "cta/primary-text", val: neutral[0], hex: "#FFFFFF" },
      { element: "Pulsante secondario — sfondo", token: "cta/sec-bg", val: neutral[100], hex: "#EDEEED" },
      { element: "Pulsante secondario — testo", token: "cta/sec-text", val: green[800], hex: "#0A3828" },
      { element: "Pulsante danger — sfondo (Annulla)", token: "cta/danger-bg", val: "#FEE2E2", hex: "#FEE2E2" },
      { element: "Pulsante danger — testo", token: "cta/danger-text", val: "#E53E3E", hex: "#E53E3E" },
    ]
  },
];

// ─── RULE ROW ────────────────────────────────────────────────────────────────
function RuleRow({ element, token, val, hex, opacity, note }) {
  const showHex = hex || val;
  return (
    <div style={{
      display: "grid",
      gridTemplateColumns: "1fr 1fr auto",
      gap: 12,
      padding: "10px 0",
      borderBottom: `1px solid ${neutral[100]}`,
      alignItems: "center",
    }}>
      <div style={{ fontSize: 13, color: green[800] }}>{element}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <div style={{
          width: 20, height: 20, borderRadius: 5,
          background: val,
          border: `1px solid rgba(0,0,0,0.07)`,
          flexShrink: 0,
        }} />
        <code style={{ fontSize: 11, color: neutral[500], fontFamily: "monospace" }}>{showHex}{opacity ? ` · ${opacity}` : ""}{note ? ` · ${note}` : ""}</code>
      </div>
      <code style={{ fontSize: 10, color: green[600], background: green[25], padding: "2px 7px", borderRadius: 6, whiteSpace: "nowrap" }}>{token}</code>
    </div>
  );
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────
const TABS = ["Annotazioni", "Regole", "Tokens"];

export default function App() {
  const [tab, setTab] = useState("Annotazioni");

  return (
    <div style={{
      minHeight: "100vh",
      background: neutral[50],
      fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
      color: green[800],
    }}>
      {/* Header */}
      <div style={{
        background: green[500],
        padding: "28px 48px 0",
        display: "flex", alignItems: "center", gap: 20, flexWrap: "wrap",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, paddingBottom: 24 }}>
          <div style={{ width: 32, height: 32, borderRadius: 10, background: "rgba(255,255,255,0.15)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16 }}>🌾</div>
          <div>
            <div style={{ fontSize: 16, fontWeight: 700, color: neutral[0] }}>Lievito — Color Rules</div>
            <div style={{ fontSize: 11, color: "rgba(255,255,255,0.55)" }}>Come applicare i colori · v0.1</div>
          </div>
        </div>
        <div style={{ marginLeft: "auto", display: "flex", gap: 2, alignSelf: "flex-start", marginTop: 8 }}>
          {TABS.map(t => (
            <button key={t} onClick={() => setTab(t)} style={{
              padding: "8px 18px",
              borderRadius: "10px 10px 0 0",
              background: tab === t ? neutral[0] : "transparent",
              color: tab === t ? green[600] : "rgba(255,255,255,0.65)",
              border: "none", fontSize: 13, fontWeight: tab === t ? 700 : 400,
              fontFamily: "inherit", cursor: "pointer",
            }}>{t}</button>
          ))}
        </div>
      </div>

      <div style={{ padding: "48px 48px 80px" }}>

        {/* ── ANNOTAZIONI ── */}
        {tab === "Annotazioni" && (
          <div>
            <div style={{ fontSize: 13, color: neutral[500], marginBottom: 40, maxWidth: 480 }}>
              La schermata <strong style={{ color: green[800] }}>Bake Detail</strong> è il riferimento principale. Ogni elemento è etichettato con il token colore usato. Il resto dell'app segue gli stessi token.
            </div>
            <div style={{ display: "flex", gap: 80, flexWrap: "wrap", alignItems: "flex-start" }}>
              <AnnotatedScreen />
              {/* Legend */}
              <div style={{ flex: 1, minWidth: 260 }}>
                <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.08em", textTransform: "uppercase", color: neutral[400], marginBottom: 16 }}>Legenda token</div>
                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  {[
                    { t: "bg/header", hex: green[500], desc: "Header verde" },
                    { t: "bg/app", hex: neutral[50], desc: "Sfondo generale" },
                    { t: "bg/card", hex: neutral[0], desc: "Card step" },
                    { t: "text/primary", hex: green[800], desc: "Nomi step" },
                    { t: "text/secondary", hex: neutral[500], desc: "Orari e durate" },
                    { t: "text/on-header", hex: neutral[0], desc: "Su sfondo verde" },
                    { t: "border/default", hex: neutral[200], desc: "Done / pending" },
                    { t: "border/active", hex: green[500], desc: "Step running — 2pt" },
                    { t: "badge/running-bg", hex: green[500], desc: "\"in corso\" fill" },
                    { t: "badge/done-bg", hex: green[50], desc: "\"done\" fill" },
                    { t: "badge/pending-bg", hex: neutral[100], desc: "\"in attesa\" fill" },
                    { t: "progress/track", hex: green[50], desc: "Sfondo barra" },
                    { t: "progress/fill", hex: green[500], desc: "Fill barra" },
                    { t: "cta/primary-bg", hex: green[500], desc: "Pulsante Completa" },
                  ].map(r => (
                    <div key={r.t} style={{ display: "flex", alignItems: "center", gap: 10 }}>
                      <div style={{ width: 14, height: 14, borderRadius: 4, background: r.hex, border: "1px solid rgba(0,0,0,0.06)", flexShrink: 0 }} />
                      <code style={{ fontSize: 11, color: green[600], width: 160, flexShrink: 0 }}>{r.t}</code>
                      <span style={{ fontSize: 12, color: neutral[500] }}>{r.desc}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ── REGOLE ── */}
        {tab === "Regole" && (
          <div style={{ maxWidth: 760 }}>
            <div style={{ fontSize: 13, color: neutral[500], marginBottom: 40, lineHeight: 1.6 }}>
              Queste regole definiscono <strong style={{ color: green[800] }}>solo quale colore usare per ogni elemento</strong>, non la forma o il comportamento dei componenti. I componenti restano quelli nativi iOS.
            </div>

            {rules.map(r => (
              <div key={r.id} style={{ marginBottom: 36 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
                  <div style={{ width: 24, height: 24, borderRadius: 7, background: r.color, flexShrink: 0 }} />
                  <div>
                    <span style={{ fontSize: 10, fontWeight: 700, color: neutral[400], letterSpacing: "0.08em", textTransform: "uppercase" }}>{r.id} · </span>
                    <span style={{ fontSize: 15, fontWeight: 700, color: green[800] }}>{r.title}</span>
                  </div>
                </div>
                <div style={{
                  background: neutral[0], border: `1px solid ${neutral[200]}`,
                  borderRadius: 16, overflow: "hidden",
                }}>
                  <div style={{
                    display: "grid", gridTemplateColumns: "1fr 1fr auto",
                    gap: 12, padding: "8px 16px",
                    background: neutral[50], borderBottom: `1px solid ${neutral[200]}`,
                  }}>
                    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: "0.07em", textTransform: "uppercase", color: neutral[400] }}>Elemento</div>
                    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: "0.07em", textTransform: "uppercase", color: neutral[400] }}>Colore</div>
                    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: "0.07em", textTransform: "uppercase", color: neutral[400] }}>Token</div>
                  </div>
                  <div style={{ padding: "0 16px" }}>
                    {r.items.map((item, i) => <RuleRow key={i} {...item} />)}
                  </div>
                </div>
              </div>
            ))}

            {/* Nota finale */}
            <div style={{
              background: green[25], border: `1px solid ${green[100]}`,
              borderRadius: 14, padding: "16px 20px", marginTop: 8,
            }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: green[700], marginBottom: 8 }}>Regola generale</div>
              <div style={{ fontSize: 13, color: green[700], lineHeight: 1.7 }}>
                <strong>green-500</strong> (#1A7D5A) è l'unico colore funzionale dell'app. Appare su: header, bordo card running, badge running, progress fill, pulsante primario.<br />
                <strong>green-800</strong> (#0A3828) è il testo primario su tutte le card bianche.<br />
                <strong>neutral-500</strong> (#737876) è il testo secondario. Nessun testo usa il nero puro.<br />
                Nessun altro colore ha ruolo funzionale. Il rosso errore (#E53E3E) compare solo per step scaduti e azioni distruttive.
              </div>
            </div>
          </div>
        )}

        {/* ── TOKENS ── */}
        {tab === "Tokens" && (
          <div style={{ maxWidth: 640 }}>
            <div style={{ fontSize: 13, color: neutral[500], marginBottom: 28 }}>Riferimento rapido. Da mappare su Color Assets in Xcode.</div>
            <div style={{ background: neutral[0], border: `1px solid ${neutral[200]}`, borderRadius: 16, overflow: "hidden" }}>
              <div style={{ display: "grid", gridTemplateColumns: "auto 1fr auto", gap: 0 }}>
                {/* Header row */}
                <div style={{ gridColumn: "1/-1", display: "grid", gridTemplateColumns: "180px 1fr 80px", padding: "8px 16px", background: neutral[50], borderBottom: `1px solid ${neutral[200]}` }}>
                  <div style={{ fontSize: 10, fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.07em", color: neutral[400] }}>Token</div>
                  <div style={{ fontSize: 10, fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.07em", color: neutral[400] }}>Note</div>
                  <div style={{ fontSize: 10, fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.07em", color: neutral[400] }}>Hex</div>
                </div>
                {Object.entries(tokens).map(([k, v], i) => (
                  <div key={k} style={{
                    gridColumn: "1/-1", display: "grid", gridTemplateColumns: "180px 1fr 80px",
                    padding: "10px 16px", borderBottom: `1px solid ${neutral[100]}`,
                    alignItems: "center",
                    background: i % 2 === 0 ? neutral[0] : neutral[50],
                  }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                      <div style={{ width: 16, height: 16, borderRadius: 4, background: v.val, border: "1px solid rgba(0,0,0,0.07)", flexShrink: 0 }} />
                      <code style={{ fontSize: 11, color: green[600] }}>{k}</code>
                    </div>
                    <div style={{ fontSize: 12, color: neutral[500] }}>{v.note}</div>
                    <code style={{ fontSize: 10, color: neutral[400], fontFamily: "monospace" }}>
                      {v.val.startsWith("rgba") ? v.val.slice(0,16) + "…" : v.val}
                    </code>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}
