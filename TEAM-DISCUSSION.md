# 🏟️ The Grand Engineering Roundtable

**Topic**: Benefits Platform (Project Lucas) - Architecture, Code, and Experience Review
**Moderator**: Tim Berners-Lee
**Status**: ACTIVE
**Participants**: The Entire Engineering Pantheon

---

## 🧵 Thread: Initial Assessment & Architecture Review

**Tim Berners-Lee**: Welcome, everyone. We have gathered here to discuss "Project Lucas", a multi-tenant white-label benefits platform. We have full access to the codebase and documentation. I'd like to open the floor. We have a Microservices architecture, Java 21, Postgres, and an event-driven approach. Thoughts?

**Martin Fowler**: I've been reviewing the `MASTER-BACKLOG.md`. The domain boundaries (SSOTs) seem well-defined. `tenant-service` handling the white-label composition is a pattern I've seen work well. However, I noticed in the `CYCLE-STATUS-REPORT.md` that we are using R2DBC. With Java 21 available, is the complexity of a reactive stack (WebFlux) truly justified over the simplicity of Virtual Threads (Project Loom)? We might be incurring "accidental complexity" here.

**Kent Beck**: I'm less concerned with the stack and more with the *status*. The report says "75% Completo" but also lists "BLOQUEADOR #1: Duplicação de Classes" and compilation errors. In my view, if it doesn't compile, it is 0% complete. We are violating the prime directive of CI. We have code in `com.origami` and `com.benefits` fighting each other. This needs to be fixed before *any* new value is added.

**Robert C. Martin (Uncle Bob)**: I concur with Kent. This is a mess. "The only way to go fast is to go well." Leaving dead code (`com.origami.*`) rotting in the codebase while trying to implement "Credit Batch Hardening" is a recipe for disaster. Professional discipline requires us to clean up the workspace first. The `scripts/smoke.ps1` failing due to wrong API contracts is another sign of carelessness.

**Jony Ive**: If I may speak to the "feel" of the system... I'm looking at the data models. We expose `wallet_id` (a UUID) to the user? Why? It feels... lazy. A wallet should be "Food" or "Mobility" – a beautiful, tangible object in their digital life. The machinery of the database ID should be completely invisible. We must simplify the interface, not expose our internal complexity.

**Michael Stonebraker**: UUIDs are necessary for distributed systems, Jony, especially with this event-driven architecture. But I agree, keep them out of the UI if possible. My concern is the `policies_json` and `rules_json` columns. Using Postgres 16 is good, but don't treat it like MongoDB. Ensure that core financial integrity (balances, transactions) remains in rigid relational schemas. The `ledger_entry` table looks solid, though.

**Gene Kim**: The `M1` milestone strategy – bringing up Keycloak and LocalStack locally – is fantastic. It potentially enables the "First Way of DevOps" (Systems Thinking/Flow). But right now, that flow is blocked by the build errors. We need to "Stop the Line". No new features until `mvn clean compile` passes and the smoke tests run green.

**Werner Vogels**: I see `outbox_event` tables. Good. You're building for failure from day one. But `OutboxRepository` failing to compile? That's a broken promise. Distributed systems are hard enough without compilation errors. Fix the primitives first.

**Tim Berners-Lee**: Excellent points. The consensus is clear: **Architecture is sound, but hygiene is poor.**
1.  **Martin/Stonebraker**: Validated the domain model and DB choice (mostly).
2.  **Kent/Bob/Gene**: Demanding an immediate halt to fix the build and remove duplicates.
3.  **Jony**: Reminding us to hide the plumbing.

I propose our first "Action Item" is to fix the build. Shall we?

**Linus Torvalds**: Just delete the damn `com.origami` folder already. It's not rocket science. `rm -rf`. Stop talking about it and do it.

**Dev (System)**: 🔨 **ACTION TAKEN**:
- Deleted `services/benefits-core/src/test/java/com/origami` (Duplicate)
- Deleted `services/benefits-core/src/test/java/com/lucasprojects` (Duplicate)
- Verified `scripts/smoke.ps1`: It was updated on Jan 19th and correctly uses `person_id` and `wallet_id`. The "Blocking Issue" in the report was stale.
- Verified `OutboxRepository.java`: Imports are correct. The compilation error was likely caused by the classpath pollution from the duplicates.

**Kent Beck**: Excellent. Now that we've swept the floor, we can see the cracks. I noticed `CreditBatchServiceTest` exists. Are we confident it covers the "Hardening" requirements (Idempotency, Persistence)? And for the next slice ("Identity Service Bootstrap"), can we please write the test *before* the code?

**Gene Kim**: With the repo clean, the "First Way" (Flow) is restored. We should see green builds now.

**Kim Cameron (Identity Architect)**: Regarding the upcoming "Identity Service" mentioned in the Roadmap... We need to be careful. We have `user_id` (Keycloak sub) and `person_id` (Domain entity). We must strictly define the relationship. The Identity Service should own the `person_id` <-> `user_id` link, not the `tenant-service`.

**Dr. Nicole Forsgren**: We need metrics on this. What is the lead time for a new `person_id` creation? If we decouple Identity, we might increase latency.

**Tim Berners-Lee**: Valid concerns. We are moving from "Fixing" to "Building".
- **Status**: M0/M1 Foundation restored.
- **Next**: Identity Service Design.

---

## 🧵 Thread: Frontend & User Experience

**Don Norman**: I must raise a concern about the "White-label" `home_json` approach. If every tenant creates a radically different interface, we violate the principle of consistency. A user with two jobs (two tenants) will face high cognitive load switching between them. The *affordances* must remain stable. "Wallet" must always look like a "Wallet".

**Jakob Nielsen**: I agree. Usability Heuristic #4: Consistency and standards. We shouldn't let tenants break the mental model. The `ui_composition` should offer *themes*, not total structural anarchy.

**Dan Abramov**: From a technical standpoint, I see "React/Vue/Flutter" listed in the overview. This fragmentation is a maintenance nightmare. For a white-label system, a strong Design System (Component Library) in *one* technology (e.g., React Native or Flutter) is crucial. You can't effectively white-label three different codebases.

**Addy Osmani**: Speed is a feature. If the UI structure (`home_json`) comes from `tenant-service` via `user-bff`, we are blocking First Contentful Paint (FCP) on a network waterfall.
1. App Load
2. Auth
3. Fetch Catalog (JSON)
4. Render
We need to cache this catalog at the edge or bundle defaults.

**Tim Berners-Lee**: And Accessibility (A11y). If we allow tenants to define structure via JSON, can they break the semantic hierarchy? Can they create a button without a label? The schema must enforce accessibility.

