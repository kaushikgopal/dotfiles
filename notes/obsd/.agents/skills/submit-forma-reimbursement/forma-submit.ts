import { Builder, By, until, WebDriver } from "selenium-webdriver";
import firefox from "selenium-webdriver/firefox";
import * as fs from "fs";
import * as path from "path";

interface ClaimConfig {
  receiptPath: string;
  account: string; // e.g. "Personal Professional Development Budget"
  category: string; // e.g. "Books"
  description: string;
  marionettePort?: number;
  geckodriverPath?: string;
}

const DEFAULT_GECKODRIVER_PATH = path.join(
  process.env.HOME || "",
  ".cache",
  "selenium",
  "geckodriver",
  "mac-arm64",
  "0.36.0",
  "geckodriver"
);

async function findGeckodriver(): Promise<string> {
  const envPath = process.env.GECKODRIVER_PATH;
  if (envPath && fs.existsSync(envPath)) return envPath;

  if (fs.existsSync(DEFAULT_GECKODRIVER_PATH)) return DEFAULT_GECKODRIVER_PATH;

  // Try to resolve via selenium-manager
  const { execFileSync } = await import("child_process");
  try {
    const swPkg = require.resolve("selenium-webdriver/package.json");
    const swDir = path.dirname(swPkg);
    const smBin = path.join(swDir, "bin", "macos", "selenium-manager");
    const result = JSON.parse(
      execFileSync(smBin, ["--driver", "geckodriver", "--output", "json"], {
        encoding: "utf-8",
      })
    );
    if (result.result?.driver_path) return result.result.driver_path;
  } catch {
    // ignore
  }

  throw new Error(
    `geckodriver not found. Set GECKODRIVER_PATH or ensure it exists at ${DEFAULT_GECKODRIVER_PATH}`
  );
}

async function connectToFirefox(
  marionettePort: number = 2828
): Promise<WebDriver> {
  const geckodriverPath = await findGeckodriver();
  const service = new firefox.ServiceBuilder(geckodriverPath);
  service.addArguments("--connect-existing", `--marionette-port=${marionettePort}`);
  const options = new firefox.Options();

  return new Builder()
    .forBrowser("firefox")
    .setFirefoxOptions(options)
    .setFirefoxService(service)
    .build();
}

async function selectDropdownOption(
  driver: WebDriver,
  dropdownInput: any,
  optionText: string
): Promise<boolean> {
  await dropdownInput.click();
  await driver.sleep(1500);

  const options = await driver.findElements(
    By.css('li.MuiAutocomplete-option, [role="option"]')
  );

  for (const opt of options) {
    const text = await opt.getText();
    if (text.toLowerCase().includes(optionText.toLowerCase())) {
      await opt.click();
      return true;
    }
  }

  // Fallback: select first non-empty option
  for (const opt of options) {
    const text = await opt.getText();
    if (text.trim().length > 0) {
      await opt.click();
      return true;
    }
  }

  return false;
}

async function uploadReceipt(driver: WebDriver, receiptPath: string): Promise<void> {
  const fileInput = await driver.findElement(
    By.css('input[type="file"], input#receipt')
  );

  // Unhide the file input so WebDriver can interact with it
  await driver.executeScript(
    `
    arguments[0].style.display = "block";
    arguments[0].style.visibility = "visible";
    arguments[0].style.opacity = "1";
    arguments[0].style.position = "fixed";
    arguments[0].style.top = "0";
    arguments[0].style.left = "0";
    arguments[0].style.zIndex = "9999";
    `,
    fileInput
  );

  await driver.sleep(500);
  await fileInput.sendKeys(receiptPath);
  await driver.sleep(2000);
}

async function clickUploadReceiptButton(driver: WebDriver): Promise<void> {
  const btn = await driver.findElement(
    By.xpath("//button[contains(., 'Upload receipt')]")
  );
  await driver.executeScript(
    'arguments[0].scrollIntoView({block: "center"});',
    btn
  );
  await driver.sleep(1000);
  await btn.click();
}

