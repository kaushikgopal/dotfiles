---
name: submit-forma-reimbursement
description: Use for submitting Forma reimbursement claims from receipt files.
allowed-tools: Read, Bash, AskUserQuestion
compatibility: macOS. Supports two browser backends:
  (a) Brave Browser + agent-browser CLI with saved auth at ~/.local/state/agent-browser/states/joinforma.json
  (b) Firefox with --marionette and selenium-webdriver with auth persisted in ~/.firefox-automation profile
---

## submit-forma-reimbursement

Automate submitting one or more expense reimbursement claims to Forma.
Receipt-first: read all receipts, infer all fields, confirm with user in one
pass, then drive the browser — opening /claims/new once per claim in a single
session.

---

## Phase 1 — Receipt Intake & Analysis

**Step 1.1 — Get receipts**

If the user did not provide any receipt file paths when invoking the skill, ask:

> "Path(s) to receipt file(s)? (PDF or image; separate multiple paths with spaces or newlines)"

Accept one or more paths. Process each receipt independently in steps 1.2–1.4,
then present a combined confirmation block in step 1.5.

**Step 1.2 — Read each receipt**

For each receipt file, use the Read tool. Claude natively handles PDFs and
images (PNG, JPG, HEIC).

Extract these fields per receipt:

| Field | What to look for |
|-------|-----------------|
| Vendor name | Company/service provider (e.g., "AT&T", "Xfinity", "Udemy") |
| Full billed amount | Total due or subscription charge on the receipt |
| Date | Service date or billing date — use MM/DD/YYYY format |
| Service type | What kind of service (mobile plan, internet, course, book, etc.) |

**Step 1.3 — Infer reimbursement type**

Map vendor/service type → one of the three Forma reimbursement types:

| Receipt type | Forma reimbursement type |
|---|---|
| Phone carrier (T-Mobile, Rogers, Verizon, AT&T, Bell, Telus) | Cell Phone/Internet Reimbursement |
| ISP / internet service (Xfinity, Comcast, Spectrum, Rogers Internet) | Cell Phone/Internet Reimbursement |
| Online courses, e-learning (Udemy, Coursera, Pluralsight, LinkedIn Learning) | Personal Professional Development Budget |
| Vocabulary, writing, language-learning, or communication-improvement subscriptions | Personal Professional Development Budget |
| Spotify, Audible, or YouTube Premium subscriptions with a truthful note explaining connection to professional development | Personal Professional Development Budget |
| Developer tools, software subscriptions (GitHub, JetBrains, 1Password work, etc.) | Personal Professional Development Budget |
| Technical books, Amazon tech purchases | Personal Professional Development Budget |
| Conferences, workshops, training events | Personal Professional Development Budget |
| Wellness, gym, spa, dining, entertainment | Treat Yourself |
| Annual personal enrichment subscription | Treat Yourself |

If the vendor doesn't map cleanly to any type, use AskUserQuestion to present
all three options and ask the user to pick.

**Step 1.4 — Determine claim amount**

The claim amount is what will be submitted to Forma — it may differ from the
full billed amount.

**For Cell Phone/Internet Reimbursement:**

The monthly benefit is $60. Apply this logic:

1. If the full billed amount ≤ $60: claim the full billed amount.
2. If the full billed amount > $60: default claim amount is $60.
3. If the user specified a prior overage from a previous submission (e.g.,
   "last bill was submitted for $61.62 instead of $60, so I'm $1.62 over"),
   reduce the first eligible claim in this batch: claim amount = $60 − prior_overage.
   Apply this only once, to the first receipt that would otherwise claim $60.

When adjusting an amount, note the adjustment explicitly in the confirmation
block (step 1.5) so the user can see and approve it.

**For all other reimbursement types:**

Use the full billed amount as the claim amount (no cap).

**Step 1.5 — Generate description**

Format: `"<Vendor> <service description> – <Month YYYY>"`

Use the billing date's month and year.

Examples:
- `"AT&T monthly cell phone bill – March 2026"`
- `"Xfinity internet service – March 2026"`
- `"Udemy online course – February 2026"`

**Step 1.6 — Present confirmation block**

After processing all receipts, present a combined summary and wait for the
user's explicit confirmation:

```
Receipts detected:

  #1  Vendor:  <vendor>
      Date:    <date>
      Billed:  $<full billed amount>
      Claim:   $<claim amount>   [← adjusted: $60 cap / prior overage of $X applied]
      Type:    <reimbursement type>
      Desc:    "<description>"

  #2  Vendor:  <vendor>
      Date:    <date>
      Billed:  $<full billed amount>
      Claim:   $<claim amount>
      Type:    <reimbursement type>
      Desc:    "<description>"

Confirm all? (or tell me what to change — e.g. "change #2 amount to $55")
```