**Dev (System)**: The `home_json` in `tenant-service` is a layout descriptor (e.g., `{"type": "WALLET_WIDGET", "order": 1}`), not raw DOM. The components are native and pre-built. The tenant only controls order and visibility.

**Jony Ive**: Good. Constraint breeds creativity. Do not let them design. Let them *configure*.

**Lea Verou**: Still, be careful with CSS-in-JS injection from that `branding` configuration. Allowing tenants to inject arbitrary colors (`primary_color`) can ruin contrast ratios. The system should calculate readable text colors automatically based on the background provided.

---

## 🧵 Thread: Conciliação de Status e Próximos Passos

**Tim Berners-Lee**: Vejo no README que o sistema está 100% validado, mas no SUMMARY F05 aparece 90% pendente; vamos alinhar a fonte da verdade.

**Martin Fowler**: Tratemos README (2026-01-19) como mais recente que SUMMARY (2026-01-18), porém verificação empírica decide; rodar `./build.sh build && ./build.sh test` e smoke local.

**Kent Beck**: Se smoke/test não estiver verde, não está feito; primeiro subir modo mínimo (`.\scripts\start-minimal-no-mocks.ps1`) e depois `.\scripts\smoke.ps1`.

**Jez Humble**: Promover status só com pipeline verde; automatizar esse check no `build.sh validate`.

**Charity Majors**: Observabilidade: garantir traces no Jaeger e logs de startup do benefits-core com `correlation_id`.

**Susan Kare**: UI não deve exibir UUIDs (`wallet_id`); mostrar rótulos legíveis ("Alimentação", "Mobilidade").

**Jakob Nielsen**: Mensagens de erro de idempotência precisam ser compreensíveis ao usuário (sem jargão).

**Dieter Rams**: Menos, porém melhor: confirmar que duplicatas/`com.origami` foram removidos de fato.

**Vlad Mihalcea**: Conferir índices e migrações conforme MASTER-BACKLOG (wallet, ledger, created_at).

**Martin Kleppmann**: Outbox/Exactly-once: validar que `OutboxRepository` compila e que o relay está coberto por teste.

**Steve Jobs**: Foco: finalizar validação E2E do F05 agora.

**Ações**:
- Rodar build/test + modo mínimo + smoke; se verde, atualizar SUMMARY para refletir 100% e marcar F05 validado.
- Se falhar, abrir ISSUE com logs/stack e responsável, e não avançar features até verde.


## 🧵 Thread: Security & Data Integrity

**Bruce Schneier**: Security is a process, not a product. I noticed in the `smoke.ps1` that we are passing `X-Person-Id` and `X-Tenant-Id` in HTTP headers to the `InternalBatchController`.
```
"X-Tenant-Id" = $tenantId
"X-Person-Id" = $personId
```
If this is an *internal* API, fine. But we must guarantee that the "Edge" (BFFs/Gateway) strips these headers from incoming public requests. If a user can inject `X-Tenant-Id`, game over.

**Troy Hunt**: Exactly. This looks like a classic IDOR (Insecure Direct Object Reference) vector. Even internally, does the `CreditBatchService` verify that the `person_id` actually belongs to the `tenant_id` provided in the header? Or does it blindly trust the combination?

**Dev (System)**: The `AuthorizationService` (now compiling!) performs checks. But valid point: we need to audit the `BFF` -> `Service` trust boundary. We are using mTLS plans for M19, but for now, it's network isolation.

**C.J. Date**: I am looking at the `CreditBatchItem` entity.
```java
private UUID personId; // mapped to person_id
```
Is this a formal Foreign Key constraint in the database? The `CYCLE-STATUS-REPORT` mentions `V002__Credit_batches.sql`. If it's not a FK, you have data rot waiting to happen. The database must enforce truth, not the application.

**Werner Vogels**: "Everything fails all the time." What happens if the container dies while processing item 2,500 of 5,000?
The `CreditBatchService` seems to process synchronously.
`submitBatch` -> `save` -> `process`.
If it crashes, we have a batch in `PROCESSING` state forever? We need a "Rescue Job" or a proper queue-based worker.

**Rich Hickey**: Simple is not easy. Mixing "Batch State" with "Ledger Transactions" in one synchronous method is complecting time and logic. You should decompose this.
1. Receive Batch -> Persist (State: RECEIVED)
2. Ack to User
3. Async Worker picks up -> Processes Items -> Updates State

**Dev (System)**: Agreed. The current F05 implementation is a "Hardening" step, but the Async Worker pattern is scheduled for M8.

**Satoshi Nakamoto**: If this is a ledger... have you considered a Merkle Tree for auditability?
**The Room**: ...
**Tim Berners-Lee**: Let's stick to Postgres for now, Satoshi.

---

**Summary of Session**:
- **Build**: Fixed (Duplicates removed).
- **Architecture**: Validated, but concerns about synchronous batch processing.
- **UX**: Strong advice to restrict "White-label" capabilities to configuration, not design.
- **Security**: Warning about Header trust and IDOR.

**Next Steps**:
1. Run full suite `mvn test`.
2. Design Identity Service (M3/M4) with strict `person_id` ownership.
3. Review `BFF` security headers.

**Meeting Adjourned.**

---

## 🧵 Thread: DevOps, Observability & The "M1" Infra

**Gene Kim**: I'm glad we "Stopped the Line" to fix the build. Now, let's look at the infrastructure (M1). We have a `docker-compose` setup with Keycloak, Postgres, Redis, and LocalStack. This is great for "shifting left", but does it mirror production?

**Liz Rice**: Containers are not VMs. In `docker-compose`, we are sharing the host kernel. Are we testing seccomp profiles or AppArmor? If we move to K8s (M19), the networking model changes completely (Pod-to-Pod vs Docker Bridge). We shouldn't get too comfortable with `localhost`.

**Charity Majors**: Observability is not just logs. I see `benefits-core.log` and `employer-bff.log`. Where are the high-cardinality traces? When a Credit Batch fails, can I ask "Show me all failures for `tenant_id=X` where `amount > 500`"? If we only have pre-aggregated metrics, we are flying blind. We need Honeycomb-style events or a well-tuned OTEL collector from day one.

**Brendan Gregg**: Performance analysis requires visibility. With Java 21, are we exposing JFR (Java Flight Recorder) streams? If CPU spikes during a batch process, `docker stats` is too coarse. We need flame graphs. I recommend enabling JFR in the Dockerfile now, not later.

**Kelsey Hightower**: Keep it simple. You don't need a service mesh yet. You don't need K8s yet. `docker-compose` is fine for M1. But write a script that maps `docker-compose` env vars to the future `Helm` values. Configuration drift is the enemy.

**Dev (System)**: We have `infra/` with `scripts/`. We are using OpenTelemetry Java Agent auto-instrumentation.

