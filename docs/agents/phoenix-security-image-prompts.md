# Phoenix Security — Adaptive Image Prompt Library

> **Type:** Standalone prompt templates for AI image generation (DALL-E, Midjourney, Ideogram, Gemini, etc.)
> **Purpose:** Generate on-brand cybersecurity visuals from any blog/article content.
> **Usage:** Replace `{{text}}` with your blog content, article excerpt, or topic description. The AI will dynamically extract the topic, generate titles, select visual metaphors, and structure the output.

---

## Brand System (Referenced by All Prompts)

```
PHOENIX SECURITY BRAND IDENTITY:

LOGO:
- Geometric low-poly phoenix bird in orange/red tones
- Available variants: stacked (bird above text), wide (bird left of text), white-on-dark
- NEVER modify, recolor, distort, or apply effects to the logo
- Place logo: top-right or top-left corner, sharp and legible

PRIMARY PALETTE:
- Neutral Dark (background):    #1E2535  (RGB 30, 37, 53)
- Neutral White (text):         #FFFFFF
- Primary Vivid Red:            #FF2D46  (RGB 247, 144, 89)
- Primary Pumpkin Orange:       #F36717  (RGB 243, 103, 23)
- Red Orange (threat accent):   #F03E1E  (RGB 240, 62, 30)
- Mahogany (deep accent):       #C6361F  (RGB 198, 54, 31)

GRADIENT BACKGROUNDS:
- Fiery Sunset:        #F36717 → #D15F3C → #9E517B → #523DD9 → #6714CC → #245EE9
- Deep Purple to Azure: #6714CC → #245EE9
- Indigo Blue Blend:   #380886 → #05057A → #030331 → #0E0E6F → #3A0E82
- Nightfall Spectrum:   deep indigo to navy

DESIGN LANGUAGE:
- Clean, minimal, high-end
- BlackHat conference / Netflix documentary aesthetic
- Subtle glow, grid, or matrix patterns on dark backgrounds
- Use red-orange ONLY for attack/threat indicators
- Typography: bold, clean, technical, spaced uppercase for headings
```

---

## How to Use

1. Pick the prompt that matches your use case (1–5).
2. Copy everything inside the code block.
3. Replace `{{text}}` at the bottom with your blog content, article, or topic description.
4. Attach your Phoenix Security logo images when submitting to the AI.
5. The AI will auto-extract the topic, generate titles, and select appropriate visuals.

---

# Prompt 1 — Blog Hero Image (Adaptive)

**Use for:** Blog post featured images, social media headers, newsletter banners.

```
Create a clean cybersecurity blog hero image in Phoenix Security style.

STRICT RULES:
- DO NOT modify or redesign the logo
- Use Phoenix Security official logo exactly as provided in the attached images
- Keep logo sharp, placed top-right or centered
- No distortion, recoloring, or effects applied to the logo

STYLE:
- Dark technical background (#1E2535)
- Gradient accents: deep purple → indigo → azure (#6714CC → #380886 → #245EE9)
- Threat highlight color: red-orange (#F03E1E)
- Subtle glow, grid, or matrix patterns
- Clean, minimal, high-end BlackHat / Netflix documentary aesthetic

CONTENT HANDLING:
- Analyze the provided {{text}} below
- Extract the main cybersecurity topic
- Generate a short impactful TITLE (max 10 words)
- Generate a supporting SUBTITLE (threat category — e.g., supply chain compromise, RCE, cloud breach, identity attack, ransomware, API abuse, zero-day exploit)
- Do NOT copy raw paragraphs — synthesize into punchy headline language

VISUAL METAPHOR (AUTO-SELECT BASED ON CONTENT):
- Supply chain attack      → domino effect / dependency chain collapse
- Credential theft         → keys / vault breach / lock picking
- Cloud attack             → cloud nodes + lateral movement arrows
- Malware / RAT            → hidden payload / embedded trojan object
- Ransomware               → encrypted lock / shattered filesystem
- API abuse                → exposed endpoints / broken gateway
- Container / K8s attack   → compromised pod / container escape
- Identity compromise      → broken authentication / stolen token
- Network intrusion        → perimeter breach / firewall bypass
- Zero-day / CVE           → cracked shield / vulnerability window
- Data exfiltration        → data stream leaving a vault
- CI/CD attack             → poisoned pipeline / injected build step
- If unclear or mixed      → abstract "attack propagation" flow with directional arrows

COMPOSITION:
- Left side: visual metaphor
- Right side: title + subtitle text block
- Maintain whitespace, avoid clutter
- Logo: top-right corner

OUTPUT:
- 1200x630px aspect ratio (or 16:9)
- Sharp, high contrast, modern cybersecurity blog hero

CONTENT:
{{text}}
```