If the user requests corrections, apply them and proceed with corrected values.
Do not re-read the receipts.

---

## Phase 2 — Browser Automation

Choose the browser backend based on what's available:

- **Brave + agent-browser CLI** (legacy): invoke the `agent-browser-kg` skill
- **Firefox + WebDriver** (recommended): use the TypeScript script at
  `forma-submit.ts` in this skill directory, or run equivalent WebDriver code

**Note on form field availability:** Forma's claims form shows different fields
depending on the selected reimbursement type. For Cell Phone/Internet
Reimbursement, the pre-scan form shows only: Category dropdown + Description
field + Upload button. Amount and Date fields appear post-scan (after the
receipt is processed by Forma). Other reimbursement types may show more fields
pre-scan. Adapt to what the snapshot reveals — do not assume a static layout.

**CRITICAL: Do not override auto-extracted fields.** After Forma scans the
receipt, it auto-populates Amount, Merchant, and Date. Manually overwriting
these fields breaks Forma's React validation and blocks submission. Only verify
the auto-extracted values match the confirmed values; do not touch the fields
unless the extraction is clearly wrong.

---

### Backend A: Brave + agent-browser CLI

**Step 2.1 — Check for saved auth state**

Run:

```bash
ls ~/.local/state/agent-browser/states/joinforma.json
```

If the file does NOT exist, print the following first-run setup message and
stop — do NOT proceed to browser automation:

```
First-run setup required. To save your Forma auth state:

1. Open Forma in headed Brave:
   agent-browser \
     --executable-path "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
     --session-name joinforma \
     --headed \
     open https://client.joinforma.com/

2. Log in with your Work account credentials in the browser window.

3. Once logged in, save the auth state:
   agent-browser --session-name joinforma state save ~/.local/state/agent-browser/states/joinforma.json

4. Re-invoke /submit-forma-reimbursement
```

**Step 2.2 — Launch Brave headed and load auth state**

Always use headed mode (skip lightpanda and headless Brave — Forma is a React
SPA and its OCR backend appears to fingerprint headless requests, causing the
receipt scan to silently time out):

```bash
agent-browser \
  --executable-path "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  --session-name joinforma \
  --headed \
  open https://client.joinforma.com/claims/new
```

Load saved auth state explicitly (do NOT rely on auto-restore — known bug):

```bash
agent-browser --session-name joinforma state load ~/.local/state/agent-browser/states/joinforma.json
```

Reload the page so the injected cookies take effect:

```bash
agent-browser --session-name joinforma open https://client.joinforma.com/claims/new
```

Take a snapshot to verify the form is loaded:

```bash
agent-browser --session-name joinforma snapshot -i
```

Inspect the snapshot. If it shows a login/sign-in page instead of the claims
form, the saved state has expired. Print this message and stop:

```
Auth state expired. Please refresh it:

1. agent-browser \
     --executable-path "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
     --session-name joinforma \
     --headed \
     open https://client.joinforma.com/

2. Log in again.

3. agent-browser --session-name joinforma state save \
     ~/.local/state/agent-browser/states/joinforma.json

4. Re-invoke /submit-forma-reimbursement
```

---

### Backend B: Firefox + WebDriver (selenium-webdriver)

**Prerequisites:**
- Firefox running with Marionette: `firefox -no-remote -profile ~/.firefox-automation --marionette`
- `selenium-webdriver` npm package available
- geckodriver installed (auto-detected via selenium-manager or at `~/.cache/selenium/geckodriver/mac-arm64/0.36.0/geckodriver`)

**Auth setup (one-time):**
1. Launch Firefox with the automation profile
2. Navigate to https://client.joinforma.com/ and log in manually
3. Auth persists in `~/.firefox-automation` across restarts

**Running the TypeScript script:**

```bash
cd ~/notes/obsd/.agents/skills/submit-forma-reimbursement
npx ts-node forma-submit.ts \
  "/path/to/receipt.pdf" \
  "Personal Professional Development Budget" \
  "Books" \
  "Audible communication audiobook - May 2026"
```

The script (`forma-submit.ts`) handles:
- Connecting to existing Firefox via Marionette
- Selecting account and category dropdowns
- Filling description
- Uploading the receipt (unhiding hidden `input[type=file]` via JS)
- Clicking "Upload receipt" to trigger OCR
- Waiting for auto-extraction
- Submitting the claim
- Saving a result screenshot

**Manual WebDriver commands (if not using the script):**