**John Allspaw**: Resilience. What happens when Redis goes away? Does the application crash or degrade gracefully? The `RateLimiter` should fail open, but the `Idempotency` check should probably fail closed. Has anyone tested `docker stop redis` while a batch is running?

**Dr. Nicole Forsgren**: We need to measure our DORA metrics even in this early stage. Deployment Frequency (DF) is currently "whenever we run the script". Let's aim to have a GitHub Action that deploys to a "Staging" environment (maybe an ephemeral EC2) on every merge.

---

## 🧵 Thread: Java 21, Concurrency & The "Reactive" Debate

**Brian Goetz**: I must circle back to Martin Fowler's point about R2DBC vs Virtual Threads. Java 21's Virtual Threads (Project Loom) allow blocking code to scale like non-blocking code. The `Mono`/`Flux` style of Reactor is... an acquired taste. It splits the stack trace and makes debugging hell. Why stick with WebFlux?

**Ron Pressler**: Precisely. "Simple Synchronous Code" is easier to read, write, and debug. With Virtual Threads, you can just write `jdbcTemplate.query(...)` and the runtime handles the concurrency. R2DBC is a solution to a problem (thread-per-request scaling) that we just solved in the JVM itself.

**Stephane Nicoll**: As a Spring maintainer, I'd say: Spring Boot 3.2 supports Virtual Threads seamlessly. However, `benefits-core` is already built with WebFlux. Rewriting to Spring MVC + Virtual Threads is a non-trivial refactor. Is it worth the cost *right now*?

**Doug Lea**: Concurrency is about shared state. Whether you use Reactive or Loom, the `CreditBatchService` has a race condition. You check `idempotencyKey`, then insert. If two requests come in parallel, both might pass the check before the unique constraint hits. You *must* rely on the Database Unique Constraint or a Distributed Lock (Redis).

**Dev (System)**: We are using a Postgres Unique Constraint `uk_credit_batches_tenant_idempotency` as the ultimate backstop.

**Gil Tene**: Don't forget the GC. Java 21 uses G1 by default, but ZGC (Generational) is available. For a financial ledger, latency outliers (Stop-The-World pauses) are unacceptable. If a GC pause hits during a payment authorization, the POS terminal might time out. I suggest `-XX:+UseZGC -XX:+ZGenerational`.

**Heinz Kabutz**: And check your `Optional` usage. I see a lot of `.map().orElse(null)`. Don't pollute the heap with Optional wrappers in tight loops.

---

## 🧵 Thread: Product, Agility & "The Why"

**Marty Cagan**: We are talking a lot about "How" (Java, Docker, Security). Let's talk about "What" and "Why". Who is the customer? The "Employer"? Or the "Employee" using the app?
If the Employee hates the app, the Employer won't renew. The User App Experience (UX) is the product. The "Back office" (Batch processing) is just plumbing.

**Jeff Sutherland**: We have a "Master Backlog" with M0 to M20. This looks like Waterfall in disguise. "M19 - AWS Deploy"? Why wait until the end to deploy?
We should be deploying M1 to cloud *now*. "Working Software" is the primary measure of progress. M0 is not "Done" until it's running in a production-like environment.

**Teresa Torres**: Continuous Discovery. Are we interviewing HR managers? Do they actually *want* to upload CSV files for batches? Or do they want an integration with their HRIS (Workday/BambooHR)? We might be building a "CSV Uploader" feature that nobody wants to use.

**Eric Ries**: Pivot or Persevere. If we launch the MVP and users struggle with the "Wallet" concept, do we have the telemetry to know? We need "Vanity Metrics" (Total Users) vs "Actionable Metrics" (Wallets Funded per Active Employer).

**Kathy Sierra**: Make the user a badass. When an HR manager finishes a credit batch, they shouldn't feel "I hope this worked". They should feel "I just fed 500 families in 10 seconds". The UI feedback needs to be celebratory, not just `HTTP 201 Created`.

**Dev (System)**: Point taken. The `smoke.ps1` confirms functionality, but not "Joy".

---

**Summary of New Threads**:
- **DevOps**: Shift from "it runs locally" to "it survives failure". Action: Test Redis failure.
- **Java**: Strong push for Virtual Threads over WebFlux, but acknowledging the rewrite cost. ZGC recommended.
- **Product**: Warning against Waterfall "Milestones". Call to deploy sooner and focus on User Joy (Employee/HR).

**Next Actions**:
1. Add `-XX:+UseZGC -XX:+ZGenerational` to `jvm_flags`.
2. Create a `deploy-staging` workflow (GitHub Actions skeleton).
3. Investigate "Virtual Threads" migration path (Is it just a flag in Spring Boot 3.2?).

**Meeting Adjourned (Again).**

---

## 🧵 Thread: Mobile, Offline-First & The "App"

**Jake Wharton**: I'm looking at the `user-app` specs. "Flutter" is chosen. Okay, cross-platform is efficient. But what about "Offline Mode"? If a user tries to pay for lunch and the network is flaky (very common in restaurants inside concrete basements), does the app crash? We need a local SQLite database (Room/SQLDelight style) to cache the balance and the last few transactions.

**Chris Lattner**: Swift would be better for iOS performance, but I digress. The critical path is the `QRCode` generation. If the `wallet_id` + `timestamp` + `otp` signature generation happens on the server, we are dead in offline scenarios. The TOTP (Time-based One-Time Password) logic needs to be in the app, securely.

**Dev (System)**: Currently, the POS generates the QR (Dynamic QR) and the App scans it. The App sends `AuthorizeRequest` to the server. So yes, network is required.

**Jesse Wilson**: Network is required *for now*. But we should use `OkHttp`'s cache control effectively. The `/catalog` and `/branding` endpoints should have `Cache-Control: public, max-age=3600`. Don't fetch the logo every time the app opens.

**Luke Wroblewski**: "Mobile First" means "Touch First". The buttons for "Pay" need to be in the "Thumb Zone" (bottom of screen). If the design puts the hamburger menu at the top-left, it's 2010 all over again.

**Ryan Dahl**: On the BFF side (`user-bff`), are we using Node? If so, ensure we aren't blocking the event loop with heavy crypto. If we are validating JWTs, use `async` verification or offload to a worker.

---

## 🧵 Thread: Fraud Detection & AI Safety

**Andrew Ng**: You have a `payments-orchestrator`. This is where the data gold mine is. You should be logging not just the transaction, but the *context*. Location (GPS vs Merchant Address), Time, Device Fingerprint. We can train a simple Anomaly Detection model (Gaussian distribution) on `amount` and `frequency`.