---

# Prompt 2 — Blog Visual / Illustration (Adaptive Depth)

**Use for:** In-article illustrations with more technical depth and storytelling.

```
You are a senior cybersecurity graphic designer.

Create a Phoenix Security styled blog illustration.

STRICT RULES:
- DO NOT CHANGE THE LOGO
- Use Phoenix logo exactly as provided in attached images
- Preserve proportions, colors, and geometry of the logo

STYLE SYSTEM:
- Background: dark navy (#1E2535)
- Gradient overlays: purple → indigo → azure (#6714CC → #380886 → #245EE9)
- Threat highlight: red-orange (#F03E1E)
- Typography: bold, clean, technical, spaced uppercase

CONTENT HANDLING:
- Analyze the provided {{text}} below
- Extract:
  - Main threat type (e.g., supply chain, RCE, lateral movement, privilege escalation)
  - Affected systems (cloud / CI/CD / app / container / identity / network / endpoint)
  - Primary attack vector (e.g., dependency injection, phishing, misconfiguration, exploit)
- Generate:
  - A concise TITLE (max 8 words)
  - A short technical TAGLINE (max 15 words, describes the core risk)
- Do NOT copy raw text — synthesize

VISUAL ELEMENTS (AUTO-SELECT BASED ON EXTRACTED THREAT):
- Software supply chain     → dependency tree turning malicious (red nodes)
- CI/CD pipeline attack     → pipeline stages with injected/poisoned step
- Cloud compromise          → cloud architecture with lateral movement lines
- Developer/runtime attack  → terminal window / code editor with highlighted exploit
- Credential/identity       → broken key / stolen token / vault breach
- Container escape          → pod breaking through boundary
- Network intrusion         → perimeter diagram with breach point
- Data breach               → database with exfiltration stream
- Vulnerability / CVE       → code with highlighted vulnerable function
- Multi-vector              → hub-and-spoke showing multiple entry points

MOOD:
- Investigative
- Controlled danger
- Precision engineering

LAYOUT:
- Top: title
- Middle: visual attack concept (derived from content)
- Bottom: short technical tagline

OUTPUT:
- Modern BlackHat keynote slide quality
- Technical storytelling, not marketing fluff
- 1200x675px or 16:9 aspect ratio

CONTENT:
{{text}}
```

---

# Prompt 3 — Attack Methodology / Technical Anatomy Infographic (Adaptive)

**Use for:** Detailed technical infographics showing attack phases and kill chain.