```typescript
import { Builder, By, until } from "selenium-webdriver";
import firefox from "selenium-webdriver/firefox";

const service = new firefox.ServiceBuilder("/path/to/geckodriver");
service.addArguments("--connect-existing", "--marionette-port=2828");
const driver = await new Builder()
  .forBrowser("firefox")
  .setFirefoxService(service)
  .build();

await driver.get("https://client.joinforma.com/claims/new");

// Select dropdown by clicking input[aria-autocomplete="list"],
// then clicking the matching li.MuiAutocomplete-option

// Upload file: find input[type="file"], unhide via JS, then sendKeys(path)
await driver.executeScript(`
  arguments[0].style.display = "block";
  arguments[0].style.visibility = "visible";
  arguments[0].style.opacity = "1";
`, fileInput);
await fileInput.sendKeys("/path/to/receipt.pdf");

// Click "Upload receipt" button, wait 10s for OCR
// Click Submit
```

---

## Phase 3 — Submit Gate (per claim)

**Step 3.1 — Present final summary**

Before clicking submit, pause and present this summary for the current claim:

```
Ready to submit claim #N of M:
  Reimbursement type: <type>
  Category:           <subcategory>
  Description:        "<description>"
  Amount:             $<claim amount>
  Date:               <date>
  Receipt:            <filename> ✓ uploaded

Submit claim? [yes / no / cancel]
```

Wait for explicit "yes" confirmation. On "no" or "cancel", close the browser
session and stop without submitting. Remaining receipts are abandoned.

**Step 3.2 — Submit**

On confirmation, scroll the Submit button into the visible viewport before
clicking — Forma's React click handler requires the button to be on-screen:

**Brave backend:**
```bash
agent-browser --session-name joinforma scroll down 300
agent-browser --session-name joinforma click @eN   # N = Submit button ref
```

**Firefox/WebDriver backend:**
```typescript
const btn = await driver.findElement(By.xpath("//button[contains(., 'Submit')]"));
await driver.executeScript('arguments[0].scrollIntoView({block: "center"});', btn);
await driver.sleep(1000);
await btn.click();
```

Take a **screenshot** (not snapshot) to verify the outcome — the success toast
is transient and disappears before `snapshot -i` can capture it:

**Brave backend:**
```bash
sleep 3 && agent-browser --session-name joinforma screenshot
```

**Firefox/WebDriver backend:**
```typescript
await driver.sleep(3000);
const screenshot = await driver.takeScreenshot();
```

Look for a success indicator: a "Claim submitted successfully." toast, a
"Great, your claim was submitted!" heading, or a redirect to `/claims`.
Report the outcome:

- **Success:** "Claim #N submitted. Forma confirmation: <any reference or message from the page>"
- **Failure:** "Submission failed for claim #N. Error: <error message from snapshot>. The form was NOT submitted — please retry manually at https://client.joinforma.com/claims/new"

On failure, stop. Do not attempt remaining receipts.

**Step 3.3 — Continue or close**

If there are more receipts, loop back to Step 2.3a (or re-run the TypeScript
script with the next receipt).

Once all receipts are submitted, close the browser session:

**Brave backend:**
```bash
agent-browser --session-name joinforma close
```

**Firefox/WebDriver backend:**
```typescript
await driver.quit();
```

Report a final summary:

```
All claims submitted:
  #1  <vendor> – <Month YYYY> → $<amount> ✓
  #2  <vendor> – <Month YYYY> → $<amount> ✓
  ...
```

---

## Error Handling Reference

| Scenario | Action |
|---|---|
| `joinforma.json` not found (Brave) | Print first-run setup instructions (Step 2.1). Stop. Do not open browser. |
| Firefox auth expired (login page shown) | User must re-log in via Firefox automation profile. |
| Snapshot shows login page after state load | Print state-expired instructions (Step 2.2). Close session. Stop. |
| Subcategory dropdown empty or unrecognised layout | Snapshot and describe what you see. Ask user to identify the right element before continuing. |
| Upload fails or processing modal does not clear | Snapshot and report. Ask user whether to retry manually in a browser window; continue once they confirm the receipt is attached. |
| Post-scan Amount or Date field not found | Snapshot and report what is visible. Do not proceed to submit without confirming both fields are set. |
| Amount not extractable from receipt | Ask user to provide the amount explicitly before Phase 2. |
| Date not extractable from receipt | Ask user to provide the date explicitly before Phase 2. |
| Vendor doesn't map to a reimbursement type | Use AskUserQuestion to present all three types. Let user pick. |
| Submission fails with page error | Snapshot and report the error message verbatim. Do NOT retry automatically. Stop. Abandon remaining receipts. |
| Auto-extracted values look wrong | Only override if clearly wrong. Overwriting breaks Forma validation. |