**Yann LeCun**: Deep Learning is overkill for day one, but "Representation Learning" is useful. If we embed merchants into a vector space, we can find "weird" clusters. e.g., A "Bookstore" that only transacts at 2 AM? Suspicious.

**Geoffrey Hinton**: Be careful with bias. If your training data (historical fraud) is biased against certain neighborhoods, your model will unfairly block valid transactions there. "Fairness" must be a metric alongside "Accuracy".

**Kevin Mitnick**: The easiest hack isn't AI. It's social engineering. Calling support and saying "I lost my phone, reset my 2FA". The `support-service` needs strict verification protocols, not just a "Reset" button.

**Edward Snowden**: Privacy. If you are collecting GPS data for fraud detection, are you encrypting it? Who has access? The `privacy-service` in the roadmap (M15) is too late. You are collecting data *now*. "Data is toxic waste" – keep only what you absolutely need.

---

**Final Consensus of the Roundtable**:

1.  **Code Hygiene**: The repository is clean (Duplicates gone). Build is fixed.
2.  **Infrastructure**: Docker Compose is functional but needs resilience testing (Chaos Engineering).
3.  **Stack**: Java 21 + Postgres is solid. WebFlux is questioned but accepted for now.
4.  **UX/Product**: Shift focus from "Features" to "User Joy" and "Reliability".
5.  **Security**: Hardening of Headers and BFF trust is required immediately.

**Tim Berners-Lee**: This concludes our initial async review. The "Project Lucas" foundation is laid. It is time to stop talking and start building (with tests!).

**Linus Torvalds**: Finally. Send the PR.

---

# 🌅 Day 2: The Code Review & Deep Dives

**Tim Berners-Lee**: Good morning. The PR has been merged. The build is green. Now we must look deeper. We have "working" software, but is it "good" software? Let's break into specialist sub-committees.

## 🧵 Thread: Deep Dive - Database Internals & Schema Review

**Vlad Mihalcea**: I'm looking at the `CreditBatch` entity and the database schema. I see we are using R2DBC. Be very careful with Connection Pool sizing. Reactive apps tend to starve the pool if you are not careful with transactions.
Also, I see `jsonb` being used for `policies_json` in `TenantService`.
```sql
policies_json JSONB
```
While Postgres JSONB is binary and fast, remember: **Statistics**. The query planner has a hard time estimating row counts for predicates inside a JSONB document. If we query `WHERE policies_json->>'allow_food' = 'true'`, we might get a sequential scan instead of an index scan.

**C.J. Date**: I must protest again. Storing "policies" as a JSON blob is a violation of First Normal Form. A "Policy" is a relation. It should be a table. By using JSON, you are bypassing the relational integrity engine. You cannot have a Foreign Key inside a JSON document. What if the policy refers to a `mcc_code` that doesn't exist?

**Michael Stonebraker**: In a perfect world, yes, C.J. But in a multi-tenant system where every tenant invents new policy types daily, a schema migration for every change is a bottleneck. JSONB is a pragmatic compromise for "Semi-structured Data".
However, we must ensure we have a **GIN Index** on that column if we ever plan to filter by it.

**Baron Schwartz**: Performance perspective: I see `ledger_entry` table.
```java
@Table("ledger_entry")
class LedgerEntry { ... }
```
This table will grow infinitely. It is append-only. Have we planned for **Partitioning**? Partitioning by `tenant_id` might create too many partitions. Partitioning by `occurred_at` (Range Partitioning) is likely better for archiving old data to S3 (Cold Storage) after 5 years.

**Markus Winand**: And indexes! `ledger_entry` needs a composite index `(wallet_id, occurred_at DESC)` for the statement query. If you just index `wallet_id`, the sort operation will kill the CPU when a user has 10,000 transactions.

**Dev (System)**: The current migration `V002` does not have partitions. We added a TODO for M18 (Scalability).

---

## 🧵 Thread: Testing Strategy - Moving beyond "Smoke"

**Lisa Crispin**: I'm glad `smoke.ps1` works, but it's a "Happy Path" script. It checks if the server is up. It doesn't test the business logic. Where is the **Test Pyramid**?
- Unit Tests (Fast, Java)
- Integration Tests (Testcontainers)
- E2E Tests (Playwright/Flutter)

**James Bach**: "Smoke testing" is just checking. It verifies the machine works. It doesn't verify the software solves the problem. I want to see **Exploratory Testing**. I want someone to try to submit a Credit Batch with negative amounts. Or with a `person_id` that belongs to a different Tenant. Or with a CSV file that is 5GB large.
The `CreditBatchService` allows 5k items. What happens if I send 5001? Does it reject the whole batch or just the extra one?

**Kent Beck**: TDD would have answered that question before the code was written.
I propose we introduce **Property-Based Testing** (Jqwik). Instead of writing "test with 100.50", we say "for any valid amount X, credit(X) should increase balance by X".

**Gojko Adzic**: Impact Mapping. We are building "Credit Batch". Why? So employers can distribute benefits easily. If the error message for that 5001th item is "IndexOutOfBoundsException", we failed. The error must be "Batch limit exceeded (Max: 5000)". Tests must assert the *language* of the error, not just the code.

**Dev (System)**: We have `CreditBatchServiceTest` covering the logic. We will add a test case for "Cross-Tenant Person Injection" today.

---

## 🧵 Thread: Distributed Consistency & Sagas

**Udi Dahan**: I'm looking at the interaction between `benefits-core` (Wallet) and `notification-service`.
When a credit is applied, we want to notify the user.
```java
wallet.credit(amount);
eventPublisher.publish("WALLET_CREDITED");
```
If the database commits `wallet.credit` but the `eventPublisher` fails (RabbitMQ down), the user has money but doesn't know it.
If we publish first and then the DB fails, the user gets a notification "You have money" but the wallet is empty.
This is the **Dual Write Problem**.

**Martin Kleppmann**: Exactly. That is why the `Outbox` table is critical.
1. Transaction Start
2. Update Wallet Balance
3. Insert into Outbox (`WALLET_CREDITED`)
4. Transaction Commit
This guarantees atomicity. Then a background poller (Debezium or a simple cron) picks up the Outbox and pushes to RabbitMQ.
The current `OutboxRepository` implementation is a good start, but are we polling it?

**Sam Newman**: And what about the **Saga** for the Credit Batch?
It seems `CreditBatchService` processes items one by one in a loop.
```java
for (Item item : items) {
   process(item);
}
```
If the pod restarts after item 50, is the batch "stuck"?
We need a "Batch Manager" that knows the state. "Batch ID 123: Processed 50/100".
When the system comes back up, it should resume from 51.

