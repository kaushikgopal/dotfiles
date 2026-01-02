# Prior to version 4.3, fish shipped an event handler that runs
# `set --universal fish_key_bindings fish_default_key_bindings`
# whenever the fish_key_bindings variable is erased.
# This means that as long as any fish < 4.3 is still running on this system,
# we cannot complete the migration.
# As a workaround, erase the universal variable at every shell startup.
set --erase --universal fish_key_bindings
