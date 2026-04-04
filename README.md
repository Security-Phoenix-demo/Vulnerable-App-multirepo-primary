# ![OWASP VulnerableApp](https://raw.githubusercontent.com/SasanLabs/VulnerableApp/master/docs/logos/Coloured/iconColoured.png) OWASP VulnerableApp

![OWASP Incubator](https://img.shields.io/badge/owasp-incubator-blue.svg) ![](https://img.shields.io/github/v/release/SasanLabs/VulnerableApp?style=flat) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Java CI with Gradle](https://github.com/SasanLabs/VulnerableApp/workflows/Java%20CI%20with%20Gradle/badge.svg) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![Docker Pulls](https://badgen.net/docker/pulls/sasanlabs/owasp-vulnerableapp?icon=docker&label=pulls)](https://hub.docker.com/r/sasanlabs/owasp-vulnerableapp/) [![codecov](https://codecov.io/gh/SasanLabs/VulnerableApp/graph/badge.svg?token=DTS3PA8WXZ)](https://codecov.io/gh/SasanLabs/VulnerableApp)

> **WARNING: This application contains intentional security vulnerabilities. Do NOT deploy in production environments. Use only for security training, vulnerability scanner testing, and educational purposes.**

As Web Applications are becoming popular these days, there comes a dire need to secure them. Although there are several Vulnerability Scanning Tools, however while developing these tools, developers need to test them. Moreover, they also need to know how well the Vulnerability Scanning tool is performing. As of now, there are little or no such vulnerable applications existing for testing such tools. There are Deliberately Vulnerable Applications existing in the market but they are not written with such an intent and hence lag extensibility, e.g. adding new vulnerabilities is quite difficult. Hence, developers resort to writing their own vulnerable applications, which usually causes productivity loss and the pain of reworking.

**VulnerableApp** is built keeping these factors in mind. This project is scalable, extensible, easier to integrate and easier to learn. As solving the above issue requires addition of various vulnerabilities, hence it becomes a very good platform to learn various security vulnerabilities.

### User Interface
![VulnerableApp-facade UI](https://raw.githubusercontent.com/SasanLabs/VulnerableApp-facade/main/docs/images/gif/VulnerableApp-Facade.gif)

## Technologies Used

- Java 8
- Spring Boot 2.4.5
- Gradle Build System
- H2 In-Memory Database
- Nimbus Jose JWT 8.3
- Docker / Docker Compose
- ReactJS (UI Facade)

---

## Project Architecture

```
VulnerableApp/
├── .github/workflows/              # CI/CD pipelines
│   ├── create-release.yml          # Release automation
│   ├── docker.yml                  # Docker image build & push
│   ├── frogbot.yml                 # JFrog Frogbot security scanning
│   ├── gradle.yml                  # Build and test
│   └── sonar.yml                   # SonarQube static analysis
│
├── src/main/java/org/sasanlabs/
│   ├── Application.java                          # Spring Boot entry point
│   ├── beans/
│   │   ├── AllEndPointsResponseBean.java         # Endpoint metadata response DTO
│   │   └── ScannerResponseBean.java              # Scanner result response DTO
│   ├── configuration/
│   │   └── VulnerableAppConfiguration.java       # Spring security & web config
│   ├── controller/
│   │   ├── AppController.java                    # Main REST controller
│   │   └── exception/
│   │       ├── ControllerException.java          # Custom exception class
│   │       └── ControllerExceptionHandler.java   # Global exception handler
│   ├── internal/utility/
│   │   ├── EnvUtils.java                         # Environment utilities
│   │   ├── GenericUtils.java                     # Generic helper methods
│   │   ├── JSONSerializationUtils.java           # JSON serialization helpers
│   │   ├── LevelConstants.java                   # Level identifier constants (LEVEL_1-10)
│   │   ├── MessageBundle.java                    # i18n message support
│   │   ├── FrameworkConstants.java               # Framework-wide constants
│   │   └── annotations/
│   │       ├── VulnerableAppRestController.java  # Marks vulnerability endpoint classes
│   │       ├── VulnerableAppRequestMapping.java  # Marks vulnerability methods with levels
│   │       └── AttackVector.java                 # Documents vulnerability type & payloads
│   ├── service/
│   │   ├── impl/
│   │   │   └── EndPointsInformationProvider.java # Scans classpath for vulnerability metadata
│   │   ├── exception/
│   │   │   └── ServiceApplicationException.java  # Service layer exception
│   │   └── vulnerability/                        # *** ALL VULNERABILITY IMPLEMENTATIONS ***
│   │       ├── commandInjection/
│   │       ├── fileupload/
│   │       ├── jwt/
│   │       ├── pathTraversal/
│   │       ├── rfi/
│   │       ├── sqlInjection/
│   │       ├── ssrf/
│   │       ├── urlRedirection/
│   │       ├── xss/
│   │       ├── xxe/
│   │       └── crossrepo/                        # Cross-repository vulnerability demos
│   └── vulnerability/types/
│       └── VulnerabilityType.java                # Enum of all vulnerability categories
│
├── src/main/resources/
│   ├── log4j2.xml                                # Logging configuration
│   └── scripts/PathTraversal/                    # Test files for path traversal
│       ├── UserInfo.json
│       ├── OwaspAppInfo.json
│       └── secret.json
│
├── src/test/java/org/sasanlabs/                  # Unit tests
│
├── VulnerableApp-dependent/                      # Cross-repo vulnerability sub-project
│   ├── vulnerable-shared-lib/                    # Shared library with intentional vulns
│   └── vulnerable-service/                       # Service consuming the shared library
│
├── docs/                                         # Documentation & blogs
├── scanner/                                      # External scanner integration
├── build.gradle                                  # Root Gradle build config
├── docker-compose.yml                            # Multi-service Docker deployment
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## Key Files & Dependencies

### Framework Layer

| File | Purpose | Depends On |
|------|---------|------------|
| `Application.java` | Spring Boot entry point, bootstraps the app | Spring Boot |
| `VulnerableAppConfiguration.java` | Disables CSRF, configures CORS, enables H2 console | Spring Security |
| `AppController.java` | REST controller serving vulnerability metadata to UI | `EndPointsInformationProvider` |
| `EndPointsInformationProvider.java` | Scans classpath for `@VulnerableAppRestController` and `@AttackVector` annotations, builds endpoint registry | All vulnerability classes |
| `ControllerExceptionHandler.java` | Global `@ControllerAdvice` for error handling | `ControllerException` |

### Custom Annotations

| Annotation | Purpose | Used By |
|------------|---------|---------|
| `@VulnerableAppRestController` | Marks a class as a vulnerability endpoint (value = path, descriptionLabel = i18n key) | All vulnerability classes |
| `@VulnerableAppRequestMapping` | Maps a method to a difficulty level (LEVEL_1-6), HTML template, HTTP method, and variant (SECURE or default) | All vulnerability methods |
| `@AttackVector` | Documents the vulnerability type exposed, description, and example payload | All vulnerability methods |

### Utility Layer

| File | Purpose | Used By |
|------|---------|--------|
| `EnvUtils.java` | Environment variable helpers | Configuration |
| `GenericUtils.java` | Generic utility methods | Various |
| `JSONSerializationUtils.java` | JSON serialization/deserialization | Controllers, services |
| `LevelConstants.java` | Constants: `LEVEL_1` through `LEVEL_10` | All vulnerability classes |
| `MessageBundle.java` | i18n message resolution | UI labels |

---

## Vulnerability Implementations (Detailed)

Each vulnerability is implemented as a Spring REST controller with progressive difficulty levels (LEVEL_1 = easiest to exploit, LEVEL_5/6 = secure). Located under `src/main/java/org/sasanlabs/service/vulnerability/`.

---

### 1. SQL Injection (`sqlInjection/`)

#### ErrorBasedSQLInjectionVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | Direct concatenation: `"select * from cars where id=" + id` | Any SQL payload |
| LEVEL_2 | Single-quote wrapped: `"id='" + id + "'"` | Close quote: `' OR 1=1--` |
| LEVEL_3 | Strips single quotes via `replaceAll("'", "")` | Double quote or backslash bypass |
| LEVEL_4 | PreparedStatement but still concatenates string | Same as LEVEL_2 |
| LEVEL_5 | **SECURE** - Proper `PreparedStatement.setString()` | N/A |

**Dependencies:** `JdbcTemplate`, `CarInformation` (JPA Entity), `CarInformationRepository`

#### UnionBasedSQLInjectionVulnerability.java
Same progressive pattern with UNION-based SQL injection techniques.

**Dependencies:** `JdbcTemplate`, `CarInformation`, `CarInformationRepository`

#### BlindSQLInjectionVulnerability.java
Time-based and boolean-based blind SQL injection.

**Dependencies:** `JdbcTemplate`, `CarInformation`

#### Supporting Files
| File | Purpose |
|------|---------|
| `CarInformation.java` | JPA entity mapped to `cars` table (id, name, imageePath) |
| `CarInformationRepository.java` | Spring Data JPA repository for `CarInformation` |

---

### 2. Command Injection (`commandInjection/`)

#### CommandInjection.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | Direct: `ProcessBuilder("sh", "-c", "ping -c 2 " + ipAddress)` | `;cat /etc/passwd` |
| LEVEL_2 | Blocks `;`, `&` | URL-encoded `%26`, `%3B` |
| LEVEL_3 | Blocks URL-encoded separators | Case variation `%3b` vs `%3B` |
| LEVEL_4 | Case-insensitive URL encoding block | Pipe `\|` |
| LEVEL_5 | Blocks pipe `\|` and additional separators | Newline `%0a` |
| LEVEL_6 | **SECURE** - Strict IP regex validation `^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$` | N/A |

**Dependencies:** `ProcessBuilder`, `Runtime`, regex validation patterns

---

### 3. Cross-Site Scripting - Reflected (`xss/reflected/`)

#### XSSWithHtmlTagInjection.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | Direct output: `<div>%s</div>` | `<script>alert(1)</script>` |
| LEVEL_2 | Blocks `<script>`, `<img>`, `<a>` tags | `<svg onload=alert(1)>`, `<object>` |
| LEVEL_3 | Blocks tags + `alert` and `javascript` keywords | `<svg onload=confirm(1)>`, encoding |

#### XSSInImgTagAttribute.java
Injection within `<img>` tag attribute context with progressive filtering.

**Dependencies:** HTTP parameter map, `Pattern` matching

---

### 4. Cross-Site Scripting - Persistent (`xss/persistent/`)

#### PersistentXSSInHTMLTagVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | No validation - direct DB store and retrieve | Any XSS payload |
| LEVEL_2 | Basic script tag filter | SVG, event handlers |
| LEVEL_3 | Extended tag filter | Null byte injection |
| LEVEL_4 | Null byte handling | Double encoding |
| LEVEL_5 | Enhanced filtering | Mutation XSS |
| LEVEL_6 | **SECURE** - `StringEscapeUtils.escapeHtml4()` output encoding | N/A |

**Dependencies:** `PostRepository` (JPA), `Post` entity (id, content, levelIdentifier)

#### Supporting Files
| File | Purpose |
|------|---------|
| `Post.java` | JPA entity storing XSS payloads (id, content, levelIdentifier) |
| `PostRepository.java` | Spring Data JPA repository for `Post` |

---

### 5. JWT Vulnerabilities (`jwt/`)

#### JWTVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | JWT exposed in URL, no secure flag | Token interception |
| LEVEL_2 | Accepts "none" algorithm | Algorithm downgrade attack |
| LEVEL_3 | Weak HMAC key (6 characters) | Brute force / dictionary |
| LEVEL_4 | JWT in insecure cookie (no HttpOnly/Secure) | XSS cookie theft |
| LEVEL_5+ | Progressive hardening | Varies |

**Dependencies:**
| File | Purpose |
|------|---------|
| `JWTValidator.java` | Validates JWT tokens, checks signatures |
| `LibBasedJWTGenerator.java` | Generates tokens using Nimbus Jose JWT library |
| `JWTAlgorithmKMS.java` | Key management system for JWT algorithms |
| `SymmetricAlgorithmKey.java` | HMAC key storage |

---

### 6. Path Traversal (`pathTraversal/`)

#### PathTraversalVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | Direct: `getResourceAsStream("/scripts/PathTraversal/" + fileName)` | `../../etc/passwd` |
| LEVEL_2 | Blocks `..` literal | URL encoding: `..%2f` |
| LEVEL_3 | Blocks URL-encoded variants | Double encoding |
| LEVEL_4 | Whitelist validation | N/A (secure for listed files) |
| LEVEL_5+ | **SECURE** - Strict validation | N/A |

**Target Files:** `UserInfo.json`, `OwaspAppInfo.json`, `secret.json` in `/resources/scripts/PathTraversal/`

---

### 7. File Upload (`fileupload/`)

#### UnrestrictedFileUpload.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | No validation - saves with original filename | Upload `.jsp`, `.html` |
| LEVEL_2 | MIME type check | MIME spoofing (modify Content-Type) |
| LEVEL_3 | Extension blacklist | Double extension: `shell.php.jpg` |
| LEVEL_4 | Enhanced extension check | Null byte: `shell.php%00.jpg` |
| LEVEL_5 | Content validation | Polyglot files |
| LEVEL_6 | **SECURE** - Validates + renames file | N/A |

**Dependencies:** `MultipartFile`, `Files`, `Path`
**Upload Directories:** `static/upload/`, `static/contentDispositionUpload/`

#### PreflightController.java
Handles CORS preflight requests for cross-origin file upload testing.

---

### 8. Server-Side Request Forgery (`ssrf/`)

#### SSRFVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | Direct URL fetch via `URLConnection` | `file:///etc/passwd`, internal IPs |
| LEVEL_2 | Blocks `file://` protocol | `http://169.254.169.254` (metadata) |
| LEVEL_3 | Validates against localhost/private IPs | DNS rebinding, IPv6 |
| LEVEL_4+ | **SECURE** - Strict URL validation | N/A |

#### MetaDataServiceMock.java
Simulates AWS/GCP cloud metadata service endpoint for SSRF demonstration.

**Dependencies:** `URL`, `URLConnection`, regex URL validation

---

### 9. XML External Entity (`xxe/`)

#### XXEVulnerability.java
| Level | Technique | Bypass Method |
|-------|-----------|---------------|
| LEVEL_1 | No XXE protection - direct JAXB unmarshal | External entity: `<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>` |
| LEVEL_2 | Partial protection | Parameter entities |
| LEVEL_3-5 | Progressive protections | Varies |
| LEVEL_6 | **SECURE** - All XXE features disabled | N/A |

**Note:** Sets `javax.xml.accessExternalDTD = "all"` system property on initialization (VULNERABLE).

#### Supporting Files
| File | Purpose |
|------|---------|
| `Book.java` | JAXB-annotated XML bean |
| `ObjectFactory.java` | JAXB factory class |
| `BookEntity.java` | JPA entity for stored XML data |
| `BookEntityRepository.java` | Spring Data JPA repository |

---

### 10. Open Redirect (`urlRedirection/`)

| File | Technique |
|------|-----------|
| `Http3xxStatusCodeBasedInjection.java` | HTTP 301/302 redirect with user-controlled Location header |
| `MetaTagBasedInjection.java` | HTML meta refresh tag with user URL |
| `RefreshHeaderBasedInjection.java` | HTTP Refresh header with user URL |
| `ClientSideInjection.java` | JavaScript `window.location` redirect |

Each has multiple levels with progressive URL validation.

---

### 11. Remote File Inclusion (`rfi/`)

#### UrlParamBasedRFI.java
Includes remote files via user-controlled URL parameter.

---

### 12. Cross-Repository Vulnerabilities (`crossrepo/`)

These demonstrate how vulnerabilities propagate through shared libraries across repository boundaries.

#### CrossRepoSQLInjection.java
| Level | Shared Lib Function | Vulnerability |
|-------|---------------------|---------------|
| LEVEL_1 | `SQLParameterizer.sanitize()` | Strips quotes but backslash-quote bypasses |
| LEVEL_2 | `SQLParameterizer.buildWhereClause()` | Uses bypassable `sanitize()` internally |
| LEVEL_3 | `SQLParameterizer.buildNumericQuery()` | `isNumeric()` allows hex/scientific notation |

#### CrossRepoXSS.java
| Level | Shared Lib Function | Vulnerability |
|-------|---------------------|---------------|
| LEVEL_1 | `HTMLSanitizer.sanitize()` | Misses `<svg>`, `<math>`, `<details>` tags |
| LEVEL_2 | `HTMLSanitizer.containsHTML()` | Naive `<` check - HTML entities bypass |
| LEVEL_3 | `HTMLSanitizer.sanitizeTemplate()` | Text4Shell (CVE-2022-42889) via commons-text 1.8 |

#### CrossRepoDeserialization.java
| Level | Shared Lib Function | Vulnerability |
|-------|---------------------|---------------|
| LEVEL_1 | `JSONHelper.fromJSON()` | `enableDefaultTyping` + jackson-databind 2.9.8 = RCE |
| LEVEL_2 | `CarDTO` deserialization | Custom `readObject()` executes command field |
| LEVEL_3 | `XMLHelper.parseXML()` | XXE + Log4Shell (CVE-2021-44228) via log4j 2.14.1 |
| LEVEL_4 | `SharedDatabaseConfig` + `SharedCryptoConfig` | Hardcoded credentials exposure |

#### CrossRepoCommandInjection.java
| Level | Shared Lib Function | Vulnerability |
|-------|---------------------|---------------|
| LEVEL_1 | `CommandSanitizer.sanitize()` | Misses newline, backtick, `$()` subshell |
| LEVEL_2 | `CommandSanitizer.buildPingCommand()` | `isValidIPAddress()` allows trailing chars |

#### CrossRepoPathTraversal.java
Uses shared lib `InputValidator` - ReDoS vulnerable regex, misses URL-encoded path sequences.

#### CrossRepoSSRF.java
Uses shared lib `URLValidator` - DNS rebinding, IPv6, octal/decimal IP bypasses.

---

## Cross-Repository Controller Summary

The parent VulnerableApp includes these new controllers that import and use the shared library from `VulnerableApp-dependent`:

| Controller | Levels | Cross-repo Pattern | Scanner Proof Value |
|------------|--------|--------------------|---------------------|
| `CrossRepoSQLInjection` | 3 | Broken `SQLParameterizer` from shared lib | Taint crosses JAR boundary through sanitizer return value |
| `CrossRepoXSS` | 3 | Broken `HTMLSanitizer` + Text4Shell | Incomplete filter + CVE-2022-42889 in transitive dep |
| `CrossRepoCommandInjection` | 2 | Broken `CommandSanitizer` | Sanitizer misses newline/backtick — taint survives cross-lib call |
| `CrossRepoSSRF` | 2 | Broken `URLValidator` (no DNS resolution) | String-based validation bypassed by DNS rebinding |
| `CrossRepoPathTraversal` | 3 | Broken `InputValidator` + `FileMetadata` | ReDoS + URL-encoded bypass across module boundary |
| `CrossRepoDeserialization` | 4 | `JSONHelper` RCE, `XMLHelper` XXE/Log4Shell, config leakage | enableDefaultTyping + CVE-2021-44228 + hardcoded creds |

**All 5 patterns covered:** broken sanitizers, microservice taint relay, shared vulnerable models, config/secrets leakage, transitive dependency poisoning.

---

## Vulnerability Dependency Graph

```
User Input (HTTP Request)
    |
    v
VulnerableApp Endpoints (@VulnerableAppRestController)
    |
    +---> Direct Vulnerabilities
    |     |
    |     +-- CommandInjection ---------> ProcessBuilder ---------> OS Execution
    |     +-- SQLInjection -------------> JdbcTemplate ------------> H2 Database
    |     +-- XSS (Reflected) ----------> String Concatenation ----> HTML Response
    |     +-- XSS (Persistent) ---------> PostRepository ----------> H2 DB --> HTML Response
    |     +-- PathTraversal ------------> getResourceAsStream -----> File System
    |     +-- FileUpload ---------------> MultipartFile -----------> File System
    |     +-- SSRF ---------------------> URLConnection -----------> Network (metadata)
    |     +-- XXE ----------------------> JAXB/SAXParser ----------> XML Parser (ext entities)
    |     +-- JWT ----------------------> JWTValidator/Generator --> Token Handling
    |     +-- OpenRedirect -------------> HTTP Response Headers ---> Browser Redirect
    |     +-- RFI ----------------------> URL Parameter -----------> Remote Resource
    |
    +---> Cross-Repo Vulnerabilities (via VulnerableApp-dependent/vulnerable-shared-lib)
          |
          +-- CrossRepoSQLInjection ----> SQLParameterizer --------> Bypassable Sanitization
          +-- CrossRepoXSS -------------> HTMLSanitizer -----------> Incomplete Tag Filter
          +-- CrossRepoCommandInjection -> CommandSanitizer -------> Incomplete Blacklist
          +-- CrossRepoDeserialization --> JSONHelper --------------> enableDefaultTyping (RCE)
          |                            -> XMLHelper ---------------> XXE + Log4Shell
          |                            -> SharedDatabaseConfig ----> Hardcoded Credentials
          +-- CrossRepoPathTraversal ---> InputValidator ----------> ReDoS + Bypass
          +-- CrossRepoSSRF ------------> URLValidator ------------> DNS Rebinding Bypass

Shared Library (vulnerable-shared-lib) Transitive Dependencies:
    +-- log4j-core 2.14.1 -----------> CVE-2021-44228 (Log4Shell)
    +-- commons-text 1.8 ------------> CVE-2022-42889 (Text4Shell)
    +-- jackson-databind 2.9.8 ------> CVE-2019-12384 (Deserialization RCE)
    +-- snakeyaml 1.26 --------------> CVE-2022-1471 (Arbitrary Constructor)
```

---

## Complete Vulnerability Inventory

### Direct Vulnerabilities (VulnerableApp Core)

| # | Category | Type | File | Levels | Secure Level |
|---|----------|------|------|--------|--------------|
| 1 | SQL Injection | Error-Based | `ErrorBasedSQLInjectionVulnerability.java` | 5 | LEVEL_5 |
| 2 | SQL Injection | Union-Based | `UnionBasedSQLInjectionVulnerability.java` | 5 | LEVEL_5 |
| 3 | SQL Injection | Blind | `BlindSQLInjectionVulnerability.java` | 5 | LEVEL_5 |
| 4 | Command Injection | OS Command | `CommandInjection.java` | 6 | LEVEL_6 |
| 5 | XSS | Reflected (HTML Tag) | `XSSWithHtmlTagInjection.java` | 3+ | Varies |
| 6 | XSS | Reflected (IMG Attr) | `XSSInImgTagAttribute.java` | 3+ | Varies |
| 7 | XSS | Persistent (HTML Tag) | `PersistentXSSInHTMLTagVulnerability.java` | 6 | LEVEL_6 |
| 8 | JWT | Multiple | `JWTVulnerability.java` | 7+ | Varies |
| 9 | Path Traversal | File Read | `PathTraversalVulnerability.java` | 5+ | LEVEL_4+ |
| 10 | File Upload | Unrestricted | `UnrestrictedFileUpload.java` | 6 | LEVEL_6 |
| 11 | SSRF | URL Fetch | `SSRFVulnerability.java` | 4+ | LEVEL_4+ |
| 12 | XXE | Entity Expansion | `XXEVulnerability.java` | 6 | LEVEL_6 |
| 13 | Open Redirect | 3xx Status | `Http3xxStatusCodeBasedInjection.java` | 3+ | Varies |
| 14 | Open Redirect | Meta Tag | `MetaTagBasedInjection.java` | 3+ | Varies |
| 15 | Open Redirect | Refresh Header | `RefreshHeaderBasedInjection.java` | 3+ | Varies |
| 16 | Open Redirect | Client-Side JS | `ClientSideInjection.java` | 3+ | Varies |
| 17 | RFI | URL Parameter | `UrlParamBasedRFI.java` | 3+ | Varies |

### Cross-Repository Vulnerabilities

| # | Category | File | Shared Lib Dependency | CVE(s) |
|---|----------|------|-----------------------|--------|
| 18 | SQL Injection | `CrossRepoSQLInjection.java` | `SQLParameterizer` | N/A (logic flaw) |
| 19 | XSS | `CrossRepoXSS.java` | `HTMLSanitizer` | CVE-2022-42889 (Text4Shell) |
| 20 | Deserialization / RCE | `CrossRepoDeserialization.java` | `JSONHelper`, `XMLHelper` | CVE-2019-12384, CVE-2021-44228 |
| 21 | Command Injection | `CrossRepoCommandInjection.java` | `CommandSanitizer` | N/A (logic flaw) |
| 22 | Path Traversal | `CrossRepoPathTraversal.java` | `InputValidator` | N/A (logic flaw) |
| 23 | SSRF | `CrossRepoSSRF.java` | `URLValidator` | N/A (logic flaw) |

### Known Vulnerable Dependencies (Transitive via shared-lib)

| Dependency | Version | CVE | Severity | Impact |
|------------|---------|-----|----------|--------|
| log4j-core | 2.14.1 | CVE-2021-44228 | **CRITICAL** (10.0) | Remote Code Execution via JNDI lookup |
| commons-text | 1.8 | CVE-2022-42889 | **CRITICAL** (9.8) | Remote Code Execution via StringSubstitutor |
| jackson-databind | 2.9.8 | CVE-2019-12384 | **HIGH** (8.1) | RCE via polymorphic deserialization |
| snakeyaml | 1.26 | CVE-2022-1471 | **CRITICAL** (9.8) | RCE via arbitrary constructor invocation |
| h2 database | 1.3.176 | Multiple | **HIGH** | SQL injection in H2 console |

---

## Database

### H2 In-Memory Database

**Access URL:** `http://localhost:9090/VulnerableApp/h2`

| Property | Value |
|----------|-------|
| JDBC URL | `jdbc:h2:mem:testdb` |
| User Name | `admin` |
| Password | `hacker` |

**Auto-Created Tables:**
| Table | Columns | Used By |
|-------|---------|---------|
| `cars` | id, name, imageePath | SQL Injection vulnerabilities |
| `posts` | id, levelIdentifier, content | Persistent XSS vulnerabilities |
| `bookentity` | id, levelIdentifier, content | XXE vulnerabilities |

---

## Running the Project

### Option 1: Docker (Recommended)

```bash
# Full deployment with UI facade
docker-compose pull && docker-compose up
```

Navigate to `http://localhost` for the full UI.

**Docker Compose Services:**
| Service | Description |
|---------|-------------|
| VulnerableApp-base | Main Java/Spring Boot app |
| VulnerableApp-jsp | Alternative JSP version |
| VulnerableApp-php | Alternative PHP version |
| VulnerableApp-facade | Nginx reverse proxy frontend |

### Option 2: Standalone JAR

```bash
# Download from Releases page
java -jar VulnerableApp-1.0.0.jar
```

Navigate to `http://localhost:9090/VulnerableApp`

### Option 3: IDE (Development)

```bash
./gradlew bootRun
```

Navigate to `http://localhost:9090/VulnerableApp`

---

## Building the Project

### Docker Build

```bash
./gradlew jibDockerBuild
docker-compose up
```

### Gradle Build

```bash
./gradlew build
```

### With Cross-Repo Shared Library

```bash
# Build the shared library first
cd VulnerableApp-dependent
./gradlew :vulnerable-shared-lib:build :vulnerable-shared-lib:publishToMavenLocal

# Then build main app with shared lib
cd ..
./gradlew build
```

---

## Sub-Projects

### VulnerableApp-dependent/

A separate Gradle multi-module project demonstrating **cross-repository vulnerability patterns**. Contains:

- **vulnerable-shared-lib/** - Intentionally vulnerable shared library (broken sanitizers, vulnerable dependencies, hardcoded credentials)
- **vulnerable-service/** - Spring Boot service consuming the shared library, demonstrating microservice taint relay

See [VulnerableApp-dependent/README.md](VulnerableApp-dependent/README.md) for full details.

---

## Contributing to Project

There are multiple ways in which you can contribute to the project:

1. If you are a developer and trying to start on to the project, then the suggestion is to go through the list of [issues](https://github.com/SasanLabs/VulnerableApp/issues) which contains `good first issue` which can be a good starter.
2. If you are a developer or a security professional looking to add new Vulnerability type then you can Generate the Sample Vulnerability by running `./gradlew GenerateSampleVulnerability`. It will generate the Sample Vulnerability template which has placeholders and comments. Modified files can be seen in the logs of the command or in the github history. You can navigate to those files, fill in the placeholders and then build the project to see the effect of the changes.
3. In case you are looking to contribute to the project by publicising it or working on the growth of the project, please feel free to add your thoughts to discussions section or issues and we can discuss over them.

---

## Contact

In case you are stuck with any of the steps or understanding anything related to project and its goals, feel free to shoot a mail at karan.sasan@owasp.org or raise an [issue](https://github.com/SasanLabs/VulnerableApp/issues) and we will try our best to help you.

## Documentation and References

1. [Documentation](https://sasanlabs.github.io/VulnerableApp)
2. [Design Documentation](https://sasanlabs.github.io/VulnerableApp/DesignDocumentation.html)
3. [Owasp VulnerableApp](https://owasp.org/www-project-vulnerableapp/)
4. [Overview video for OWASP Spotlight series](https://www.youtube.com/watch?v=HRRTrnRgMjs)
5. [Overview Video](https://www.youtube.com/watch?v=AjL4B-WwrrA&ab_channel=OwaspVulnerableApp)

### Blogs
1. [Overview of Owasp-VulnerableApp - Medium article](https://hussaina-begum.medium.com/an-extensible-vulnerable-application-for-testing-the-vulnerability-scanning-tools-cc98f0d94dbc)
2. [Overview of Owasp-VulnerableApp - Blogspot post](https://hussaina-begum.blogspot.com/2020/10/an-extensible-vulnerable-application.html)
3. [Introduction to Owasp VulnerableApp by Kenji Nakajima](https://jpn.nec.com/cybersecurity/blog/220520/index.html)

### Troubleshooting references
1. [Reddit exploiting SQL Injection Vulnerability](https://www.reddit.com/r/hacking/comments/11wtf17/owasp_vulnerableappfacade_sql_injection/)

### Readme in other languages
1. [Russian](https://github.com/SasanLabs/VulnerableApp/tree/master/docs/i18n/ru/README.md)
2. [Chinese](https://github.com/SasanLabs/VulnerableApp/tree/master/docs/i18n/zh-CN/README.md)
3. [Hindi](https://github.com/SasanLabs/VulnerableApp/tree/master/docs/i18n/hi/README.md)
4. [Punjabi](https://github.com/SasanLabs/VulnerableApp/tree/master/docs/i18n/pa/README.md)
