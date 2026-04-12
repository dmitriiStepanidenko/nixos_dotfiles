export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`echo "opencode (server): Response ready" | notify -silent`;
      }
      if (event.type === "permission.asked") {
        await $`echo "opencode (server): Input needed" | notify -silent`;
      }
      if (event.type === "permission.asked") {
        await $`echo "opencode: Input needed" | notify -silent`;
      }
    },
  };
};