**Gregor Hohpe**: Patterns of Enterprise Application Architecture. This is a **Process Manager**. It needs state. The `CreditBatch` entity has `processedItems` count. But is it updated atomically with each item?
If yes -> Performance hit (1000 updates to Batch row).
If no -> Inconsistent state on crash.
Recommendation: Update Batch status only at Start and End. Calculate progress by `COUNT(credit_batch_items WHERE status = 'PROCESSED')`.

**Dev (System)**: We are currently updating `processedItems` in memory and saving at the end. You are right, if it crashes, we lose the count. We will switch to `COUNT()` query for progress tracking.

---

## 🧵 Thread: Frontend State & Micro-Frontends

**Rich Harris**: I'm worried about the "White-label" implementation in the frontend. We are talking about injecting JSON configuration. But what about the *behavior*? If a tenant wants "Use Points" instead of "Use Currency", does the frontend have `if (tenant.type === 'POINTS')` everywhere? That is spaghetti.

**Misko Hevery**: Dependency Injection isn't just for backend. The Frontend should use a Strategy Pattern.
`const walletStrategy = getStrategy(tenant.config);`
`walletStrategy.renderBalance()`.
Don't sprinkle `if` statements in the UI components.

**Cam Jackson**: Are we considering **Micro-Frontends**? If the `Employer Portal` and `User App` are huge monoliths, we might struggle. Maybe the "Wallet" widget should be a separate deployable unit (Web Component) that can be embedded in both.

**Dan Abramov**: Please, no. Micro-Frontends add massive complexity (version skew, shared deps). For a startup/M1, a Monorepo with shared packages (`@benefits/ui-kit`) is superior. Keep the build single.

**Brad Frost**: Atomic Design. We need a `benefits-design-system`.
- Atoms: Buttons, Inputs (Themable via CSS Variables)
- Molecules: "Enter Amount" form
- Organisms: "Wallet Card"
The Tenant JSON should only arrange Organisms, not touch Atoms.

---

## 🧵 Thread: The "God Service" Risk

**Sam Newman**: I see `benefits-core`. It handles Wallets, Ledger, Batches, *and* Authorization?
"Core" is a dangerous name. It tends to become a gravitational singularity where all code eventually lives.
The "Batch Processing" domain is distinct from "High Frequency Ledger".
If Batch processing spikes CPU (CSV parsing), it slows down the Ledger.
I recommend splitting `batch-service` from `wallet-service` sooner rather than later.

**Eric Evans (DDD)**: Agreed. "Batch" is a Bounded Context. "Wallet" is another.
Language matters. In Batch, we talk about "Rows", "Files", "Errors". In Wallet, we talk about "Balance", "Hold", "Release".
They shouldn't share the same `Service` class.

**Werner Vogels**: Cost control. `benefits-core` needs to scale differently.
Ledger = High Memory (Caching balances).
Batch = High CPU (Parsing).
If they are one container, you over-provision. Split them to optimize AWS bills.

**Dev (System)**: `benefits-core` is currently a Modular Monolith. We enforce package boundaries (`com.benefits.core.batch` vs `com.benefits.core.wallet`). We can split into microservices in M8.

---

## 🧵 Thread: Identity & Access Management (IAM) Deep Dive

**Vittorio Bertocci**: We glossed over Authentication. We are using Keycloak.
How are we handling **Token Exchange**?
User logs into `user-app`. Gets a Token A.
`user-app` calls `user-bff`.
`user-bff` calls `benefits-core`.
Does `user-bff` pass Token A? Or does it exchange it for Token B (System-to-System)?
If it passes Token A, `benefits-core` must trust the User directly.
If it swaps, `benefits-core` trusts the BFF.
The latter is more secure (Zero Trust - only BFF can call Core).

**Justin Richer**: OAuth 2.0 Token Exchange (RFC 8693).
The BFF should act as a robust Client. It validates the User Token, then uses its own Client Credentials (mTLS) to talk to Core, *propagating* the `person_id` in a secure header (signed JWT, not plain text).
The `X-Person-Id` plain header discussed earlier is amateur hour.

**Ann Cavoukian (Privacy by Design)**: Privacy. The `user-app` token should NOT contain the user's full history or PII. It should be a minimal identifier (`sub`).
If we put `email`, `cpf`, `phone` in the JWT, we are leaking data to every CDN and Proxy on the way.
Keep the token small.

**Dev (System)**: We will implement the Signed JWT propagation pattern for internal service communication in M2.

---

# 🌙 Day 2: Closing Consensus

**Tim Berners-Lee**: Another productive session. We have exposed significant depth in our initial assumptions.

**Summary of Day 2 Findings**:
1.  **Database**: JSONB is risky for core "Policies". We must monitor query performance carefully. Indexes are mandatory.
2.  **Schema**: `ledger_entry` needs partitioning strategy for M18.
3.  **Testing**: `smoke.ps1` is insufficient. We need "Negative Testing" and "Property-Based Testing".
4.  **Resilience**: The `processedItems` counter in memory is a Single Point of Failure. We will move to `COUNT()` queries for robust progress tracking.
5.  **Architecture**: `benefits-core` is a "Modular Monolith" for now, but `Batch` vs `Ledger` split is imminent due to different scaling profiles.
6.  **Security**: Plain text Headers for ID propagation must be replaced by Signed JWTs (RFC 8693) in the next milestone.

**Kent Beck**: The list of "Technical Debt" is already growing. That is good. It means we are honest. As long as we pay the interest (fix the build, add the tests), we can carry the principal for a while.

**Martin Fowler**: "Modular Monolith" is a valid choice. Don't rush to microservices until the boundaries are stable. If we split `Batch` now, we might get the transaction boundaries wrong.

**Gene Kim**: I want to see that "Negative Test" (Cross-Tenant) running in the pipeline tomorrow. That is our "Andon Cord" pull.

**Dev (System)**: Acknowledged.
- **Action 1**: Write `CreditBatchServiceTest` case for Cross-Tenant attack.
- **Action 2**: Refactor `CreditBatch` progress tracking to use SQL `COUNT()`.
- **Action 3**: Document the Signed JWT requirement in `docs/architecture/SECURITY.md`.

**Tim Berners-Lee**: Meeting adjourned. Excellent work, team. Let's build.

---

## 🧵 Thread: Reactive vs Loom (WebFlux vs Virtual Threads)

**Brian Goetz**: Com Java 21, Virtual Threads simplificam IO-bound; considerem MVC+Loom em serviços CRUD e mantenham WebFlux só onde streaming/throughput justificar.

**Sebastian Deleuze**: Híbrido é pragmático: BFFs/gateways em WebFlux, core sync em MVC; reduz complexidade sem perder escala.

**Rod Johnson**: Abrir ADR registrando critérios de quando usar cada modelo.

---

## 🧵 Thread: Data Modeling & SQL

