---
kind: workflow
status: active
tags:
  - firefox
  - webdriver
  - forma
  - react-spa
  - file-upload
---

# Firefox WebDriver for React SPA Form Automation

## Context
When automating Forma (a React SPA) via Firefox, the Firefox DevTools MCP
server lacks two critical capabilities:
1. `upload_file_by_uid` requires a visible `<input type=file>` element, but
   Forma hides its file input via CSS.
2. `take_snapshot` crashes with `str.substring is not a function` when React
   dropdowns (MUI Autocomplete) are open.

The workaround is to drop to `selenium-webdriver` connected to the existing
Firefox Marionette instance.

## Learning

### Connecting to Existing Firefox
```typescript
import { Builder } from "selenium-webdriver";
import firefox from "selenium-webdriver/firefox";

const service = new firefox.ServiceBuilder("/path/to/geckodriver");
service.addArguments("--connect-existing", "--marionette-port=2828");
const driver = await new Builder()
  .forBrowser("firefox")
  .setFirefoxService(service)
  .build();
```

### Uploading to Hidden File Inputs
MCP and some WebDriver tools cannot interact with `display: none` file inputs.
Unhide via JS before sending keys:

```typescript
const fileInput = await driver.findElement(By.css('input[type="file"]'));
await driver.executeScript(`
  arguments[0].style.display = "block";
  arguments[0].style.visibility = "visible";
  arguments[0].style.opacity = "1";
  arguments[0].style.position = "fixed";
  arguments[0].style.top = "0";
  arguments[0].style.left = "0";
  arguments[0].style.zIndex = "9999";
`, fileInput);
await fileInput.sendKeys("/path/to/file.pdf");
```

### React Dropdowns (MUI Autocomplete)
MCP snapshots crash on open MUI dropdowns. Use WebDriver directly:

```typescript
await driver.findElement(By.css('input[aria-autocomplete="list"]')).click();
await driver.sleep(1500);
const options = await driver.findElements(
  By.css('li.MuiAutocomplete-option, [role="option"]')
);
for (const opt of options) {
  const text = await opt.getText();
  if (text.includes("Target Option")) {
    await opt.click();
    break;
  }
}
```

### Forma-Specific: Do Not Override Auto-Extracted Fields
After uploading a receipt and clicking "Upload receipt", Forma OCR
auto-populates Amount, Merchant, and Date. Manually overwriting these fields
breaks Forma's React validation (`invalid="true"`) and blocks submission.
Only verify the values; do not touch the fields unless the extraction is
clearly wrong.

## When It Applies
- Any React SPA with hidden `<input type=file>` elements
- Any MUI/Material-UI autocomplete dropdown automation
- Forma reimbursement claim submission specifically

## Evidence
- Session: 2026-05-26 Firefox MCP vs agent-browser-kg testing
- Successful claim submission via WebDriver after 4 failed MCP attempts
- Skill file: `.agents/skills/submit-forma-reimbursement/forma-submit.ts`

## Related
- [[submit-forma-reimbursement]] skill
- `.agents/skills/submit-forma-reimbursement/forma-submit.ts`
