export const SoundHooks = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "tui.toast.show") {
        await $`afplay $XDG_STATE_HOME/sound-notification-human`.quiet();
      }

      if (event.type === "session.idle") {
        await $`afplay $XDG_STATE_HOME/sound-done-human`.quiet();
      }
    },
  };
};
