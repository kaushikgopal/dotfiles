import { Clipboard, environment, LaunchType, Toast, updateCommandMetadata } from "@raycast/api";

const command = async () => {
  const now = new Date();

  const cal = now.toLocaleString(undefined, { timeZone: "America/Los_Angeles", timeStyle: "short" });
  const nyc = now.toLocaleString(undefined, { timeZone: "America/New_York", timeStyle: "short" });
  const india = now.toLocaleString(undefined, { timeZone: "Asia/Kolkata", timeStyle: "short" });
  const china = now.toLocaleString(undefined, { timeZone: "Asia/Shanghai", timeStyle: "short" });
  
  const subtitle = `🇺🇸 ${cal}        🇨🇦🗽 ${nyc}       🇮🇳 ${india}         🇨🇳 ${china}`;
  await updateCommandMetadata({ subtitle });

  if (environment.launchType === LaunchType.UserInitiated) {
    const toast = new Toast({
      style: Toast.Style.Success,
      title: "Refreshed!",
      message: subtitle,
    });
    toast.primaryAction = {
      title: "Copy to Clipboard",
      shortcut: { modifiers: ["cmd", "shift"], key: "c" },
      onAction: () => Clipboard.copy(subtitle),
    };
    await toast.show();
  }
};

export default command;
