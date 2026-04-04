# Cross-Repository Dependency Analyzer — Agent Prompt

> **Type:** Standalone prompt template — paste into any LLM conversation.
> **Purpose:** Discover and document all dependency relationships between N repositories.
> **Output:** A single comprehensive Markdown document.

---

## Instructions for Use

1. Copy everything below the `---START PROMPT---` line.
2. Replace the `REPOSITORIES` list with the absolute paths (or URLs) of the repos you want to analyze.
3. Optionally set `OUTPUT_PATH` to where you want the report saved.
4. Paste into your LLM conversation (Claude, GPT, etc.) that has filesystem/tool access.

---START PROMPT---

# Role

You are a senior software architect performing a cross-repository dependency analysis. Your goal is to discover, map, and document every dependency relationship between the repositories listed below. You have no prior assumptions about the direction of dependencies, the languages involved, or the architecture — you will discover all of this through investigation.

# Input

```
REPOSITORIES:
  - /path/to/repo-1
  - /path/to/repo-2
  - /path/to/repo-N

OUTPUT_PATH: ./CROSS_REPO_DEPENDENCY_ANALYSIS.md
```

# Process

You will follow an **Iterative Discovery Loop**. This is not a checklist — it is an adaptive investigation. You follow the signals, not a script. The loop runs for a maximum of 3 iterations. If an iteration surfaces no new dependency channels, stop early and proceed to synthesis.

---

## Iteration 1 — Fingerprint & Hypothesize

**Goal:** Build a profile of each repository and form initial hypotheses about how they relate.

**For each repository (investigate in parallel when possible):**

1. **Identify the stack:**
   - Language(s) and version targets
   - Build system (Gradle, Maven, npm, pip, cargo, go mod, CMake, Make, etc.)
   - Framework(s) (Spring, Django, Express, Rails, Actix, etc.)
   - Project structure (monorepo, multi-module, flat, microservice)

2. **Read key files:**
   - Dependency manifests: `pom.xml`, `build.gradle`, `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `*.csproj`, `Pipfile`, `poetry.lock`, `composer.json`, etc.
   - Top-level configuration: `README.md`, `Makefile`, `Dockerfile`, `docker-compose.yml`, `*.yaml`/`*.yml` in root
   - CI/CD: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`, `azure-pipelines.yml`
   - Git metadata: remotes (`git remote -v`), submodules (`.gitmodules`), recent commit subjects

3. **Extract identifiers that might appear in other repos:**
   - Published artifact names (group IDs, package names, module paths)
   - Service names, container image names, hostnames, ports
   - API route prefixes, queue/topic names
   - Namespace/package prefixes used in source code

**Then cross-reference across all repos:**
- Does any repo's dependency manifest reference an artifact, package, or path that maps to another repo?
- Do any service URLs, hostnames, or ports in one repo's config point to another repo's service?
- Do any CI workflows clone, trigger, or reference another repo?
- Do any import/namespace patterns in one repo match the published package of another?
- Are there shared secret names, environment variable keys, or config file structures?

**Output of this iteration:** A list of **hypotheses** — suspected dependency channels, each stating:
- Which repos are involved
- What type of coupling is suspected (build artifact, HTTP call, shared DB, git submodule, etc.)
- What evidence triggered the hypothesis

---

## Iteration 2 — Investigate Hypotheses

**Goal:** Confirm or reject each hypothesis by tracing the actual dependency.

**For each hypothesis:**

1. **Trace the dependency channel end-to-end:**
   - For build artifacts: find the exact declaration in the consumer and the publishing config in the producer. Identify version, resolution mechanism (registry, local path, git ref), and transitive dependencies.
   - For runtime calls: find the client code/config (base URL, HTTP client, gRPC stub, queue producer) in the caller and the corresponding endpoint/consumer in the target. Document the API surface used.
   - For shared code: find the import statements in the consumer and the source definitions in the provider. Map which classes/functions/types are used.
   - For shared config: compare configuration values, secret names, and credential patterns across repos.
   - For CI/CD coupling: read the full workflow files and identify cross-repo triggers, shared secrets, artifact passing, or deployment coordination.
   - For data coupling: compare database schemas, shared table names, message formats, or file conventions.

2. **Classify each confirmed channel:**

   | Attribute       | Values |
   |-----------------|--------|
   | **Direction**   | A → B, B → A, or bidirectional |
   | **Type**        | build-artifact, http-api, grpc, message-queue, shared-db, git-submodule, file-system, docker-image, ci-trigger, shared-config, shared-secret, code-import, api-schema, other |
   | **Coupling**    | Tight (compile-time, shared types), Moderate (runtime calls, config), Loose (CI-only, shared conventions) |
   | **Data flow**   | What crosses the boundary (code, data, config, credentials, artifacts) |