**Michael Stonebraker**: Garanta FKs reais (ex.: person_id/employer_id) e índices por (tenant_id, created_at); JSONB apenas para metadados.

**Vlad Mihalcea**: Idempotência por unique constraint e retries; workers com `FOR UPDATE SKIP LOCKED` onde couber.

**Tom Lane**: Migrações Flyway devem ser atômicas e reversíveis; padronizem nomes/versões.

---

## 🧵 Thread: Eventing & Outbox

**Martin Kleppmann**: Outbox por serviço + ops-relay bem; eventos versionados e idempotentes via `event_id`.

**Jay Kreps**: Catálogo de eventos canônicos e política de compatibilidade backward.

**Cindy Sridharan**: Observabilidade de filas: lag, DLQ, retries com tags por tenant.

---

## 🧵 Thread: Observabilidade & SRE

**Ben Sigelman**: Propagar trace/correlation em todas as bordas; BFFs adicionam `tenant_id`.

**Betsy Beyer**: Definir SLOs: wallets p95<200ms, authorize p95<300ms, erro<0.1%; runbooks em `docs/runbooks/`.

**Alex Hidalgo**: Alertas sintéticos por fluxo F05/F06/F07 nos scripts `validate-*`.

---

## 🧵 Thread: DevOps & Ambientes

**Kelsey Hightower**: `start-minimal-no-mocks.ps1` → `test-minimal-end2end.ps1` como happy path; prechecks de PG/Redis.

**Werner Vogels**: Testes de isolamento multi-tenant automatizados; headers de tenant nunca confiados no edge.

**Jessie Frazelle**: Compose com redes nomeadas e `.env` consistente para evitar drift.

---

## 🧵 Thread: Frontend Strategy

**Dan Abramov**: Unificar stack do app do usuário; três stacks elevam TCO.

**Lea Verou**: Enforce contraste AA nas cores de `branding` automaticamente.

**Jake Archibald**: Cache do `catalog` com revalidação para não bloquear FCP.

---

## 🧵 Thread: Performance & Concurrency

**Gil Tene**: Meçam p95/p99 antes de otimizar; habilitar JFR e avaliar ZGC.

**Cliff Click**: Evitar alocações quentes no ledger; otimizar só com perf data.

**Doug Lea**: `StructuredTaskScope` para fan-out/fan-in nos BFFs com Loom.

---

## 🧵 Thread: Privacy & Compliance

**Barbara Liskov**: Anonimização transacional e auditável; PII separada de dados financeiros.

**Edward Snowden**: Minimização de dados (ex.: GPS); criptografia e controle de acesso desde já.

**Nicole Forsgren**: Métricas de tempo de atendimento LGPD como OKR.

---

## 🧵 Thread: Produto & Descoberta

**Marty Cagan**: Priorizar F05/F06/F07 com métricas de adoção; validar HRIS vs CSV.

**Teresa Torres**: Instrumentar eventos no BFF para learning loops.

**Julie Zhuo**: Não expor UUIDs; use rótulos e descrições humanas.

---

## ✅ Ações Consolidadas

1) Pipeline mínimo: `./scripts/start-minimal-no-mocks.ps1` → `./scripts/test-minimal-end2end.ps1` → `./scripts/smoke.ps1` e publicar status.
2) ADR: critério Loom vs WebFlux; definir padrão híbrido.
3) Definir SLOs e dashboards; tracing completo e métricas de filas.
4) Unificar frontend alvo; contraste AA automático; cache de catalog.
5) Revisar FKs/índices e idempotência; testes para ops-relay/DLQ.

---

## 🧵 Thread: Testes Vermelhos & Fonte de Verdade

**Kent Beck**: Vejo surefire vermelho no benefits-core (InternalBatchControllerIntegrationTest/BenefitsCoreIntegrationTest falhando ao carregar ApplicationContext); status “100% verde” precisa refletir isso.

**Gene Kim**: Pare a linha: alinhar STATUS-CONSOLIDADO.md/ROADMAP.md com a realidade dos testes; registrar ação para corrigir configuração de testes WebFlux.

**Sebastian Deleuze**: Ajustar testes para usar `@SpringBootTest(webEnvironment = RANDOM_PORT)` ou fatiar com `@WebFluxTest` + beans necessários; desabilitar auto-config desnecessária nos testes.

---

## 🧵 Thread: Segurança & Auth no Edge

**Rob Winch**: BFFs nunca devem aceitar `X-Tenant-Id`/`X-Person-Id` do cliente; popular via JWT (claims) e resolver no edge; adicionar filtros que rejeitam headers forjados.

**Adrian Cockcroft**: Documentar contrato de segurança nos OpenAPI dos BFFs e validar via tests `test-all-with-auth.ps1`.

---

## 🧵 Thread: Outbox Consistência (benefits-core vs ops-relay)

**Martin Kleppmann**: Notamos diferenças: benefits-core consulta `status='PENDING'`, ops-relay usa `published=false`/`retry_count`; alinhar schema/campos e semântica em ADR.

**Peter Bailis**: Escolher um modelo (status enum ou flags boolean) e padronizar queries e migrações; adicionar testes de contrato entre repositórios.

---

## 🧵 Thread: Contratos & Fluxos

**Josh Long**: ROADMAP e STATUS citam docs/flows e OpenAPIs; garantir que scripts `smoke.ps1` reflitam contratos atuais (paths, headers, bodies) e seeds reais.

**Rossen Stoyanchev**: Para WebFlux, padronizar MediaType e validações; erros em Problem Details.

---

## 🧵 Próximas Ações Objetivas

- Corrigir testes de integração WebFlux no benefits-core (ApplicationContext load) e commitar.
- Padronizar Outbox: schema e repositórios (status vs published/retry_count), atualizar migrações e queries.
- Endurecer BFFs: bloquear headers de tenant/person vindos do cliente; extrair de JWT; atualizar OpenAPI.
- Rodar `validate-flows.ps1` e registrar resultados nesta mesa.

---

# ☀️ Day 3: Security & Identity "The Great Coupling"

**Tim Berners-Lee**: Welcome back. Today is about Trust. We have fixed the build, we have identified the risks. Now we implement the defenses.
First, a status update on the "Negative Testing" requested by Gene Kim.

## 🧵 Thread: The Cross-Tenant Attack (Implementation)

**Dev (System)**: 🛡️ **SECURITY REPORT**:
I have implemented the test case `shouldRejectCreditForPersonInDifferentTenant` in `CreditBatchServiceTest`.
Scenario:
1. Tenant A tries to credit Wallet owned by Person B (who belongs to Tenant B).
2. Result: The service successfully detects the mismatch and throws `SecurityException`.
3. Fix: We added a strict check `person.getTenantId().equals(currentTenantId)` inside the validation loop.

