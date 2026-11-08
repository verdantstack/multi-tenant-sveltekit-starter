# Data residency — multi-region tenants, per-region processing policy

A tenant's data lives in **one** region, and that region's policy decides what the
application is willing to do with it. This document covers the model, every
control it enforces, and — deliberately — what it does **not** do.

> **Read this first.** The policy values shipped in `src/lib/server/regions.ts`
> are a defensible starting configuration, **not legal advice**. Retention,
> erasure-SLA and transfer settings differ by contract and by statute, and they
> are yours to set with counsel. Every value is in one file, on purpose:
> [`POLICY_REVIEW_NOTICE`](../src/lib/server/regions.ts) travels with the numbers
> into the UI so a reader is never told they are authoritative.

---

## 1. The model

| Concept               | Where it lives                             | Why                                                                                                        |
| --------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| **Region catalogue**  | `src/lib/server/regions.ts` (code, frozen) | A table would let a tenant pick a jurisdiction the operator does not run                                   |
| **Policy per region** | `Region.policy` in the same file           | One registry = one answer to "what does this region enforce?"                                              |
| **Tenant's region**   | `organizations.region_code`                | Written once at creation; afterwards only by an applied region change                                      |
| **DPA acceptance**    | `organizations.dpa_accepted_at_ms`         | A timestamp, not a boolean: a reviewer asks _when_, and "yes" cannot be reconciled with a contract version |
| **Change requests**   | `region_moves`                             | Attributable, reviewable, and applies at most once                                                         |

### Shipped regions

| Code             | Location                      | Jurisdiction                        | Status    | DPA required | Cross-border export | Webhook egress | Exports pseudonymised |
| ---------------- | ----------------------------- | ----------------------------------- | --------- | :----------: | :-----------------: | :------------: | :-------------------: |
| `us-east-1`      | AWS us-east-1, N. Virginia    | United States (state statutes vary) | active    |      no      |       allowed       |    allowed     |          no           |
| `eu-west-1`      | AWS eu-west-1, Ireland        | EU/EEA — GDPR                       | active    |   **yes**    |     **refused**     |  **refused**   |        **yes**        |
| `ap-southeast-1` | AWS ap-southeast-1, Singapore | Singapore — PDPA 2012               | active    |   **yes**    |     **refused**     |    allowed     |        **yes**        |
| `ap-southeast-2` | AWS ap-southeast-2, Sydney    | Australia — Privacy Act 1988 (Cth)  | **pilot** |     yes      |       refused       |    refused     |          no           |

`us-east-1` is the default. **The default is the permissive region on purpose**: a
kit whose `createOrg()` demanded a DPA signature for every buyer on the first call
would teach them to pass a flag they do not understand. Set `REGION_DEFAULT` to
your primary region and the strict one becomes the default — that is a deploy-time
decision, not a code change.

`ap-southeast-2` ships as `pilot` to make one behaviour visible: **a region that is
not accepting new tenants still serves the tenants already in it, and refuses both
new organizations and in-flight moves into it.**

---

## 2. What the policy actually enforces

Every field in `ResidencyPolicy` is consumed somewhere. A field that is not
enforced anywhere is a marketing claim, and this kit does not ship those.

| Control                                                                              | Enforced by                                                                        | Refusal code                                     | HTTP    |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------------------------ | ------- |
| No tenant may be created in a `pilot`/`retired` region                               | `regions.resolveNewOrgRegion` ← `services/orgs.ts:createOrg`                       | `region_not_accepting`                           | 400     |
| No tenant may be created in a region whose DPA it has not accepted                   | same                                                                               | `dpa_required`                                   | 400     |
| An unknown region is never silently defaulted                                        | `regions.requireRegion`                                                            | `unknown_region`                                 | 400     |
| A tenant cannot be committed to a move into a region requiring a DPA nobody accepted | `services/residency.ts:requestRegionChange`                                        | `dpa_required`                                   | 400     |
| Tenant events cannot be exported to another region unless the **origin** allows it   | `services/residency.ts:exportOrgAudit`                                             | `cross_border_blocked`                           | **403** |
| A tenant cannot stream events off-platform where the region forbids it               | `services/residency.ts:assertWebhookEgress` ← `services/webhooks.ts:createWebhook` | `egress_blocked`                                 | **403** |
| Identifiers leave pseudonymised where the region requires it                         | `exportOrgAudit` + `regions.pseudonymizeActorId`                                   | — (transform)                                    | —       |
| The region changes only through a recorded, reviewed request                         | `requestRegionChange` / `completeRegionChange`                                     | `same_region`, `move_pending`, `no_pending_move` | 400     |
| A misconfigured `REGION_DEFAULT` is loud, not silent                                 | `regions.defaultRegionCode`                                                        | `bad_default_region`                             | **500** |

Two of those deserve a note.

**The export gate reads the origin's policy, not the destination's.** A tenant in
`eu-west-1` cannot escape its own policy by addressing an export to `us-east-1`.
Addressing an export to the tenant's _own_ region is always allowed — nothing
crossed a border.