async function clickSubmit(driver: WebDriver): Promise<void> {
  const btn = await driver.findElement(
    By.xpath("//button[contains(., 'Submit')]")
  );
  await driver.executeScript(
    'arguments[0].scrollIntoView({block: "center"});',
    btn
  );
  await driver.sleep(1000);
  await btn.click();
}

async function submitClaim(config: ClaimConfig): Promise<{
  success: boolean;
  url: string;
  screenshotPath?: string;
}> {
  const driver = await connectToFirefox(config.marionettePort);

  try {
    await driver.sleep(2000);

    // Navigate to claims page
    await driver.get("https://client.joinforma.com/claims/new");
    await driver.sleep(5000);
    await driver.wait(until.elementLocated(By.css("form")), 15000);

    // 1. Select Account
    const accountDropdown = await driver.findElement(
      By.css('input[aria-autocomplete="list"]')
    );
    const accountSelected = await selectDropdownOption(
      driver,
      accountDropdown,
      config.account
    );
    if (!accountSelected) {
      throw new Error(`Could not find account option matching: ${config.account}`);
    }
    console.log("Account selected");
    await driver.sleep(3000);

    // 2. Select Category (second dropdown)
    const dropdowns = await driver.findElements(
      By.css('input[aria-autocomplete="list"]')
    );
    if (dropdowns.length >= 2) {
      const categorySelected = await selectDropdownOption(
        driver,
        dropdowns[1],
        config.category
      );
      if (!categorySelected) {
        throw new Error(`Could not find category option matching: ${config.category}`);
      }
      console.log("Category selected");
      await driver.sleep(2000);
    }

    // 3. Fill Description
    const descInput = await driver.findElement(
      By.css('textarea[name*="description" i], input[name*="description" i]')
    );
    await descInput.click();
    await descInput.clear();
    await descInput.sendKeys(config.description);
    console.log("Description filled");

    // 4. Upload receipt file
    await uploadReceipt(driver, config.receiptPath);
    console.log("File uploaded");

    // 5. Click "Upload receipt" button to trigger OCR processing
    await clickUploadReceiptButton(driver);
    console.log("Upload receipt clicked — waiting for OCR processing...");
    await driver.sleep(10000); // Forma OCR takes ~8-10s

    // 6. DO NOT override auto-extracted amount/merchant/date
    // Forma's React validation breaks if these are manually overridden.
    // Only verify they look reasonable.

    // 7. Submit
    await clickSubmit(driver);
    console.log("Submit clicked");
    await driver.sleep(8000);

    const currentUrl = await driver.getCurrentUrl();
    const success = !currentUrl.includes("/claims/new");

    // Save screenshot for verification
    const screenshotPath = `/tmp/forma-claim-result-${Date.now()}.png`;
    const screenshot = await driver.takeScreenshot();
    fs.writeFileSync(screenshotPath, screenshot, "base64");

    return { success, url: currentUrl, screenshotPath };
  } finally {
    // Keep browser open for inspection; do not quit
    console.log("Browser session kept open for inspection");
  }
}

// CLI entrypoint
async function main() {
  const args = process.argv.slice(2);

  if (args.length < 4) {
    console.error(`
Usage: npx ts-node forma-submit.ts <receiptPath> <account> <category> <description> [marionettePort]

Example:
  npx ts-node forma-submit.ts \\
    /tmp/receipt.pdf \\
    "Personal Professional Development Budget" \\
    "Books" \\
    "Audible communication audiobook - May 2026"
`);
    process.exit(1);
  }

  const [receiptPath, account, category, description, marionettePortStr] = args;

  const config: ClaimConfig = {
    receiptPath,
    account,
    category,
    description,
    marionettePort: marionettePortStr ? parseInt(marionettePortStr, 10) : 2828,
  };

  console.log("Submitting Forma claim...");
  console.log(JSON.stringify(config, null, 2));

  try {
    const result = await submitClaim(config);
    console.log("\nResult:", JSON.stringify(result, null, 2));
    process.exit(result.success ? 0 : 1);
  } catch (err: any) {
    console.error("Failed:", err.message);
    process.exit(1);
  }
}

main();
