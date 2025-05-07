import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open, rectangle, shell } from "./utils";

// Only the rules array is defined at the top level
const rules: KarabinerRules[] = [
  // --- Right Cmd (alone) -> Enter ---
  {
    description: "Right Cmd (alone) -> Enter",
    manipulators: [
      {
        from: {
          key_code: "right_command",
          modifiers: { optional: ["any"] },
        },
        to: [
          { key_code: "right_control" },
        ],
        to_if_alone: [
          { key_code: "return_or_enter" },
        ],
        conditions: [
          {
            type: "device_if",
            identifiers: [
              { vendor_id: 1452 },
              { vendor_id: 76 },
              { is_built_in_keyboard: true },
            ],
          },
        ],
        type: "basic",
      },
    ],
  },
  // --- Caps Lock -> Escape (alone) | Ctrl (simple) + Vim/Arrow/Mouse ---
  {
    description: "Caps Lock -> Escape (alone) | Ctrl (simple)",
    manipulators: [
      // Caps Lock alone -> Escape, held -> right_control
      {
        from: {
          key_code: "caps_lock",
          modifiers: { optional: ["any"] },
        },
        to: [ { key_code: "right_control" } ],
        to_if_alone: [ { key_code: "escape" } ],
        type: "basic",
      },
      // Vim-like arrow keys with Control
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { key_code: "left_arrow" } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { key_code: "down_arrow" } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { key_code: "up_arrow" } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { key_code: "right_arrow" } ],
        type: "basic",
      },

      // Command + Vim keys to Command + Arrow
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["left_command", "right_control"] },
        },
        to: [ { key_code: "left_arrow", modifiers: ["left_command"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_command", "right_control"] },
        },
        to: [ { key_code: "down_arrow", modifiers: ["left_command"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["left_command", "right_control"] },
        },
        to: [ { key_code: "up_arrow", modifiers: ["left_command"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["left_command", "right_control"] },
        },
        to: [ { key_code: "right_arrow", modifiers: ["left_command"] } ],
        type: "basic",
      },

      // Shift + Vim keys to Shift + Arrow
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["left_shift", "right_control"] },
        },
        to: [ { key_code: "left_arrow", modifiers: ["left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["left_shift", "right_control"] },
        },
        to: [ { key_code: "right_arrow", modifiers: ["left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["left_shift", "right_control"] },
        },
        to: [ { key_code: "up_arrow", modifiers: ["left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_shift", "right_control"] },
        },
        to: [ { key_code: "down_arrow", modifiers: ["left_shift"] } ],
        conditions: [
          {
            type: "frontmost_application_unless",
            bundle_identifiers: ["com.google.android.studio", "^com\\.jetbrains\\..*$"]
          }
        ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_shift", "right_control"] },
        },
        to: [ { key_code: "j", modifiers: ["left_control", "left_shift"] } ],
        conditions: [
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["com.google.android.studio", "^com\\.jetbrains\\..*$"]
          }
        ],
        type: "basic",
      },

      // Option + Vim keys to Option + Arrow
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["left_option", "right_control"] },
        },
        to: [ { key_code: "left_arrow", modifiers: ["left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_option", "right_control"] },
        },
        to: [ { key_code: "down_arrow", modifiers: ["left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["left_option", "right_control"] },
        },
        to: [ { key_code: "up_arrow", modifiers: ["left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["left_option", "right_control"] },
        },
        to: [ { key_code: "right_arrow", modifiers: ["left_option"] } ],
        type: "basic",
      },

      // Command + Option + Vim keys to Command + Option + Arrow
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["left_command", "left_option", "right_control"] },
        },
        to: [ { key_code: "left_arrow", modifiers: ["left_command", "left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_command", "left_option", "right_control"] },
        },
        to: [ { key_code: "down_arrow", modifiers: ["left_command", "left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["left_command", "left_option", "right_control"] },
        },
        to: [ { key_code: "up_arrow", modifiers: ["left_command", "left_option"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["left_command", "left_option", "right_control"] },
        },
        to: [ { key_code: "right_arrow", modifiers: ["left_command", "left_option"] } ],
        type: "basic",
      },

      // Command + Shift + Vim keys to Command + Shift + Arrow
      {
        from: {
          key_code: "h",
          modifiers: { mandatory: ["left_command", "left_shift", "right_control"] },
        },
        to: [ { key_code: "left_arrow", modifiers: ["left_command", "left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: { mandatory: ["left_command", "left_shift", "right_control"] },
        },
        to: [ { key_code: "down_arrow", modifiers: ["left_command", "left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: { mandatory: ["left_command", "left_shift", "right_control"] },
        },
        to: [ { key_code: "up_arrow", modifiers: ["left_command", "left_shift"] } ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: { mandatory: ["left_command", "left_shift", "right_control"] },
        },
        to: [ { key_code: "right_arrow", modifiers: ["left_command", "left_shift"] } ],
        type: "basic",
      },

      // Mouse control with arrow keys
      {
        from: {
          key_code: "down_arrow",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { mouse_key: { y: 1536 } } ],
        type: "basic",
      },
      {
        from: {
          key_code: "up_arrow",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { mouse_key: { y: -1536 } } ],
        type: "basic",
      },
      {
        from: {
          key_code: "left_arrow",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { mouse_key: { x: -1536 } } ],
        type: "basic",
      },
      {
        from: {
          key_code: "right_arrow",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { mouse_key: { x: 1536 } } ],
        type: "basic",
      },

      // Mouse clicks
      {
        from: {
          key_code: "return_or_enter",
          modifiers: { mandatory: ["right_control"] },
        },
        to: [ { pointing_button: "button1" } ],
        type: "basic",
      },
      {
        from: {
          key_code: "return_or_enter",
          modifiers: { mandatory: ["left_command", "right_control"] },
        },
        to: [ { pointing_button: "button2" } ],
        type: "basic",
      },
    ],
  },
  // --- Special characters enabled with shift + numkey ---
  {
    description: "special characters enabled with shift + numkey",
    manipulators: [
      // F + I -> * (shift + 8)
      {
        from: { key_code: "i" },
        to: [{ key_code: "8", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "8", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "i" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + U -> & (shift + 7)
      {
        from: { key_code: "u" },
        to: [{ key_code: "7", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "7", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "u" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Y -> ^ (shift + 6)
      {
        from: { key_code: "y" },
        to: [{ key_code: "6", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "6", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "y" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // J + T -> % (shift + 5)
      {
        from: { key_code: "t" },
        to: [{ key_code: "5", modifiers: ["left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "5", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "t" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // J + R -> $ (shift + 4)
      {
        from: { key_code: "r" },
        to: [{ key_code: "4", modifiers: ["left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "4", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "r" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // J + E -> # (shift + 3)
      {
        from: { key_code: "e" },
        to: [{ key_code: "3", modifiers: ["left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "3", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "e" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // J + W -> @ (shift + 2)
      {
        from: { key_code: "w" },
        to: [{ key_code: "2", modifiers: ["left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "2", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "w" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // J + Q -> ! (shift + 1)
      {
        from: { key_code: "q" },
        to: [{ key_code: "1", modifiers: ["left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "1", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "q" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // F + L -> - (hyphen)
      {
        from: { key_code: "l" },
        to: [{ key_code: "hyphen" }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "hyphen" }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "l" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Semicolon -> + (shift + equals)
      {
        from: { key_code: "semicolon" },
        to: [{ key_code: "equal_sign", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "equal_sign", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "semicolon" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Quote -> = (equals)
      {
        from: { key_code: "quote" },
        to: [{ key_code: "equal_sign" }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "equal_sign" }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "quote" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },
    ],
  },
  // --- Bracket combinations ---
  {
    description: "bracket combos",
    manipulators: [
      // F + J -> ( (shift + 9)
      {
        from: { key_code: "j" },
        to: [{ key_code: "9", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "9", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "j" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + K -> ) (shift + 0)
      {
        from: { key_code: "k" },
        to: [{ key_code: "0", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "0", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "k" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + M -> [ (open_bracket)
      {
        from: { key_code: "m" },
        to: [{ key_code: "open_bracket" }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "open_bracket" }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "m" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Comma -> ] (close_bracket)
      {
        from: { key_code: "comma" },
        to: [{ key_code: "close_bracket" }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "close_bracket" }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "comma" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Period -> { (shift + open_bracket)
      {
        from: { key_code: "period" },
        to: [{ key_code: "open_bracket", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "open_bracket", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "period" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },

      // F + Slash -> } (shift + close_bracket)
      {
        from: { key_code: "slash" },
        to: [{ key_code: "close_bracket", modifiers: ["left_shift"] }],
        conditions: [{ name: "f-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "f-mode", value: 1 } },
          { key_code: "close_bracket", modifiers: ["left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "f" },
            { key_code: "slash" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "f-mode", value: 0 } }
            ]
          }
        }
      },
    ],
  },
  // --- Delete sequences ---
  {
    description: "delete sequences",
    manipulators: [
      // J + S -> Control + U (clear line) in Terminal
      {
        from: { key_code: "s" },
        to: [{ key_code: "u", modifiers: ["left_control"] }],
        conditions: [
          { name: "j-mode", value: 1, type: "variable_if" },
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "u", modifiers: ["left_control"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "s" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        },
        conditions: [
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ]
      },

      // J + S -> Command + Backspace (delete to start of line) in other apps
      {
        from: { key_code: "s" },
        to: [{ key_code: "delete_or_backspace", modifiers: ["left_command"] }],
        conditions: [
          { name: "j-mode", value: 1, type: "variable_if" },
          {
            type: "frontmost_application_unless",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "delete_or_backspace", modifiers: ["left_command"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "s" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        },
        conditions: [
          {
            type: "frontmost_application_unless",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ]
      },

      // J + D -> Control + W (delete word) in Terminal
      {
        from: { key_code: "d" },
        to: [{ key_code: "w", modifiers: ["left_control"] }],
        conditions: [
          { name: "j-mode", value: 1, type: "variable_if" },
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "w", modifiers: ["left_control"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "d" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        },
        conditions: [
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ]
      },

      // J + D -> Option + Backspace (delete word) in other apps
      {
        from: { key_code: "d" },
        to: [{ key_code: "delete_or_backspace", modifiers: ["left_option"] }],
        conditions: [
          { name: "j-mode", value: 1, type: "variable_if" },
          {
            type: "frontmost_application_unless",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "delete_or_backspace", modifiers: ["left_option"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "d" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        },
        conditions: [
          {
            type: "frontmost_application_unless",
            bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
          }
        ]
      },

      // J + F -> Backspace (delete character)
      {
        from: { key_code: "f" },
        to: [{ key_code: "delete_or_backspace" }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "delete_or_backspace" }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "f" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },
    ],
  },
  // --- Command next/prev tab ---
  {
    description: "cmd next/prev tab",
    manipulators: [
      // J + X -> Command + Shift + [ (previous tab)
      {
        from: { key_code: "x" },
        to: [{ key_code: "open_bracket", modifiers: ["left_command", "left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "open_bracket", modifiers: ["left_command", "left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "x" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },

      // J + C -> Command + Shift + ] (next tab)
      {
        from: { key_code: "c" },
        to: [{ key_code: "close_bracket", modifiers: ["left_command", "left_shift"] }],
        conditions: [{ name: "j-mode", value: 1, type: "variable_if" }],
        type: "basic",
      },
      {
        type: "basic",
        parameters: { "basic.simultaneous_threshold_milliseconds": 250 },
        to: [
          { set_variable: { name: "j-mode", value: 1 } },
          { key_code: "close_bracket", modifiers: ["left_command", "left_shift"] }
        ],
        from: {
          simultaneous: [
            { key_code: "j" },
            { key_code: "c" }
          ],
          simultaneous_options: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              { set_variable: { name: "j-mode", value: 0 } }
            ]
          }
        }
      },
    ],
  },
];

// Define the devices configuration
const devices = [
  {
    identifiers: {
      is_keyboard: true,
      is_pointing_device: true,
      product_id: 45919,
      vendor_id: 1133,
    },
    ignore: false,
    manipulate_caps_lock_led: false,
  },
  {
    identifiers: {
      is_pointing_device: true,
    },
    simple_modifications: [
      {
        from: { key_code: "right_command" },
        to: [{ key_code: "right_control" }],
      },
    ],
  },
  {
    identifiers: {
      is_keyboard: true,
      product_id: 50475,
      vendor_id: 1133,
    },
    ignore: true,
  },
];

// Define function keys mapping
const fn_function_keys = [
  {
    from: { key_code: "f3" },
    to: [{ key_code: "mission_control" }],
  },
  {
    from: { key_code: "f4" },
    to: [{ key_code: "launchpad" }],
  },
  {
    from: { key_code: "f5" },
    to: [{ key_code: "illumination_decrement" }],
  },
  {
    from: { key_code: "f6" },
    to: [{ key_code: "illumination_increment" }],
  },
  {
    from: { key_code: "f9" },
    to: [{ consumer_key_code: "fastforward" }],
  },
];

// Write the complete configuration to karabiner.json
fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: {
        show_in_menu_bar: false,
      },
      profiles: [
        {
          name: "Default",
          complex_modifications: {
            parameters: {
              "basic.simultaneous_threshold_milliseconds": 25,
              "basic.to_delayed_action_delay_milliseconds": 10,
              "basic.to_if_alone_timeout_milliseconds": 250,
              "basic.to_if_held_down_threshold_milliseconds": 500,
            },
            rules,
          },
          devices,
          fn_function_keys,
          selected: true,
          virtual_hid_keyboard: {
            country_code: 0,
            keyboard_type_v2: "ansi",
          },
        },
      ],
    },
    null,
    2
  )
);
