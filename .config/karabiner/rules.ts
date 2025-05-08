// @ts-ignore
import fs from "fs";
import { KarabinerRules, KeyCode } from "./types";
import { createHyperSubLayers, app, open, rectangle, shell, createKeyLayerCombo, createSimultaneousKeyCombo } from "./utils";
import { manipulator, createRule, createKeyCombo, createAppSpecificKeyCombo, key, withOptionalModifiers, withMandatoryModifiers, forApp, unlessApp } from "./builders";
import { DEVICE_CONFIGS, DEVICE, DEVICE_COMBO } from "./devices";

// Only the rules array is defined at the top level
const rules: KarabinerRules[] = [
  // --- Right Cmd (alone) -> Enter ---
  createRule(
    "Right Cmd (alone) -> Enter",
    [
      manipulator()
        .fromKey("right_command", { optional: ["any"] })
        .to([{ key_code: "right_control" }])
        .toIfAlone([{ key_code: "return_or_enter" }])
        .forDevices(DEVICE_COMBO.APPLE_ALL)
        .build()
    ]
  ),
  // --- Caps Lock -> Escape (alone) | Ctrl (simple) + Vim/Arrow/Mouse ---
  (() => {
    const vimKeys: KeyCode[] = ["h", "j", "k", "l"];
    const arrowKeys: KeyCode[] = ["left_arrow", "down_arrow", "up_arrow", "right_arrow"];
    const shiftVimKeys: KeyCode[] = ["h", "k", "l"];
    const shiftArrowKeys: KeyCode[] = ["left_arrow", "up_arrow", "right_arrow"];
    return createRule(
      "Caps Lock -> Escape (alone) | Ctrl (simple)",
      [
        // Caps Lock alone -> Escape, held -> right_control
        manipulator()
          .fromKey("caps_lock", withOptionalModifiers("any"))
          .to(key("right_control"))
          .toIfAlone(key("escape"))
          .build(),

        // Vim-like arrow keys with Control
        ...vimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("right_control"))
            .to(key(arrowKeys[idx]))
            .build()
        ),

        // Command + Vim keys to Command + Arrow
        ...vimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("left_command", "right_control"))
            .to(key(arrowKeys[idx], ["left_command"]))
            .build()
        ),

        // Shift + Vim keys to Shift + Arrow (with JetBrains/Android Studio exception for j)
        ...shiftVimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("left_shift", "right_control"))
            .to(key(shiftArrowKeys[idx], ["left_shift"]))
            .build()
        ),
        // j with Shift+Ctrl, with app-specific conditions
        manipulator()
          .fromKey("j", withMandatoryModifiers("left_shift", "right_control"))
          .to(key("down_arrow", ["left_shift"]))
          .withCondition(unlessApp(["com.google.android.studio", "^com\\.jetbrains\\..*$"]))
          .build(),
        manipulator()
          .fromKey("j", withMandatoryModifiers("left_shift", "right_control"))
          .to(key("j", ["left_control", "left_shift"]))
          .withCondition(forApp(["com.google.android.studio", "^com\\.jetbrains\\..*$"]))
          .build(),

        // Option + Vim keys to Option + Arrow
        ...vimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("left_option", "right_control"))
            .to(key(arrowKeys[idx], ["left_option"]))
            .build()
        ),

        // Command + Option + Vim keys to Command + Option + Arrow
        ...vimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("left_command", "left_option", "right_control"))
            .to(key(arrowKeys[idx], ["left_command", "left_option"]))
            .build()
        ),

        // Command + Shift + Vim keys to Command + Shift + Arrow
        ...vimKeys.map((keyChar, idx) =>
          manipulator()
            .fromKey(keyChar, withMandatoryModifiers("left_command", "left_shift", "right_control"))
            .to(key(arrowKeys[idx], ["left_command", "left_shift"]))
            .build()
        ),

        // Mouse control with arrow keys
        ...[
          { key: "down_arrow" as KeyCode, mouse: { y: 1536 } },
          { key: "up_arrow" as KeyCode, mouse: { y: -1536 } },
          { key: "left_arrow" as KeyCode, mouse: { x: -1536 } },
          { key: "right_arrow" as KeyCode, mouse: { x: 1536 } },
        ].map(({ key, mouse }) =>
          manipulator()
            .fromKey(key, withMandatoryModifiers("right_control"))
            .to({ mouse_key: mouse })
            .build()
        ),

        // // Mouse clicks
        // manipulator()
        //   .fromKey("return_or_enter", withMandatoryModifiers("right_control"))
        //   .to({ pointing_button: "button1" })
        //   .build(),
        // manipulator()
        //   .fromKey("return_or_enter", withMandatoryModifiers("left_command", "right_control"))
        //   .to({ pointing_button: "button2" })
        //   .build(),
      ]
    );
  })(),
  // --- Special characters enabled with shift + numkey ---
  createRule(
    "special characters enabled with shift + numkey",
    [
      // F key combinations for special characters
      ...createSimultaneousKeyCombo("f", {
        i: { key_code: "8", modifiers: ["left_shift"] },  // *
        u: { key_code: "7", modifiers: ["left_shift"] },  // &
        y: { key_code: "6", modifiers: ["left_shift"] },  // ^
        o: { key_code: "backslash" },                     // \
        l: { key_code: "hyphen" },                        // -
        semicolon: { key_code: "equal_sign", modifiers: ["left_shift"] },  // +
        quote: { key_code: "equal_sign" },                // =
      }),
    ]
  ),
  // --- J-key special characters ---
  createRule(
    "J-key special character combinations",
    [
      ...createSimultaneousKeyCombo("j", {
        t: { key_code: "5", modifiers: ["left_shift"] },  // % (shift + 5)
        r: { key_code: "4", modifiers: ["left_shift"] },  // $ (shift + 4)
        e: { key_code: "3", modifiers: ["left_shift"] },  // # (shift + 3)
        w: { key_code: "2", modifiers: ["left_shift"] },  // @ (shift + 2)
        q: { key_code: "1", modifiers: ["left_shift"] },  // ! (shift + 1)
      }),
    ]
  ),
  // --- Bracket combinations ---
  createRule(
    "bracket combos",
    [
      ...createSimultaneousKeyCombo("f", {
        j: { key_code: "9", modifiers: ["left_shift"] },   // (
        k: { key_code: "0", modifiers: ["left_shift"] },   // )
        m: { key_code: "open_bracket" },                   // [
        comma: { key_code: "close_bracket" },              // ]
        period: { key_code: "open_bracket", modifiers: ["left_shift"] },   // {
        slash: { key_code: "close_bracket", modifiers: ["left_shift"] },   // }
      }),
    ]
  ),
  // --- Delete sequences ---
  createRule(
    "delete sequences",
    [
      // App-specific J key combinations
      ...createAppSpecificKeyCombo(
        "j",
        [
          // J + S -> Control + U (clear line) in Terminal / Command + Backspace (delete to start of line) in other apps
          {
            key: "s",
            terminalOutput: { key_code: "u", modifiers: ["left_control"] },
            otherAppsOutput: { key_code: "delete_or_backspace", modifiers: ["left_command"] }
          },
          // J + D -> Control + W (delete word) in Terminal / Option + Backspace (delete word) in other apps
          {
            key: "d",
            terminalOutput: { key_code: "w", modifiers: ["left_control"] },
            otherAppsOutput: { key_code: "delete_or_backspace", modifiers: ["left_option"] }
          },
        ]
      ),

      // J + F -> Backspace (delete character)
      ...createKeyCombo("j", "f", { key_code: "delete_or_backspace" }),
    ]
  ),
  // --- Command next/prev tab ---
  createRule(
    "cmd next/prev tab",
    [
      ...createSimultaneousKeyCombo("j", {
        x: { key_code: "open_bracket", modifiers: ["left_command", "left_shift"] },   // previous tab
        c: { key_code: "close_bracket", modifiers: ["left_command", "left_shift"] },  // next tab
      }),
    ]
  ),

  // Example of adding a new F-key combo:
  // To add F+O -> \ (backslash), simply add this to the "special characters" section:
  // ...createKeyCombo("f", "o", { key_code: "backslash" }),
];

// Create the complete configuration object
const karabinerConfig = {
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
      // DEVICE_CONFIGS,
      // fn_function_keys,
      // selected: true,
      virtual_hid_keyboard: {
        country_code: 0,
        keyboard_type_v2: "ansi",
      },
    },
  ],
};

// Write the complete configuration to karabiner.json
fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(karabinerConfig, null, 2)
);