**`bad_default_region` is not registered in `http.ts`.** Every other code is
mapped so the browser gets a meaningful status. This one is absent on purpose: it
is an operator misconfiguration, the user cannot fix it, and echoing it as a 400
would tell them to try again. It surfaces as a logged 500 instead. There is a test
that pins exactly that.

---

## 3. Pseudonymised exports

Where `pseudonymizeActorIds` is set, the export replaces `actorUserId` with
`psn_` + 32 hex characters of `sha256("residency:<region>:<userId>")`.

- **Stable**, so an auditor comparing two exports of the same tenant can still
  follow one actor across them. A random or per-export salt would destroy the
  audit trail it was meant to protect.
- **Region-scoped**, so the same person does not pseudonymise to the same value in
  two regions, and an outsider holding both files cannot join them.
- **Marked** with the `psn_` prefix, so nobody downstream mistakes a
  pseudonymised file for a real identifier list. The response also carries
  `x-residency-pseudonymized: true|false`.

Pseudonymisation is applied _after_ the rows are read and _before_ the single CSV
writer runs, so the audit log's formula-injection guard and RFC 4180 escaping
still apply. There is one CSV writer in this kit (`db/audit.ts`), not two.

---

## 4. Changing a tenant's region

**This kit does not move data.** Copying a tenant's rows across a jurisdiction is
an operator-run migration, and a starter kit that flipped a column and called it a
residency change would be worse than one that says so out loud.

What the kit does is make the decision attributable and impossible to fake:

1. **Request** — an owner (`org.region.move`) records `from`, `to`, a reason, and
   — where the destination demands it — the DPA acceptance. Refused if a request
   is already open, if the target is not `active`, or if the destination's DPA has
   not been accepted. **Nothing moves.**
2. **Apply** — after the operator has copied the rows out of band, the owner
   completes the request. That single call flips `organizations.region_code`,
   closes the request, and writes `org.region.change_completed` with the from/to
   pair and the account that applied it — in one transaction.
3. **Or cancel** — the request is closed and the tenant stays where it was.

Re-validated at apply time, not only at request time: a region can be retired
while a request is open, and applying the move would strand the tenant in the one
place it must not be.

The UI is [`/app/org/[id]/region`](../src/routes/app/org/%5Bid%5D/region/+page.svelte);
every role can read it (`org.region.view` — where a member's data is processed is
a fact about _their_ data, not an admin detail), only an owner can act on it.

---

## 5. The report

`residencyReport()` — rendered on the same page — returns row counts per data
class plus the retention posture:

- `oldestAuditEventAtMs`, and `auditRetentionDeadlineMs` = oldest + the region's
  `auditRetentionDays`;
- `auditRetentionExceeded` when the tenant holds an event past that commitment;
- `invitesAwaitingPruning` — unaccepted, unrevoked invites older than
  `inviteRetentionDays` (invites carry an email address, so they are the
  shortest-lived personal data in the schema);
- `dsarErasureSlaDays` — the deadline a data-subject request runs against.

Both retention figures are **reported, not enforced**. The audit log is
append-only by construction — there is no UPDATE or DELETE path anywhere — and a
kit that quietly deleted a compliance trail on a timer would be trading the feature
it sells for the one it measures. Your pruning job reads these numbers.

---

## 6. Configuration

| Variable         | Default     | Effect                                                                                                                                           |
| ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `REGION_DEFAULT` | `us-east-1` | Region a new organization lands in when the caller names none. Validated against the catalogue; an unknown value throws rather than falling back |

Nothing else is configurable at runtime, by design: the region catalogue is code,
so adding a jurisdiction is a reviewed deploy and not an `INSERT`.

---

## 7. Adding a region

1. Add the code to `REGION_CODES` and an entry to `CATALOGUE` in
   `src/lib/server/regions.ts`.
2. `tests/residency.test.ts` fails if the two disagree, if a policy window is not a
   positive integer, or if the catalogue is not frozen.
3. If the new region introduces a policy field that nothing consumes, either wire
   it to an enforcement point or leave it out. See §2.
4. Provision it for real: a row in the catalogue is a claim about where data is
   processed. Point `keyAlias` at your own regional key, and do not deploy a
   region you have not stood up.

---

## 8. What this does **not** do

Said plainly, because the failure mode of a residency feature is a buyer believing
more than the code delivers:

- **It does not move or copy data**, and it does not verify that a migration
  happened. §4.
- **It is not per-table routing.** There is one database; the region is a recorded
  fact about the tenant, and physical placement is the operator's job (separate
  database per region, `DATA_DIR`/`DATABASE_URL` per deployment).
- **It does not encrypt per region.** `keyAlias` names the seam; no KMS is called.
- **It does not redact metadata inside audit rows.** `metadata_json` can carry
  tenant-supplied values; if your policy needs those redacted, that is a
  per-field decision at the write site, not something this module can infer.
- **It is not a legal opinion.** §0.