```
Create a technical cybersecurity infographic in Phoenix Security style.

STRICT RULES:
- DO NOT MODIFY THE PHOENIX SECURITY LOGO
- Use official logos from attached images
- Keep logo top-right or top-left

STYLE:
- Dark background (#1E2535) with gradient purple → blue (#6714CC → #245EE9)
- High contrast, structured infographic layout
- Use red-orange (#F03E1E) ONLY for attack/threat indicators
- Clean typography, spaced uppercase headings

CONTENT HANDLING:
- Analyze the provided {{text}} below
- Automatically extract and map to kill chain phases:
  - Initial access method (how the attacker gets in)
  - Execution method (what runs, what's triggered)
  - Affected systems / platforms (OS, cloud, containers, apps)
  - Lateral movement (if present — how it spreads)
  - Persistence techniques (if present — how it stays)
  - Data targeted (credentials, keys, PII, source code, configs)
  - Exfiltration or impact (what happens at the end)

TITLE:
- Generate a concise technical title from the content
- Format: "[Threat Name]: [Attack Type] Anatomy" or similar

STRUCTURE (AUTO-GENERATED, 4–6 PHASES):
- Include ONLY phases that have evidence in the content
- Do NOT invent or pad phases
- Typical flow:
  - Phase 1 — Initial Access / Entry Point
  - Phase 2 — Injection / Payload Delivery
  - Phase 3 — Execution / Activation
  - Phase 4 — Lateral Movement / Expansion (if present)
  - Phase 5 — Persistence / Foothold (if present)
  - Phase 6 — Exfiltration / Impact

EACH PHASE MUST INCLUDE:
- Phase number and name
- 2-3 bullet points describing what happens
- An icon representing the action (key, terminal, cloud, lock, arrow, skull, etc.)
- Platform indicators where relevant (Windows / Linux / macOS / cloud / container)

VISUAL ELEMENTS:
- Directional arrows showing attack flow between phases
- Icons per phase
- Platform differentiation badges
- Color escalation: phases get progressively more red-orange toward impact

LAYOUT:
- Horizontal left-to-right flow (preferred) OR vertical top-to-bottom
- Numbered steps with connecting arrows
- Each phase in its own visual panel/card

OUTPUT:
- BlackHat-level technical diagram
- Precise, clean, highly readable
- 1600x900px or wider landscape format

CONTENT:
{{text}}
```

---

# Prompt 4 — Campaign / Advisory Infographic (Adaptive)

**Use for:** Security advisory cards, campaign visuals, executive + technical hybrid summaries.

```
Create a cybersecurity campaign infographic in Phoenix Security style.

STRICT RULES:
- DO NOT MODIFY THE LOGO
- KEEP "PHOENIX SECURITY | VULNERABILITY INTELLIGENCE" branding EXACT
- Match Phoenix campaign visual language from attached images

STYLE:
- Dark gradient background: purple → blue (#6714CC → #245EE9) or Indigo Blue Blend (#380886 → #05057A)
- Orange/red (#F03E1E, #C6361F) used ONLY for critical alerts and threat indicators
- Clean boxed sections with subtle borders
- Structured, balanced for both executive and technical audiences

CONTENT HANDLING:
- Analyze the provided {{text}} below
- Extract:
  - Root cause of the incident/vulnerability
  - Affected components, packages, versions, or systems
  - Attack flow / exploitation chain (step by step)
  - Indicators of compromise — IOCs (domains, IPs, file hashes, behaviors, package names)
  - Remediation actions (what to do to fix/mitigate)
- If any category has no data in the content, OMIT that section entirely

TITLE:
- Generate a campaign-style title from content
- Format examples:
  - "[Package/System] Compromise: [Attack Type]"
  - "[CVE/Threat] Advisory: [Impact Summary]"
  - "[Incident Name]: What You Need to Know"

MANDATORY SECTIONS (auto-filled from content, omit if no data):

1. ISSUE & ROOT CAUSE
   - What happened and why (2-3 lines max)

2. AFFECTED COMPONENTS / VERSIONS
   - Table or list: component name, affected versions, safe versions
   - Highlight critical versions in red-orange

3. ATTACK FLOW (centerpiece visual)
   - Step-by-step chain: entry → injection → execution → impact
   - Use arrows and icons
   - This is the visual anchor of the infographic

4. KEY INDICATORS (IOCs)
   - Domains, IPs, file names, hashes, package names, behaviors
   - Displayed in monospace/code style

5. REMEDIATION ACTIONS
   - Numbered actionable steps
   - Use green or blue accent for "safe" actions

VISUAL:
- Attack flow as centerpiece: pipeline / chain / domino metaphor
- Structured panels for each section
- Clear visual hierarchy: title → flow → details → actions

OUTPUT:
- Consistent with Phoenix Security campaign visual identity
- Clear, actionable, high signal-to-noise ratio
- 1200x1600px portrait OR 1600x900px landscape

CONTENT:
{{text}}
```

