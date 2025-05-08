// @ts-ignore
import fs from "fs";
import { KarabinerRules, KeyCode, ModifiersKeys, Manipulator } from "./types";
import {
  manipulator,
  createRule,
  createAppSpecificKeyCombo,
  forApp,
  unlessApp,
  createKeyLayer,
  keymap,
  layer,
} from "./builders";

// Only the rules array is defined at the top level
const rules: KarabinerRules[] = [

  // --- Right Cmd (alone) -> Enter ---
  keymap("Right Cmd (alone) -> Enter")
    .remap("right_command").to("return_or_enter").whenAlone()
    .build(),

  // --- Caps Lock -> Escape (alone) | Ctrl (simple) + Vim/Arrow/Mouse ---
  createCapsLockRule(),

  // --- Special characters enabled with shift + numkey ---
  createRule(
    "special characters enabled with shift + numkey",
    layer("f")
      .bind("i").to("8", ["left_shift"])  // *
      .bind("u").to("7", ["left_shift"])  // &
      .bind("y").to("6", ["left_shift"])  // ^
      .bind("o").to("backslash")          // \
      .bind("l").to("hyphen")             // -
      .bind("semicolon").to("equal_sign", ["left_shift"])  // +
      .bind("quote").to("equal_sign")     // =
      .build()
  ),

  // --- J-key special character combinations ---
  createRule(
    "J-key special character combinations",
    layer("j")
      .bind("t").to("5", ["left_shift"])  // %
      .bind("r").to("4", ["left_shift"])  // $
      .bind("e").to("3", ["left_shift"])  // #
      .bind("w").to("2", ["left_shift"])  // @
      .bind("q").to("1", ["left_shift"])  // !
      .build()
  ),

  // --- Bracket combinations ---
  createRule(
    "bracket combos",
    layer("f")
      .bind("j").to("9", ["left_shift"])  // (
      .bind("k").to("0", ["left_shift"])  // )
      .bind("m").to("open_bracket")       // [
      .bind("comma").to("close_bracket")  // ]
      .bind("period").to("open_bracket", ["left_shift"])  // {
      .bind("slash").to("close_bracket", ["left_shift"])  // }
      .build()
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
      ...layer("j")
        .bind("f").to("delete_or_backspace")
        .build()
    ]
  ),

  // --- Command next/prev tab ---
  createRule(
    "cmd next/prev tab",
    layer("j")
      .bind("x").to("open_bracket", ["left_command", "left_shift"])   // previous tab
      .bind("c").to("close_bracket", ["left_command", "left_shift"])  // next tab
      .build()
  )
];

/**
 * Creates the Caps Lock rule with vim navigation
 */
function createCapsLockRule(): KarabinerRules {
  return createRule(
    "Caps Lock -> Escape (alone) | Ctrl (simple)",
    [
      // Caps Lock alone -> Escape, held -> right_control
      manipulator()
        .from("caps_lock", { optional: ["any"] })
        .to("right_control")
        .to("escape", { if_alone: true })
        .build(),

      // j with Shift+Ctrl, with app-specific conditions
      manipulator()
        .from("j", { mandatory: ["left_shift", "right_control"] })
        .to("down_arrow", { modifiers: ["left_shift"] })
        .withCondition(unlessApp(["com.google.android.studio", "^com\\.jetbrains\\..*$"]))
        .build(),

      manipulator()
        .from("j", { mandatory: ["left_shift", "right_control"] })
        .to("j", { modifiers: ["left_control", "left_shift"] })
        .withCondition(forApp(["com.google.android.studio", "^com\\.jetbrains\\..*$"]))
        .build(),

      // CapLock + Vim keys -> quick arrow keys (along with modifier combinations)
      ...createVimNavigationManipulators(),

      // Mouse control with arrow keys
      ...(
        [
          { key: "down_arrow", mouse: { y: 1536 } },
          { key: "up_arrow", mouse: { y: -1536 } },
          { key: "left_arrow", mouse: { x: -1536 } },
          { key: "right_arrow", mouse: { x: 1536 } },
        ] as Array<{ key: KeyCode, mouse: { y?: number, x?: number } }>
      ).map(({ key, mouse }) =>
        manipulator()
          .from(key, { mandatory: ["right_control"] })
          .to({ mouse_key: mouse })
          .build()
      ),
    ]
  );
}

/**
 * Creates manipulators for vim-style navigation with various modifier combinations
 */
function createVimNavigationManipulators(): Manipulator[] {
  const vimKeys: KeyCode[] = ["h", "j", "k", "l"];
  const arrowKeys: KeyCode[] = ["left_arrow", "down_arrow", "up_arrow", "right_arrow"];

  type ModifierCombo = { from: ModifiersKeys[]; to: ModifiersKeys[] };

  const modifierCombos: ModifierCombo[] = [
    { from: ["right_control"], to: [] },
    { from: ["right_control", "left_command"],                to: ["left_command"] },
    { from: ["right_control", "left_option"],                 to: ["left_option"] },
    { from: ["right_control", "left_shift"],                  to: ["left_shift"] },
    { from: ["right_control", "left_command", "left_option"], to: ["left_command", "left_option"] },
    { from: ["right_control", "left_command", "left_shift"],  to: ["left_command", "left_shift"] },
  ];

  return modifierCombos.flatMap(combo => {
    return vimKeys.map((keyChar, idx) => {
      return manipulator()
        .from(keyChar, { mandatory: combo.from })
        .to(arrowKeys[idx], { modifiers: combo.to })
        .build();
    });
  });
}

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