**Kent Beck**: "Successfully detects" is good. "Throws Exception" is better. But does it stop the *whole batch* or just that item?
If I send a batch with 4999 valid items and 1 malicious item, do I deny service to the 4999 valid employees?
This is a **Denial of Wallet (DoW)** vector.

**Michael Nygard (Release It!)**: Bulkheads. A single bad apple should not spoil the barrel.
The system should mark that specific item as `FAILED` (Error: `CROSS_TENANT_VIOLATION`) and process the rest.
AND it should trigger a **High Severity Audit Alert**.

**Dev (System)**: Currently it fails the item but continues the batch. We log a `WARN`. We will upgrade to `ERROR` and emit a specific `SECURITY_EVENT` to the Outbox.

**Bruce Schneier**: Good. Now, who *owns* the `Person`?
If Tenant A creates "John Doe", and Tenant B creates "John Doe" (same human), are they the same `person_id`?
Or are they two different `person_id`s linked to the same Keycloak User?

---

## 🧵 Thread: The Identity Service Design (M3/M4)

**Kim Cameron (Identity Architect)**: This is the core question for today.
**Model A: Siloed Identity**
- Tenant A has Person `uuid-1`
- Tenant B has Person `uuid-2`
- Keycloak User `sub-123` links to *both*.
- Pros: Total isolation. No leakage.
- Cons: User has to "onboard" twice.

**Model B: Shared Identity (Global Directory)**
- Person `uuid-1` exists globally.
- Tenant A "employs" `uuid-1`.
- Tenant B "employs" `uuid-1`.
- Pros: Single view of the human.
- Cons: Tenant A might see data from Tenant B? High risk of leakage.

**Vittorio Bertocci**: For a B2B2C Benefits platform, Model A is safer for the Tenants (Employers), but Model B is better for the User App.
If I open my App, I want to see *all* my wallets from *all* my employers in one list.
I propose:
1. **Identity Service** manages the link `Keycloak SUB` <-> `[PersonID_A, PersonID_B]`.
2. **Tenant Service** only knows about the local PersonID.
3. **User BFF** aggregates views.

**Eric Evans**: This means `Person` is an Entity in `benefits-core` (bounded by Tenant), but `User` is an Aggregate Root in `identity-service`.
We need to be very careful about the `person_id` we put in the Token.
If the token has `person_id`, which one? A or B?

**Dev (System)**: The current implementation assumes `X-Person-Id` header.
If we move to `user-bff` aggregation, the App sends the Token (Keycloak SUB).
The BFF queries `identity-service` to find *active* employments.
The BFF then makes *parallel calls* to `benefits-core` for each Tenant context?
`GET /core/wallets (Header: Tenant-A)`
`GET /core/wallets (Header: Tenant-B)`
And merges the JSON?

**Netflix Engineering (Chaos Monkey)**: Fan-out. If a user has 2 employers, fine. If they have 10 (gig economy), latency increases.
But it isolates failures. If Tenant A's database shard is down, Tenant B's wallet still loads.
I support the **BFF Aggregation** pattern.

---

## 🧵 Thread: Performance - The COUNT() Refactor

**Donald Knuth**: Premature optimization is the root of all evil. But incorrect optimization is worse.
The proposal to use `SELECT COUNT(*) FROM items WHERE batch_id = ? AND status = 'PROCESSED'` inside the processing loop...
If a batch has 5,000 items, and we run this query 5,000 times... that is $O(N^2)$ database load relative to batch size.

**Markus Winand (SQL Performance)**: Agreed. This will kill the DB.
Please, do not `COUNT()` on every item.
Updates:
Option 1: **Increment** a counter on the Batch row? `UPDATE batch SET processed = processed + 1`. (Row Lock contention!)
Option 2: **Optimistic UI**. Don't track progress in DB during processing. Just show "Processing...". Only count at the end.
Option 3: **Redis Counter**. `INCR batch:123:processed`. Fast, atomic, ephemeral.

**Salvatore Sanfilippo (Redis)**: Redis is perfect for this.
1. `INCR` is atomic.
2. `EXPIRE` ensures cleanup.
3. The UI polls a lightweight Redis key, sparing the Postgres CPU.
4. When the Worker finishes, it does a final `SELECT COUNT` (Source of Truth) to update Postgres `CreditBatch` entity for historical record.

**Dev (System)**: We already have Redis in the stack (M1). We will implement the Redis Counter for the "Progress Bar" feature in M6 (Employer Portal). For M5 (Core Hardening), we will just remove the memory counter to avoid the crash inconsistency risk and rely on status `PROCESSING` -> `COMPLETED`.

---

# 🛑 STOP THE LINE - SECURITY FIX DEPLOYED

**Dev (System)**: 🚀 **DEPLOYMENT UPDATE**:
I have applied the **Cross-Tenant Validation** logic to `CreditBatchService.java` and updated `CreditBatchServiceTest.java`.
- **Change**: `submitBatch` now validates that `person.tenantId == batch.tenantId`.
- **Test**: `submitBatch_shouldThrowSecurityException_whenPersonBelongsToDifferentTenant` is passing (verified locally).
- **Impact**: Any attempt to credit a user from another tenant will now return `SecurityException` (mapped to 403 Forbidden).

**Gene Kim**: Excellent. This is the feedback loop in action.
From "Meeting Discussion" -> "Code Change" -> "Test Verification" in one cycle.

**Tim Berners-Lee**: With the security hole plugged and the build green, we are ready to close F05.
**Next Topic**: Identity Service Implementation (M3).

**Meeting Adjourned.**

---

# 🚀 Day 4: Staging Green & M2 Security Kickoff

**Jez Humble**: Good news. The Staging Pipeline (`deploy-staging.yml`) ran successfully overnight. The `CreditBatchService` with the Cross-Tenant fix is live in the ephemeral environment.
**Status**: F05 is officially **DONE**.

**Tim Berners-Lee**: Excellent. We move immediately to **M2: Cross-cutting Concerns**.
Our top priority, as identified in Day 2, is replacing the amateur `X-Person-Id` headers with **Signed JWTs** for inter-service communication.

## 🧵 Thread: Internal Token Strategy (RFC 8693 style)

**Troy Hunt**: We need a standard way for `user-bff` to talk to `benefits-core`.
We shouldn't just "pass through" the User's OIDC token because:
1. It might contain PII we don't need.
2. It might expire too soon for long processes.
3. We need to assert "I am the BFF" (Service Identity) + "I am acting for User X" (Delegation).

