export const SoundHooks = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "tui.toast.show") {
        await $`afplay $XDG_DATA_HOME/sound-notification-orc`.quiet();
      }

      if (event.type === "session.idle") {
        await $`afplay $XDG_DATA_HOME/sound-done-orc`.quiet();
      }
    },
  };
};
