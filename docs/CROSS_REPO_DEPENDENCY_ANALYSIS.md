# Cross-Repository Dependency Analysis

**Primary Repository:** `Security-Phoenix-demo/VulnerableApp` (Vulnerable-App-multirepo-primary)
**Dependent Repository:** `Security-Phoenix-demo/Vulnerable-App-multirepo-dependant`
**Date:** 2026-03-27
**Author:** Senior Development Team

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Repository Overview](#2-repository-overview)
3. [Dependency Mechanisms](#3-dependency-mechanisms)
4. [Build-Time Dependencies](#4-build-time-dependencies)
5. [Runtime / Inter-Service Dependencies](#5-runtime--inter-service-dependencies)
6. [Shared Code Dependencies](#6-shared-code-dependencies)
7. [Configuration & Credential Coupling](#7-configuration--credential-coupling)
8. [CI/CD & Workflow Dependencies](#8-cicd--workflow-dependencies)
9. [Vulnerability Propagation Paths](#9-vulnerability-propagation-paths)
10. [Dependency Diagram](#10-dependency-diagram)
11. [Risk Assessment](#11-risk-assessment)
12. [Recommendations](#12-recommendations)

---

## 1. Executive Summary

The **primary repository** (VulnerableApp) has a direct build-time and runtime dependency on the **dependent repository** (Vulnerable-App-multirepo-dependant). The dependency relationship is established through three distinct channels:

| Channel | Mechanism | Coupling Level |
|---------|-----------|----------------|
| **Build-time artifact** | Gradle dependency on `vulnerable-shared-lib` JAR | **Tight** |
| **Runtime HTTP calls** | Dependent service calls primary on port 9090 | **Moderate** |
| **Shared configuration** | Identical credentials, DB config, crypto settings | **Tight** |

The dependent repo publishes a shared library (`org.sasanlabs:vulnerable-shared-lib:1.0.0`) that the primary repo consumes. Additionally, the dependent repo's `vulnerable-service` makes HTTP calls to the primary repo's REST endpoints at runtime, creating a bidirectional operational dependency.

---

## 2. Repository Overview

### 2.1 Primary Repository (This Repo)

| Attribute | Value |
|-----------|-------|
| **GitHub** | `Security-Phoenix-demo/VulnerableApp` |
| **Upstream** | `vulnerable-apps/VulnerableApp` |
| **Language** | Java 8 |
| **Framework** | Spring Boot 2.4.5 |
| **Build System** | Gradle (wrapper) |
| **Port** | 9090 |
| **Context Path** | `/VulnerableApp` |
| **Docker Image** | `sasanlabs/owasp-vulnerableapp` |

### 2.2 Dependent Repository

| Attribute | Value |
|-----------|-------|
| **GitHub** | `Security-Phoenix-demo/Vulnerable-App-multirepo-dependant` |
| **Language** | Java 8 |
| **Framework** | Spring Boot 2.4.5 |
| **Build System** | Gradle 7.5.1 (multi-module) |
| **Modules** | `vulnerable-shared-lib`, `vulnerable-service` |
| **Port** | 9091 |
| **Context Path** | `/DependentService` |

### 2.3 Module Breakdown (Dependent Repo)

```
Vulnerable-App-multirepo-dependant/
├── vulnerable-shared-lib/       # Published library consumed by BOTH repos
│   └── org.sasanlabs.shared.*   # Sanitizers, models, config, utilities
└── vulnerable-service/          # Microservice that calls the primary repo
    └── org.sasanlabs.dependent.*# Controllers, services, client
```

---

## 3. Dependency Mechanisms

The primary repo depends on the dependent repo through **three distinct mechanisms**:

### 3.1 Maven Artifact Dependency (Build-Time)

The primary repo's `build.gradle` (lines 41–43) conditionally resolves the shared library:

```gradle
if (useLocalLib) {
    implementation files('../VulnerableApp-dependent/vulnerable-shared-lib/build/libs/vulnerable-shared-lib-1.0.0.jar')
} else {
    implementation group: 'org.sasanlabs', name: 'vulnerable-shared-lib', version: '1.0.0'
}
```

- **Local mode** (`-PuseLocal=true`): References the JAR directly from the dependent repo's build output directory. Requires the dependent repo to be checked out as a sibling at `../VulnerableApp-dependent/`.
- **Published mode** (default): Resolves the artifact from Maven Local (`mavenLocal()`) or a configured repository.

### 3.2 HTTP Inter-Service Communication (Runtime)

The dependent repo's `vulnerable-service` communicates with the primary repo via HTTP REST calls through `VulnerableAppClient.java`:

```
Dependent Service (port 9091) ──HTTP──> Primary VulnerableApp (port 9090)
```

Configured in the dependent repo's `application.properties`:
```properties
vulnerableapp.base-url=http://localhost:9090/VulnerableApp
```

### 3.3 Shared Code Contracts (Compile-Time)

Both repositories compile against the same `vulnerable-shared-lib` API surface, creating an implicit contract. Changes to the shared library's interfaces affect both repositories simultaneously.

---

## 4. Build-Time Dependencies

### 4.1 Shared Library: `vulnerable-shared-lib`

**GAV Coordinates:** `org.sasanlabs:vulnerable-shared-lib:1.0.0`

The shared library provides the following packages consumed by the primary repo:

| Package | Classes | Purpose |
|---------|---------|---------|
| `org.sasanlabs.shared.sanitizer` | `SQLParameterizer`, `HTMLSanitizer`, `CommandSanitizer`, `InputValidator`, `URLValidator` | Input sanitization (intentionally broken) |
| `org.sasanlabs.shared.util` | `JSONHelper`, `XMLHelper` | Data parsing utilities |
| `org.sasanlabs.shared.config` | `SharedDatabaseConfig`, `SharedCryptoConfig` | Configuration beans |
| `org.sasanlabs.shared.model` | `UserDTO`, `CarDTO`, `FileMetadata` | Shared data transfer objects |

### 4.2 Transitive Dependencies via Shared Library

The shared library brings in these transitive dependencies (all intentionally vulnerable):

| Dependency | Version | Known CVE | Severity |
|------------|---------|-----------|----------|
| `org.apache.logging.log4j:log4j-core` | 2.14.1 | CVE-2021-44228 (Log4Shell) | **CRITICAL** |
| `org.apache.logging.log4j:log4j-api` | 2.14.1 | CVE-2021-44228 | **CRITICAL** |
| `org.apache.commons:commons-text` | 1.8 | CVE-2022-42889 (Text4Shell) | **CRITICAL** |
| `com.fasterxml.jackson.core:jackson-databind` | 2.9.8 | CVE-2019-12384 | **HIGH** |
| `org.yaml:snakeyaml` | 1.26 | CVE-2022-1471 | **CRITICAL** |
| `com.nimbusds:nimbus-jose-jwt` | 8.3 | Multiple | **HIGH** |
| `org.json:json` | 20190722 | — | — |

### 4.3 Build Order Requirements

To build the primary repo successfully:

```
1. Clone dependent repo → ../VulnerableApp-dependent/
2. cd vulnerable-shared-lib && gradle build publishToMavenLocal
3. cd ../../Vulnerable-App-multirepo-primary && gradle build
```

Or with local path resolution:
```
1. Clone dependent repo → ../VulnerableApp-dependent/
2. cd vulnerable-shared-lib && gradle build
3. cd ../../Vulnerable-App-multirepo-primary && gradle build -PuseLocal=true
```

---

## 5. Runtime / Inter-Service Dependencies

### 5.1 Service Topology

```
┌──────────────────────────┐         ┌──────────────────────────┐
│   Primary VulnerableApp  │◄──HTTP──│  Dependent Service       │
│   Port: 9090             │         │  Port: 9091              │
│   /VulnerableApp         │         │  /DependentService       │
│                          │         │                          │
│  ┌────────────────────┐  │         │  ┌────────────────────┐  │
│  │ vulnerable-shared  │  │         │  │ vulnerable-shared  │  │
│  │ -lib (classes)     │  │         │  │ -lib (classes)     │  │
│  └────────────────────┘  │         │  └────────────────────┘  │
└──────────────────────────┘         └──────────────────────────┘
```

### 5.2 HTTP Endpoints Called by Dependent Service

The dependent service's `VulnerableAppClient` and `ProxyController` relay requests to these primary repo endpoints:

| Dependent Endpoint | Primary Endpoint Called | Vulnerability Pattern |
|-------------------|------------------------|----------------------|
| `POST /api/proxy/car` | `GET /ErrorBasedSQLInjectionVulnerability/{level}?id={id}` | SQL Injection relay |
| `POST /api/proxy/fetch` | `GET /SSRFVulnerability/{level}?fileurl={url}` | SSRF relay |
| `POST /api/proxy/ping` | `GET /CommandInjection/{level}?ipaddress={ip}` | Command Injection relay |
| `GET /api/proxy/forward` | Arbitrary path on primary | Open proxy |
| `POST /api/file/upload` | `POST /UnrestrictedFileUpload/LEVEL_1` | File upload relay |
| `GET /api/data/aggregate` | `GET /PersistentXSSInHTMLTagVulnerability/{level}` | Reverse taint XSS |

### 5.3 Runtime Failure Modes

| Scenario | Impact on Primary | Impact on Dependent |
|----------|-------------------|---------------------|
| Primary down | No direct impact | All proxy/relay endpoints return 500 |
| Dependent down | No direct impact (primary is upstream) | Service unavailable |
| Shared lib mismatch | ClassNotFoundException / NoSuchMethodError | Same |
| Port conflict | Both services fail to bind | Both services fail to bind |

---

## 6. Shared Code Dependencies

### 6.1 Import Map: Primary Repo → Shared Library

The following source files in the primary repo import from the shared library:

| Primary Repo Source File | Shared Library Import |
|--------------------------|----------------------|
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoSQLInjection.java` | `org.sasanlabs.shared.sanitizer.SQLParameterizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoXSS.java` | `org.sasanlabs.shared.sanitizer.HTMLSanitizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoCommandInjection.java` | `org.sasanlabs.shared.sanitizer.CommandSanitizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoSSRF.java` | `org.sasanlabs.shared.sanitizer.URLValidator`, `org.sasanlabs.shared.sanitizer.InputValidator` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoDeserialization.java` | `org.sasanlabs.shared.util.JSONHelper`, `org.sasanlabs.shared.util.XMLHelper`, `org.sasanlabs.shared.model.UserDTO`, `org.sasanlabs.shared.model.CarDTO` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoFileUpload.java` | `org.sasanlabs.shared.sanitizer.InputValidator`, `org.sasanlabs.shared.model.FileMetadata` |

### 6.2 Shared Library API Surface Used

```
org.sasanlabs.shared
├── sanitizer
│   ├── SQLParameterizer.parameterize(String) → String
│   ├── HTMLSanitizer.sanitize(String) → String
│   ├── CommandSanitizer.sanitize(String) → String
│   ├── InputValidator.isValidInput(String) → boolean
│   ├── InputValidator.isValidPath(String) → boolean
│   └── URLValidator.isValidURL(String) → boolean
├── util
│   ├── JSONHelper.deserialize(String, Class<T>) → T
│   └── XMLHelper.parse(String) → Document
├── config
│   ├── SharedDatabaseConfig  (JDBC settings, credentials)
│   └── SharedCryptoConfig    (encryption keys, algorithms)
└── model
    ├── UserDTO               (user data transfer object)
    ├── CarDTO                (vehicle data transfer object)
    └── FileMetadata          (file upload metadata)
```

---

## 7. Configuration & Credential Coupling

### 7.1 Shared Credentials

Both repositories use identical hardcoded credentials, creating a security coupling:

| Credential | Value | Used In |
|------------|-------|---------|
| DB Username | `admin` | Both `application.properties` |
| DB Password | `hacker` | Both `application.properties` |
| App User | `admin` / `hacker` | `SharedDatabaseConfig` |
| App User | `application` / `hacker` | `SharedDatabaseConfig` |

### 7.2 Shared Configuration Patterns

| Configuration | Primary Repo | Dependent Repo |
|---------------|-------------|----------------|
| H2 Console | Enabled at `/h2-console` | Enabled at `/h2-console` |
| Logging Level | `org.sasanlabs=DEBUG` | `org.sasanlabs=DEBUG` |
| Spring Boot Version | 2.4.5 | 2.4.5 |
| Java Target | 1.8 | 1.8 |
| Gradle Version | Wrapper | 7.5.1 (wrapper) |

### 7.3 Crypto Configuration Sharing

The `SharedCryptoConfig` class in the shared library provides encryption settings used by both repos, including:
- Hardcoded encryption keys
- Weak algorithm selections
- Shared JWT signing configuration via `nimbus-jose-jwt`

---

## 8. CI/CD & Workflow Dependencies

### 8.1 Workflow Inventory

| Workflow | Primary Repo | Dependent Repo | Shared? |
|----------|-------------|----------------|---------|
| Gradle Build | `gradle.yml` | — | No |
| Docker Publish | `docker.yml` | — | No |
| Release | `create-release.yml` | — | No |
| SonarQube | `sonar.yml` | — | No |
| JFrog Frogbot | `frogbot.yml` | — | No |
| **Phoenix PR Scan** | `phoenix-pr-scan.yml` | `phoenix-pr-scan.yml` | **Yes** |

### 8.2 Phoenix PR Scan Coupling

Both repositories share an identical Phoenix PR Scan workflow that:
- Triggers on pull request events (opened, synchronize, reopened, ready_for_review)
- Uses the same secrets: `PHOENIX_API_URL`, `PHOENIX_API_TOKEN`
- Calls the same API endpoint: `${PHOENIX_API_URL}/api/v1/pr-scan/resolve`
- Reports to the same Phoenix security platform instance

This creates an **operational coupling**: changes to the Phoenix API or token rotation must be coordinated across both repositories.

### 8.3 Build Pipeline Dependencies

The primary repo's CI **does not** automatically build the dependent repo's shared library. This means:
- The CI assumes `vulnerable-shared-lib:1.0.0` is available in the configured Maven repository
- A breaking change in the shared library will not be caught until the primary repo's CI next runs
- There is **no cross-repo CI trigger** — changes in the dependent repo do not automatically trigger builds in the primary repo

---

## 9. Vulnerability Propagation Paths

This section documents how vulnerabilities propagate across the repository boundary. This is the core purpose of the multi-repo architecture.

### 9.1 Pattern 1: Broken Sanitizer Propagation

```
[Dependent Repo]                          [Primary Repo]
vulnerable-shared-lib/                    src/.../crossrepo/
  SQLParameterizer  ──(JAR dependency)──>   CrossRepoSQLInjection.java
  HTMLSanitizer     ──(JAR dependency)──>   CrossRepoXSS.java
  CommandSanitizer  ──(JAR dependency)──>   CrossRepoCommandInjection.java
  InputValidator    ──(JAR dependency)──>   CrossRepoSSRF.java, CrossRepoFileUpload.java
  URLValidator      ──(JAR dependency)──>   CrossRepoSSRF.java
```

**Impact:** The primary repo trusts the shared library's sanitizers, but they contain intentional bypasses:
- `SQLParameterizer`: Quote-stripping bypass allows injection
- `HTMLSanitizer`: Incomplete tag filtering allows XSS
- `CommandSanitizer`: Newline/backtick bypass allows command injection
- `InputValidator`: ReDoS + path traversal bypass
- `URLValidator`: DNS rebinding bypass

### 9.2 Pattern 2: Microservice Taint Relay

```
[User Input] → [Dependent Service:9091] ──HTTP──> [Primary VulnerableApp:9090]
                ProxyController                    SQL/SSRF/CMDi endpoints
```

Untrusted user input enters the dependent service and is relayed unmodified to the primary service's vulnerable endpoints. Neither service validates the data at the boundary.

### 9.3 Pattern 3: Vulnerable Shared Models

```
[Dependent Repo]                          [Primary Repo]
shared-lib/model/                         crossrepo/
  UserDTO   ──(deserialization)──>          CrossRepoDeserialization.java
  CarDTO    ──(deserialization)──>          CrossRepoDeserialization.java
```

DTOs in the shared library may contain gadget chains exploitable during deserialization, especially via the vulnerable `jackson-databind:2.9.8`.

### 9.4 Pattern 4: Configuration & Secrets Leakage

Hardcoded credentials in `SharedDatabaseConfig` and `SharedCryptoConfig` are compiled into both applications. Compromising one repo's configuration reveals credentials valid for the other.

### 9.5 Pattern 5: Transitive Dependency Poisoning

```
[Dependent Repo]                          [Primary Repo]
vulnerable-shared-lib                     build.gradle
  log4j-core:2.14.1    ──(transitive)──>   Log4Shell exploitable
  commons-text:1.8     ──(transitive)──>   Text4Shell exploitable
  jackson-databind:2.9.8──(transitive)──>  Deserialization RCE
  snakeyaml:1.26       ──(transitive)──>   Arbitrary constructor RCE
```

The primary repo inherits all critical CVEs from the shared library's dependency tree without declaring them directly.

---

## 10. Dependency Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DEVELOPER WORKSTATION                        │
│                                                                     │
│  ┌───────────────────────────┐    ┌───────────────────────────────┐ │
│  │  Vulnerable-App-          │    │  Vulnerable-App-              │ │
│  │  multirepo-primary        │    │  multirepo-dependant          │ │
│  │                           │    │                               │ │
│  │  ┌─────────────────────┐  │    │  ┌─────────────────────────┐ │ │
│  │  │ VulnerableApp       │  │    │  │ vulnerable-shared-lib   │ │ │
│  │  │ (Spring Boot :9090) │  │    │  │ (Java Library)          │ │ │
│  │  │                     │  │    │  │                         │ │ │
│  │  │ crossrepo/*         │◄─┼─JAR┼──│ sanitizer/*             │ │ │
│  │  │  - SQLInjection     │  │    │  │ model/*                 │ │ │
│  │  │  - XSS              │  │    │  │ util/*                  │ │ │
│  │  │  - CommandInjection │  │    │  │ config/*                │ │ │
│  │  │  - SSRF             │  │    │  │                         │ │ │
│  │  │  - Deserialization  │  │    │  │ Transitive deps:        │ │ │
│  │  │  - FileUpload       │  │    │  │  log4j 2.14.1           │ │ │
│  │  │                     │  │    │  │  commons-text 1.8       │ │ │
│  │  │ Other vuln modules  │  │    │  │  jackson-databind 2.9.8 │ │ │
│  │  │  - sqlInjection/*   │  │    │  │  snakeyaml 1.26         │ │ │
│  │  │  - xss/*            │  │    │  └─────────────────────────┘ │ │
│  │  │  - jwt/*            │  │    │                               │ │
│  │  │  - ssrf/*           │  │    │  ┌─────────────────────────┐ │ │
│  │  │  - ...              │  │    │  │ vulnerable-service      │ │ │
│  │  │                     │  │    │  │ (Spring Boot :9091)     │ │ │
│  │  │                     │◄─┼HTTP┼──│                         │ │ │
│  │  │                     │  │    │  │ ProxyController         │ │ │
│  │  │                     │  │    │  │ VulnerableAppClient     │ │ │
│  │  └─────────────────────┘  │    │  └─────────────────────────┘ │ │
│  │                           │    │                               │ │
│  │  CI: gradle, docker,     │    │  CI: phoenix-pr-scan          │ │
│  │      sonar, frogbot,     │    │                               │ │
│  │      phoenix-pr-scan     │    │                               │ │
│  └───────────────────────────┘    └───────────────────────────────┘ │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Maven Local Repository                    │   │
│  │  org.sasanlabs:vulnerable-shared-lib:1.0.0                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 11. Risk Assessment

### 11.1 Dependency Risks

| Risk | Severity | Description |
|------|----------|-------------|
| **No cross-repo CI** | High | Changes to `vulnerable-shared-lib` are not automatically validated against the primary repo |
| **Local path coupling** | Medium | `useLocal=true` mode requires specific directory layout (`../VulnerableApp-dependent/`) |
| **Version pinning** | High | Both repos pin `vulnerable-shared-lib:1.0.0` with no version range or update mechanism |
| **No artifact registry** | Medium | Relies on `mavenLocal()` — no shared artifact repository for team builds |
| **Shared secrets** | High | Identical hardcoded credentials across repos mean one compromise affects both |
| **No API contract testing** | High | HTTP interface between services has no contract tests or schema validation |
| **Transitive CVEs** | Critical | 4 critical/high CVEs propagate silently through the shared library |

### 11.2 Operational Risks

| Risk | Severity | Description |
|------|----------|-------------|
| **Phoenix secret rotation** | Medium | `PHOENIX_API_TOKEN` must be rotated in both repos simultaneously |
| **Port conflicts** | Low | Both services must run on the same host (9090 + 9091) for inter-service communication |
| **No health checks** | Medium | Dependent service does not verify primary service is available before proxying |
| **No Docker for dependent** | Low | Primary has Docker support; dependent does not, complicating deployment consistency |

---

## 12. Recommendations

### For Security Scanner Testing (Current Purpose)

1. **Document the build order** in a top-level `Makefile` or `docker-compose.yml` that orchestrates both repos
2. **Add a cross-repo CI trigger** so that changes to `vulnerable-shared-lib` automatically test the primary repo
3. **Publish the shared library** to a shared artifact repository (e.g., GitHub Packages) instead of relying on `mavenLocal()`
4. **Add contract tests** for the HTTP interface between the dependent service and primary VulnerableApp

### For Multi-Repo Architecture Awareness

5. **SAST tools must scan both repos together** to detect cross-repo vulnerability patterns (broken sanitizer usage, taint relay)
6. **SCA tools must resolve transitive dependencies** from the shared library to identify inherited CVEs in the primary repo
7. **Secret scanning** should flag shared credentials across repositories as a configuration drift risk

---

## Appendix A: File Reference

### Primary Repo Files Involved in Cross-Repo Dependency

| File | Role |
|------|------|
| `build.gradle` (lines 41–43) | Declares dependency on `vulnerable-shared-lib` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoSQLInjection.java` | Uses `SQLParameterizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoXSS.java` | Uses `HTMLSanitizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoCommandInjection.java` | Uses `CommandSanitizer` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoSSRF.java` | Uses `URLValidator`, `InputValidator` |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoDeserialization.java` | Uses `JSONHelper`, `XMLHelper`, DTOs |
| `src/main/java/org/sasanlabs/service/vulnerability/crossrepo/CrossRepoFileUpload.java` | Uses `InputValidator`, `FileMetadata` |
| `.github/workflows/phoenix-pr-scan.yml` | Shared CI workflow pattern |

### Dependent Repo Files That Primary Depends On

| File | Role |
|------|------|
| `vulnerable-shared-lib/build.gradle` | Defines the published library and its vulnerable dependencies |
| `vulnerable-shared-lib/src/main/java/org/sasanlabs/shared/sanitizer/*.java` | Broken sanitizer implementations |
| `vulnerable-shared-lib/src/main/java/org/sasanlabs/shared/model/*.java` | Shared DTOs |
| `vulnerable-shared-lib/src/main/java/org/sasanlabs/shared/util/*.java` | JSON/XML parsing utilities |
| `vulnerable-shared-lib/src/main/java/org/sasanlabs/shared/config/*.java` | Shared configuration beans |
| `vulnerable-service/src/main/java/org/sasanlabs/dependent/service/VulnerableAppClient.java` | HTTP client calling primary repo |
| `vulnerable-service/src/main/java/org/sasanlabs/dependent/controller/ProxyController.java` | Proxy endpoints relaying to primary |
| `vulnerable-service/src/main/resources/application.properties` | Contains primary repo's base URL |

---

## Appendix B: Quick Reference — How to Build Both Repos

```bash
# 1. Clone both repositories side by side
git clone https://github.com/Security-Phoenix-demo/Vulnerable-App-multirepo-dependant.git
git clone https://github.com/Security-Phoenix-demo/VulnerableApp.git

# 2. Build and publish the shared library
cd Vulnerable-App-multirepo-dependant/vulnerable-shared-lib
./gradlew build publishToMavenLocal

# 3. Build the dependent service
cd ../vulnerable-service
./gradlew build

# 4. Build the primary VulnerableApp
cd ../../VulnerableApp
./gradlew build

# OR: Build primary with local JAR reference (no Maven publish needed)
./gradlew build -PuseLocal=true

# 5. Run both services
cd ../Vulnerable-App-multirepo-dependant/vulnerable-service
./gradlew bootRun &

cd ../../VulnerableApp
./gradlew bootRun &

# Primary:   http://localhost:9090/VulnerableApp
# Dependent: http://localhost:9091/DependentService
```