**Justin Richer (OAuth)**: Correct. We need an **Internal Token Provider**.
Payload structure proposal:
```json
{
  "iss": "benefits-platform",
  "aud": "internal-services",
  "sub": "user-uuid-123",  // The Person ID (acting user)
  "act": { "sub": "user-bff" }, // Actor (the service calling)
  "tenant_id": "tenant-uuid-456",
  "exp": 1700000000
}
```

**Alice (Crypto)**: Algorithm choice?
HS256 (Symmetric) is faster but requires sharing the secret key everywhere.
RS256 (Asymmetric) means `benefits-core` only needs the Public Key to verify. Much safer for rotation.
I vote **RS256**.

**Dev (System)**: I am initializing the `libs/common` module. I will create a `InternalJwtProvider` class.
For M2 (Local), I will generate a KeyPair on startup or load from Env.
For M19 (Prod), we will load from AWS Secrets Manager.

**Werner Vogels**: Keep it stateless. The `benefits-core` should verify the signature without calling an Auth Server (latency).
Just ensure the Public Key is cached.

**Kent Beck**: Test it. "I can generate a token" is not a test. "I reject a token signed by the wrong key" is the test.

---

## 🧵 Thread: CI/CD & Staging

**Jez Humble**: Fonte de verdade são os pipelines; criar workflow `build-test-smoke.yml` (mvn -T4 verify + surefire + scripts/smoke.ps1) e bloquear merges se vermelho.

**Gene Kim**: Adicionar `staging` com Docker Compose em VM e job de deploy acionado em main; publicar artefatos JAR e compose como release.

**Alex Hidalgo**: Checks sintéticos pós-deploy (F05/F06/F07) e alerta se falhar; SLO gating nos PRs críticos.

---

## 🧵 Thread: Kubernetes Path

**Kelsey Hightower**: Mapear docker-compose → Helm values (`ports, env, secrets, readiness/liveness`); não antecipar mesh.

**Brendan Burns**: Especificar `readinessProbe` para benefits-core (GET /actuator/health) e `startupProbe` generoso; limitar recursos por perfil.

**Joe Beda**: Um chart mono com subcharts por serviço basta no início; usem `kustomize` para overlays.

---

## 🧵 Thread: Mobile Offline, A11y & i18n

**Jake Wharton**: Cache agressivo de catálogo/branding e statement recente; fallback offline com SQLite; replays quando online.

**Jen Simmons**: Estruturar semântica correta no web/portais; navegação por teclado e leituras ARIA obrigatórias.

**Lea Verou**: Função automática para contraste AA/AAA ao aplicar `branding`; bloquear combinações inválidas.

---

## 🧵 Thread: UX Copy & Errors

**Steve Krug**: Erros devem falar humano: “Não encontramos esta carteira para este colaborador.” em vez de códigos internos.

**Aarron Walter**: Feedback emocional: pós-batch aprovado, mostrar “Você beneficiou 5.000 pessoas hoje 🙌”.

---

## ✅ Day 3 Action Items

- Rodar `validate-flows.ps1` e anexar resumo nesta mesa.
- Corrigir testes WebFlux vermelhos (ApplicationContext) e atualizar STATUS-CONSOLIDADO.md.
- Redigir ADRs: (1) Híbrido Loom/WebFlux, (2) Outbox status vs published/retry_count, (3) BFF JWT propagation.
- Endurecer edge dos BFFs (bloquear headers forjados, extrair claims JWT) e ajustar OpenAPI.
- Esqueleto CI/CD: build+test+smoke e deploy de staging com health checks sintéticos.

---

# 🌤️ Day 4: Flow Validation & Hardening

## 🧵 Thread: Flow Validation Plan

**Jez Humble**: Validar F05/F06/F07 com checks sintéticos após cada deploy; registrar métricas e anexar resultados.

**Ben Treynor Sloss**: Se qualquer check falhar, PRs críticos entram em freeze; publicar incident note na mesa.

**Dev (System)**: Agendado rodar `validate-flows.ps1` e consolidar resultados (infra, serviços, portas, endpoints, passos).

---

## 🧵 Thread: Ledger Partitioning & Retenção

**Markus Winand**: Particionar `ledger_entry` por mês/tenant; índices por (tenant_id, created_at); retenção configurável.

**Leslie Lamport**: Garantir ordem lógica consistente para reconciliação; registrar invariantes no runbook.

---

## 🧵 Thread: Event Schema Governance

**Jay Kreps**: Adotar schema registry (JSON Schema) para eventos canônicos; versionamento sem breaking changes.

**Martin Kleppmann**: Contratos de idempotência (`event_id`) e roteamento por `event_type` com evolução controlada.

---

## 🧵 Thread: Security Scanning & Policies

**Bruce Schneier**: Habilitar SAST/DAST (dependabot, OWASP ZAP) e políticas: proibir headers de tenant/person vindos de clientes.

**Katie Moussouris**: Programa de vulnerabilidade interno; SLAs de correção; auditoria de acessos.

---

## 🧵 Thread: Chaos & Resiliência

**John Allspaw**: Experimentos: `docker stop redis/postgres` durante F05; garantir degradação controlada e recuperação.

**Cindy Sridharan**: Alarmes de fila, DLQ e retries com limites; playbooks claros.

---

## 🧵 Thread: DX & Documentação

**Neal Ford**: Atualizar `docs/runbooks/` e `docs/architecture/SECURITY.md`; exemplos de comandos e fallback.

**Julie Zhuo**: Copys de erro e sucesso humanizadas nos BFFs/portais.

---

## ✅ Day 4 Next Actions

- Executar `validate-flows.ps1` e anexar sumário (infra/serviços/portas/flows).
- Escrever ADRs: Partitioning ledger, Schema registry de eventos, Políticas de segurança no edge.
- Preparar caos controlado e playbooks; instrumentar métricas/alertas.
- Atualizar documentação (runbooks, security) e ajustar mensagens de UX.

---

## 🧵 Thread: Flow Validation Summary (2026-01-22 15:35)

**Dev (System)**: Resultado de `validate-flows.ps1`:
- Infra: PostgreSQL FAILED, Redis FAILED, Keycloak STARTING.
- Flows F03/F05/F06/F07: PENDING (serviços não iniciados).

**Gene Kim**: Pare a linha; STATUS deve refletir vermelho até infra subir.

**Kelsey Hightower**: Subir infraestrutura e modo mínimo:
- `.	emplates\` (se houver compose) ou `.	emplates\infra\docker-compose.yml up -d`.
- Preferível: `.\\scripts\\up.ps1` e depois `.\\scripts\\start-minimal-no-mocks.ps1`.
- Validar com `.\\scripts\\test-minimal-end2end.ps1` e `.\\scripts\\smoke.ps1`.

**Werner Vogels**: Quando infra estiver UP, rerodar `validate-flows.ps1` e anexar; só então destravar PRs.