---

# Prompt 5 — Timeline / Campaign Evolution (Adaptive)

**Use for:** Incident timelines, attack evolution storytelling, investigation views.

```
Create a cybersecurity campaign timeline infographic in Phoenix Security style.

STRICT RULES:
- DO NOT CHANGE THE LOGO
- Use official Phoenix Security logos from attached images
- Preserve logo exactly — no modifications

STYLE:
- Dark gradient background: Deep Purple to Azure (#6714CC → #245EE9)
- Horizontal timeline as primary visual structure
- Purple → blue base with orange/red (#F03E1E) highlights for attack peaks
- Clean typography, spaced uppercase for phase labels

CONTENT HANDLING:
- Analyze the provided {{text}} below
- Extract chronological events, dates, or phases
- If explicit timestamps exist in the content → use them on the timeline
- If no timestamps → infer logical phases from the narrative order
- Do NOT fabricate dates or events not present in the content

TITLE:
- Generate a timeline title from content
- Format examples:
  - "[Incident Name] Attack Timeline — [Month Year]"
  - "[Threat Name]: From Compromise to Discovery"
  - "Timeline: [CVE/Package] Supply Chain Incident"

TIMELINE STRUCTURE (auto-generated, include only what content supports):

Phase 1 — Pre-Staging / Initial Activity
  - Preparation, reconnaissance, account compromise, clean package publish

Phase 2 — Weaponization / Attack Execution
  - Malicious payload deployed, trojanized version released, exploit triggered

Phase 3 — Exploitation Window / Active Compromise
  - Victims affected, payload executing, data being stolen

Phase 4 — Discovery / Detection
  - Community detection, security researcher alert, vendor notification

Phase 5 — Response / Remediation
  - Packages pulled, patches released, credentials rotated, advisory published

RULES:
- Only include phases that have supporting evidence in the content
- Each phase gets: label, date/time (if known), 2-3 bullet points, icon
- Minimum 3 phases, maximum 7

VISUAL ELEMENTS:
- Timeline bar with phase markers
- Intensity escalation: glow/color gets warmer (purple → orange → red) as attack peaks
- Cool down (red → blue → green) during detection and remediation
- Icons per phase representing systems involved (cloud, npm, CI/CD, terminal, lock, shield)
- Optional: small attack surface count or impact metric badges

LAYOUT:
- Horizontal timeline (preferred) or vertical if content has many phases
- Phase markers evenly spaced with connecting line
- Title above timeline
- Logo top-right

OUTPUT:
- Investigative, Netflix documentary style
- Structured narrative, easy to follow chronologically
- 1600x600px wide banner OR 1200x900px standard

CONTENT:
{{text}}
```

---

## Quick Reference — Which Prompt to Use

| Scenario | Prompt |
|----------|--------|
| Blog featured image / social share | **Prompt 1** — Blog Hero |
| In-article illustration with depth | **Prompt 2** — Blog Visual |
| Technical attack breakdown / kill chain | **Prompt 3** — Attack Anatomy |
| Security advisory / campaign card | **Prompt 4** — Campaign Infographic |
| Incident timeline / investigation story | **Prompt 5** — Timeline |

## Tips for Best Results

1. **More content = better extraction.** Paste the full blog post or at least 3-4 paragraphs into `{{text}}` for best auto-detection.
2. **Attach all logo variants** when submitting — the AI picks the best placement.
3. **These prompts work with any cybersecurity topic** — not just supply chain. The visual metaphor, phases, and structure adapt to whatever the content describes.
4. **Combine prompts** for a full campaign: use Prompt 1 for the hero, Prompt 3 for the technical breakdown, Prompt 5 for the timeline, and Prompt 4 for the advisory card.