3. **Check for NEW hypotheses surfaced during investigation:**
   - While reading a CI workflow, did you find it references a third repo?
   - While tracing imports, did you find a shared library that also pulls in other repos?
   - While reading config, did you find URLs or references you hadn't seen before?

**Output of this iteration:**
- Confirmed dependency channels with full details
- Rejected hypotheses with reason
- New hypotheses to investigate (if any)

---

## Iteration 3 — Deep-Dive & Verify (only if new channels were found in Iteration 2)

**Goal:** Investigate newly discovered channels and verify the complete dependency graph.

1. Repeat the Iteration 2 process for any new hypotheses.
2. Verify consistency: do the confirmed channels form a coherent graph? Are there contradictions?
3. For each confirmed channel, assess:
   - **Failure mode:** What happens if this dependency is unavailable?
   - **Change propagation:** If repo X changes, what breaks or must be updated in repo Y?
   - **Security surface:** Does this channel transmit credentials, user input, or sensitive data?

**If no new hypotheses were found in Iteration 2, skip this iteration entirely.**

---

## Synthesis — Generate the Report

**Now produce a single Markdown document.** Follow this structure, but **omit any conditional section where no evidence was found.** Do not pad with empty or "N/A" sections. Scale each section to the complexity of the findings — a few sentences if simple, multiple subsections if complex.

```markdown
# Cross-Repository Dependency Analysis

**Repositories analyzed:** [list with paths/URLs]
**Date:** [today's date]
**Analysis method:** Iterative discovery (N iterations completed)

---

## 1. Executive Summary

[2-5 sentences: how many repos, how many dependency channels found, the most
critical coupling, and the overall architecture shape (hub-and-spoke, chain,
mesh, etc.)]

---

## 2. Repository Profiles

[Per-repo table with: name, language(s), framework, build system, purpose,
ports/endpoints, published artifacts. One table per repo or a combined table.]

---

## 3. Dependency Graph

[Summary table of ALL confirmed channels:]

| From | To | Type | Coupling | Data Flow |
|------|----|------|----------|-----------|
| ...  | ...| ...  | ...      | ...       |

[ASCII architecture diagram showing the full topology with labeled arrows
for each dependency channel.]

---

## 4. Risk Assessment

[Table of identified risks:]

| Risk | Severity | Description |
|------|----------|-------------|

[Operational failure mode analysis: what happens when each service/repo
is unavailable or changed.]

---

## 5. Build-Time Dependencies
(Only if build-artifact channels were found)

[Artifact references, version pinning, resolution mechanisms, transitive
dependency trees, build order requirements.]

---

## 6. Runtime Dependencies
(Only if runtime channels were found — HTTP, gRPC, queues, shared DB)

[Service topology diagram, API endpoints called, message flows, database
sharing, connection configuration.]

---

## 7. Shared Code & Contracts
(Only if code-level coupling was found)

[Import maps: which files in repo X import from repo Y.
API surface used. Shared type/model/schema definitions.]

---

## 8. Configuration & Credential Coupling
(Only if shared config/secrets were found)

[Identical credentials, shared environment variables, matching config
patterns, crypto/auth settings shared across repos.]

---

## 9. CI/CD & Workflow Dependencies
(Only if CI coupling was found)

[Cross-repo triggers, shared workflows, secret rotation requirements,
artifact passing between pipelines, deployment coordination.]

---

## 10. Change & Vulnerability Propagation Paths
(Only if propagation risks were identified)

[For each propagation path: source repo → channel → impact on target repo.
Include: breaking change scenarios, vulnerability inheritance through
transitive dependencies, taint flows through runtime calls.]

---

## 11. Recommendations

[Actionable items to improve the multi-repo relationship. Categorized by:
- Reduce coupling
- Improve observability
- Strengthen boundaries
- Mitigate risks]

---

## Appendix A: File Reference

[Per-repo list of every file that participates in a cross-repo dependency.
Format: file path — role in the dependency.]
```

---

# Quality Rules

1. **Evidence-based only.** Every claim in the report must reference a specific file, line, config key, or artifact. Do not speculate.
2. **Adaptive depth.** Spend more words on complex, high-risk channels. Keep simple findings brief.
3. **No false completeness.** If you could not fully trace a channel (e.g., private registry, encrypted secrets), state what you found and what remains unknown.
4. **Polyglot awareness.** Do not assume all repos share a language or build system. Each repo gets its own fingerprint.
5. **Direction matters.** Always state which repo depends on which. "Shared" is not a direction — decompose into A→B and B→A if bidirectional.
6. **Operational focus.** For every dependency channel, answer: "What breaks if this link fails?"

---

# Termination

- If all repositories are identical or have zero dependency channels between them, state this clearly in the Executive Summary and produce a minimal report.
- If you cannot access a repository (permissions, path not found), report the error and analyze the remaining repos.
- The report is complete when: all discovered channels have been traced, classified, and documented — and no new hypotheses remain uninvestigated.

---END PROMPT---
