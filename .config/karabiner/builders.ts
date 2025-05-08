import {
  KarabinerRules,
  Manipulator,
  To,
  KeyCode,
  Modifiers,
  Conditions,
  SimultaneousOptions,
  ModifiersKeys
} from "./types";
import { DEVICE, DEVICE_COMBO } from "./devices";

// Define these if not available in types.ts
const ARROW_KEYS: KeyCode[] = ["left_arrow", "down_arrow", "up_arrow", "right_arrow"];
const VIM_NAV_KEYS: KeyCode[] = ["h", "j", "k", "l"];

/**
 * Builder class for creating Karabiner manipulator objects
 */
export class ManipulatorBuilder {
  private manipulator: Partial<Manipulator> = { type: "basic" };

  /**
   * Unified method to specify source key with modifiers or simultaneous keys
   *
   * @example
   * // Simple key
   * .from("a")
   *
   * // Key with optional modifiers
   * .from("a", { optional: ["any"] })
   *
   * // Key with mandatory modifiers
   * .from("a", { mandatory: ["left_shift", "right_control"] })
   *
   * // Simultaneous keys
   * .from(["a", "b"], {
   *   detect_key_down_uninterruptedly: true,
   *   key_down_order: "strict"
   * })
   */
  from(
    key: KeyCode | KeyCode[],
    options?: {
      optional?: ModifiersKeys[],
      mandatory?: ModifiersKeys[],
      simultaneousOptions?: SimultaneousOptions
    }
  ): ManipulatorBuilder {
    if (Array.isArray(key)) {
      // Handle simultaneous keys
      this.manipulator.from = {
        simultaneous: key.map(k => ({ key_code: k })),
      };
      if (options?.simultaneousOptions) {
        this.manipulator.from.simultaneous_options = options.simultaneousOptions;
      }
    } else {
      // Handle single key with modifiers
      this.manipulator.from = { key_code: key };
      if (options) {
        let modifiers: Partial<Modifiers> = {};
        if (options.optional) modifiers.optional = options.optional;
        if (options.mandatory) modifiers.mandatory = options.mandatory;

        if (Object.keys(modifiers).length > 0) {
          this.manipulator.from.modifiers = modifiers;
        }
      }
    }

    return this;
  }

  /**
   * Shorthand to create from with mandatory modifiers
   *
   * @example
   * .fromWithModifiers("a", ["left_shift", "right_control"])
   */
  fromWithModifiers(key: KeyCode, mandatoryModifiers: ModifiersKeys[]): ManipulatorBuilder {
    return this.from(key, { mandatory: mandatoryModifiers });
  }

  /**
   * Shorthand to create from with optional modifiers
   *
   * @example
   * .fromWithOptionalModifiers("a", ["any"])
   */
  fromWithOptionalModifiers(key: KeyCode, optionalModifiers: ModifiersKeys[]): ManipulatorBuilder {
    return this.from(key, { optional: optionalModifiers });
  }

  /**
   * Unified method to specify target outputs for different scenarios
   *
   * @example
   * // Simple key output
   * .to("a")
   *
   * // Key with modifiers
   * .to("a", { modifiers: ["left_shift"] })
   *
   * // Multiple outputs
   * .to([{ key_code: "a" }, { key_code: "b" }])
   *
   * // Specify if_alone behavior
   * .to("escape", { if_alone: true })
   *
   * // Mouse key
   * .to({ mouse_key: { x: 1536 } })
   *
   * // Set variable
   * .to({ set_variable: { name: "mode", value: 1 } })
   */
  to(
    keyOrCommands: KeyCode | To | To[],
    options?: {
      modifiers?: ModifiersKeys[],
      if_alone?: boolean,
      after_key_up?: boolean
    }
  ): ManipulatorBuilder {
    let commands: To[];

    // Convert the input to an array of commands
    if (typeof keyOrCommands === 'string') {
      // It's a simple key code
      const keyCommand: To = {
        key_code: keyOrCommands as KeyCode,
        ...(options?.modifiers ? { modifiers: options.modifiers } : {})
      };
      commands = [keyCommand];
    } else if (!Array.isArray(keyOrCommands)) {
      // It's a single To object
      commands = [keyOrCommands];
    } else {
      // It's already an array of To objects
      commands = keyOrCommands;
    }

    // Determine which property to set based on options
    if (options?.if_alone) {
      this.manipulator.to_if_alone = commands;
    } else if (options?.after_key_up) {
      this.manipulator.to_after_key_up = commands;
    } else {
      this.manipulator.to = commands;
    }

    return this;
  }

  /**
   * Shorthand to add a key with modifiers as output
   */
  toWithModifiers(key: KeyCode, modifiers: ModifiersKeys[]): ManipulatorBuilder {
    return this.to(key, { modifiers });
  }

  /**
   * Shorthand to add a key as output when the source key is pressed alone
   */
  toIfAlone(key: KeyCode, modifiers?: ModifiersKeys[]): ManipulatorBuilder {
    return this.to(key, { modifiers, if_alone: true });
  }

  /**
   * Shorthand to add actions after key up
   */
  toAfterKeyUp(keyOrCommands: KeyCode | To | To[], modifiers?: ModifiersKeys[]): ManipulatorBuilder {
    if (typeof keyOrCommands === 'string' && modifiers) {
      return this.to(keyOrCommands, { modifiers, after_key_up: true });
    }
    return this.to(keyOrCommands, { after_key_up: true });
  }

  /**
   * Set a variable to a specific value
   */
  setVariable(name: string, value: number | boolean | string): ManipulatorBuilder {
    return this.to({ set_variable: { name, value } });
  }

  /**
   * Add mouse movement output
   */
  toMouseMovement({ x, y, wheel_v, wheel_h }: { x?: number, y?: number, wheel_v?: number, wheel_h?: number }): ManipulatorBuilder {
    return this.to({
      mouse_key: {
        x,
        y,
        vertical_wheel: wheel_v,
        horizontal_wheel: wheel_h
      }
    });
  }

  /**
   * Add a condition to the manipulator
   */
  withCondition(condition: Conditions): ManipulatorBuilder {
    if (!this.manipulator.conditions) {
      this.manipulator.conditions = [condition];
    } else {
      this.manipulator.conditions.push(condition);
    }
    return this;
  }

  /**
   * Add a device condition to limit the rule to specific devices
   */
  forDevices(identifiersOrDevice: object[] | keyof typeof DEVICE_COMBO | keyof typeof DEVICE): ManipulatorBuilder {
    let identifiers: object[];

    if (typeof identifiersOrDevice === 'string') {
      // Check if it's a DEVICE_COMBO key
      if (Object.keys(DEVICE_COMBO).includes(identifiersOrDevice as string)) {
        identifiers = DEVICE_COMBO[identifiersOrDevice as keyof typeof DEVICE_COMBO];
      }
      // Otherwise it must be a single DEVICE
      else {
        identifiers = [DEVICE[identifiersOrDevice as keyof typeof DEVICE]];
      }
    }
    // Raw array of identifiers
    else {
      identifiers = identifiersOrDevice;
    }

    return this.withCondition({
      type: "device_if",
      identifiers
    } as Conditions);
  }

  /**
   * Add a variable condition
   */
  ifVariable(name: string, value: number): ManipulatorBuilder {
    return this.withCondition({
      type: "variable_if",
      name,
      value
    } as Conditions);
  }

  /**
   * Add a condition to exclude a variable with a specific value
   */
  unlessVariable(name: string, value: number): ManipulatorBuilder {
    return this.withCondition({
      type: "variable_unless",
      name,
      value
    } as Conditions);
  }

  /**
   * Set a parameter for the manipulator
   */
  withParameter(name: string, value: number): ManipulatorBuilder {
    if (!this.manipulator.parameters) {
      this.manipulator.parameters = {};
    }
    this.manipulator.parameters[name] = value;
    return this;
  }

  /**
   * Set common parameters with reasonable defaults
   */
  withStandardParameters({
    simultaneousThreshold = 250,
    toDelayedActionDelay = 10,
    toIfAloneTimeout = 250,
    toIfHeldDownThreshold = 500
  } = {}): ManipulatorBuilder {
    return this
      .withParameter("basic.simultaneous_threshold_milliseconds", simultaneousThreshold)
      .withParameter("basic.to_delayed_action_delay_milliseconds", toDelayedActionDelay)
      .withParameter("basic.to_if_alone_timeout_milliseconds", toIfAloneTimeout)
      .withParameter("basic.to_if_held_down_threshold_milliseconds", toIfHeldDownThreshold);
  }

  /**
   * Set a description for the manipulator
   */
  withDescription(description: string): ManipulatorBuilder {
    this.manipulator.description = description;
    return this;
  }

  /**
   * Build the manipulator object
   */
  build(): Manipulator {
    return this.manipulator as Manipulator;
  }
}

/**
 * Create a new manipulator builder
 */
export function manipulator(): ManipulatorBuilder {
  return new ManipulatorBuilder();
}

/**
 * Create a Karabiner rule with description and manipulators
 */
export function createRule(description: string, manipulators: Manipulator[]): KarabinerRules {
  return { description, manipulators };
}

/**
 * Helper to create key that outputs another key with modifiers
 */
export function key(keyCode: KeyCode, modifiers?: ModifiersKeys[]): To {
  return modifiers ? { key_code: keyCode, modifiers } : { key_code: keyCode };
}

/**
 * Helper for creating optional modifiers in 'from' key definition
 */
export function withOptionalModifiers(...modifiers: ModifiersKeys[]): Partial<Modifiers> {
  return { optional: modifiers };
}

/**
 * Helper for creating mandatory modifiers in 'from' key definition
 */
export function withMandatoryModifiers(...modifiers: ModifiersKeys[]): Partial<Modifiers> {
  return { mandatory: modifiers };
}

/**
 * Configuration for a key combination or mapping
 */
export interface KeyComboConfig {
  key: KeyCode;
  output: To | To[];
}

/**
 * Configuration for app-specific key combinations
 */
export interface AppSpecificKeyComboConfig {
  key: KeyCode;
  terminalOutput: To | To[];
  otherAppsOutput: To | To[];
}

/**
 * Helper function to create key layer combinations
 */
export function createKeyCombo(
  layer_key: KeyCode,
  targetKey: KeyCode | KeyComboConfig[],
  output?: To | To[]
): Manipulator[] {
  // If targetKey is an array, we're using the bulk version
  if (Array.isArray(targetKey)) {
    return targetKey.flatMap(combo =>
      createKeyCombo(layer_key, combo.key, combo.output)
    );
  }

  // Regular single combo version
  const outputs = Array.isArray(output) ? output : [output!];
  const modalVar = `${layer_key}-mode`;

  return [
    // When mode is active
    manipulator()
      .from(targetKey)
      .to(outputs)
      .ifVariable(modalVar, 1)
      .build(),

    // Simultaneous press
    manipulator()
      .from([layer_key, targetKey], {
        simultaneousOptions: {
          detect_key_down_uninterruptedly: true,
          key_down_order: "strict",
          key_up_order: "strict_inverse",
          key_up_when: "any",
          to_after_key_up: [{ set_variable: { name: modalVar, value: 0 } }]
        }
      })
      .to([
        { set_variable: { name: modalVar, value: 1 } },
        ...outputs
      ])
      .withParameter("basic.simultaneous_threshold_milliseconds", 250)
      .build()
  ];
}

/**
 * Helper for creating app-specific key layer combinations
 */
export function createAppSpecificKeyCombo(
  layer_key: KeyCode,
  targetKey: KeyCode | AppSpecificKeyComboConfig[],
  terminalOutput?: To | To[],
  otherAppsOutput?: To | To[]
): Manipulator[] {
  // If targetKey is an array, we're using the bulk version
  if (Array.isArray(targetKey)) {
    return targetKey.flatMap(combo =>
      createAppSpecificKeyCombo(layer_key, combo.key, combo.terminalOutput, combo.otherAppsOutput)
    );
  }

  // Regular single combo version
  return [
    ...createKeyCombo(layer_key, targetKey, terminalOutput!).map(m => {
      if (!m.conditions) m.conditions = [];
      m.conditions.push(forTerminal());
      return m;
    }),
    ...createKeyCombo(layer_key, targetKey, otherAppsOutput!).map(m => {
      if (!m.conditions) m.conditions = [];
      m.conditions.push(unlessTerminal());
      return m;
    })
  ];
}

/**
 * Helper for app-specific conditions
 */
export function forApp(bundleIdentifiers: string[]): Conditions {
  return {
    type: "frontmost_application_if",
    bundle_identifiers: bundleIdentifiers
  } as Conditions;
}

/**
 * Helper for excluding apps from a rule
 */
export function unlessApp(bundleIdentifiers: string[]): Conditions {
  return {
    type: "frontmost_application_unless",
    bundle_identifiers: bundleIdentifiers
  } as Conditions;
}

/**
 * Helper for terminal application conditions
 */
export function forTerminal(): Conditions {
  return forApp(["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]);
}

/**
 * Helper for excluding terminal applications
 */
export function unlessTerminal(): Conditions {
  return unlessApp(["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]);
}

/**
 * Configuration for creating a key layer
 */
export interface KeyLayerConfig {
  [key: string]: { key_code: KeyCode; modifiers?: ModifiersKeys[] };
}

/**
 * Creates a key combination layer with configurable behavior.
 * When a trigger key is held and another key is pressed, the output is triggered.
 * Supports both simultaneous press and mode-based activation.
 *
 * @param trigger The trigger key that activates the layer
 * @param combos The key combinations to create with their outputs
 * @param options Optional configuration for conditions
 * @returns Array of manipulators for the key layer
 *
 * @example
 * createKeyLayer("f", {
 *   j: { key_code: "9", modifiers: ["left_shift"] }, // f+j -> (
 *   k: { key_code: "0", modifiers: ["left_shift"] }, // f+k -> )
 * })
 */
export function createKeyLayer(
  trigger: KeyCode,
  combos: KeyLayerConfig,
  options: {
    conditions?: Conditions[];
    simultaneousThreshold?: number;
  } = {}
): Manipulator[] {
  const { conditions = [], simultaneousThreshold = 250 } = options;
  const variableName = `${trigger}-mode`;
  const manipulators: Manipulator[] = [];

  Object.entries(combos).forEach(([key, output]) => {
    // Add mode-based handler
    manipulators.push(
      manipulator()
        .from(key as KeyCode)
        .to(output)
        .ifVariable(variableName, 1)
        .build()
    );

    // Add any additional conditions
    if (conditions.length > 0) {
      conditions.forEach(condition => {
        manipulators[manipulators.length - 1].conditions!.push(condition);
      });
    }

    // Add simultaneous handler
    manipulators.push(
      manipulator()
        .from([trigger, key as KeyCode], {
          simultaneousOptions: {
            detect_key_down_uninterruptedly: true,
            key_down_order: "strict",
            key_up_order: "strict_inverse",
            key_up_when: "any",
            to_after_key_up: [
              {
                set_variable: {
                  name: variableName,
                  value: 0,
                },
              },
            ],
          }
        })
        .to([
          {
            set_variable: {
              name: variableName,
              value: 1,
            },
          },
          output
        ])
        .withParameter("basic.simultaneous_threshold_milliseconds", simultaneousThreshold)
        .build()
    );

    // Add any additional conditions to the simultaneous handler
    if (conditions.length > 0) {
      conditions.forEach(condition => {
        manipulators[manipulators.length - 1].conditions!.push(condition);
      });
    }
  });

  return manipulators;
}

/**
 * Creates a vim-style navigation layer that maps h,j,k,l to arrow keys
 * with support for various modifier combinations
 *
 * @param trigger The key that activates the vim navigation layer
 * @param options Optional configuration and customization
 * @returns Array of manipulators for vim navigation
 *
 * @example
 * // Basic vim navigation with caps_lock as trigger
 * createVimNavigationLayer("right_control")
 *
 * @example
 * // Custom vim navigation for specific apps
 * createVimNavigationLayer("right_option", {
 *   conditions: [forApp(["com.apple.Safari"])]
 * })
 *
 * @example
 * // Custom modifier combinations
 * createVimNavigationLayer("right_control", {
 *   modifierCombinations: [
 *     { from: [], to: [] },  // No modifiers
 *     { from: ["left_shift"], to: ["left_shift"] }  // Shift only
 *   ]
 * })
 */
export function createVimNavigationLayer(
  trigger: KeyCode,
  options: {
    modifierCombinations?: Array<{from: ModifiersKeys[], to: ModifiersKeys[]}>;
    conditions?: Conditions[];
    simultaneousThreshold?: number;
  } = {}
): Manipulator[] {
  const {
    modifierCombinations = [
      { from: [], to: [] },
      { from: ["left_command"], to: ["left_command"] },
      { from: ["left_option"], to: ["left_option"] },
      { from: ["left_shift"], to: ["left_shift"] },
      { from: ["left_command", "left_option"], to: ["left_command", "left_option"] },
      { from: ["left_command", "left_shift"], to: ["left_command", "left_shift"] },
    ],
    conditions = [],
    simultaneousThreshold = 250
  } = options;

  const manipulators: Manipulator[] = [];

  // Create mappings for each vim key to the corresponding arrow key
  VIM_NAV_KEYS.forEach((keyChar, idx) => {
    modifierCombinations.forEach(combo => {
      // Add the appropriate modifiers
      const mandatoryMods = ["right_control" as ModifiersKeys, ...combo.from];

      manipulators.push(
        manipulator()
          .from(keyChar, { mandatory: mandatoryMods })
          .to(ARROW_KEYS[idx], { modifiers: combo.to })
          .build()
      );

      // Apply conditions if provided
      if (conditions.length > 0 && manipulators.length > 0) {
        conditions.forEach(condition => {
          const lastManipulator = manipulators[manipulators.length - 1];
          if (!lastManipulator.conditions) {
            lastManipulator.conditions = [];
          }
          lastManipulator.conditions!.push(condition);
        });
      }
    });
  });

  return manipulators;
}

/**
 * Creates mouse movement controls using the specified trigger key and arrow keys
 *
 * @param trigger The key that activates the mouse movement
 * @param options Optional configurations
 */
export function createMouseControls(
  trigger: KeyCode,
  options: {
    distance?: number;
    conditions?: Conditions[];
  } = {}
): Manipulator[] {
  const { distance = 1536, conditions = [] } = options;

  const mouseMovements = [
    { key: "down_arrow", mouse: { y: distance } },
    { key: "up_arrow", mouse: { y: -distance } },
    { key: "left_arrow", mouse: { x: -distance } },
    { key: "right_arrow", mouse: { x: distance } },
  ];

  return mouseMovements.map(({ key, mouse }) => {
    const manipulator = new ManipulatorBuilder()
      .from(key as KeyCode, { mandatory: [trigger as ModifiersKeys] })
      .toMouseMovement(mouse);

    // Apply conditions
    conditions.forEach(condition => {
      manipulator.withCondition(condition);
    });

    return manipulator.build();
  });
}

/**
 * Common modifiers helper to create both from and to modifiers
 * @example
 * // Using shift
 * mod.shift.from  // Gives ["left_shift"]
 * mod.shift.to    // Same for output
 *
 * // Command+Shift
 * mod.cmd.shift.from  // Gives ["left_command", "left_shift"]
 */
export const mod = createModifierHelper();

function createModifierHelper() {
  const modifierMap = {
    cmd: "left_command" as ModifiersKeys,
    opt: "left_option" as ModifiersKeys,
    alt: "left_option" as ModifiersKeys,
    shift: "left_shift" as ModifiersKeys,
    ctrl: "left_control" as ModifiersKeys
  };

  return createProxyChain(modifierMap);
}

function createProxyChain(modifierMap: Record<string, ModifiersKeys>) {
  const baseObject = {
    _keys: [] as ModifiersKeys[],
    get from() { return this._keys; },
    get to() { return this._keys; }
  };

  return new Proxy(baseObject, {
    get(target, prop) {
      if (typeof prop === 'string' && prop in modifierMap) {
        const newChain = createProxyChain(modifierMap);
        newChain._keys = [...target._keys, modifierMap[prop]];
        return newChain;
      }
      return Reflect.get(target, prop);
    }
  });
}

/**
 * Creates a key binding layer that activates when trigger key is used
 * @example
 * // Create F-key layer for brackets
 * layer("f")
 *   .bind("j").to("9", ["left_shift"])  // (
 *   .bind("k").to("0", ["left_shift"])  // )
 *   .bind("m").to("open_bracket")       // [
 *   .bind("comma").to("close_bracket")  // ]
 */
export function layer(triggerKey: KeyCode) {
  return new LayerBuilder(triggerKey);
}

class LayerBuilder {
  private trigger: KeyCode;
  private bindings: Record<string, { key_code: KeyCode, modifiers?: ModifiersKeys[] }> = {};
  private conditions: Conditions[] = [];
  private threshold: number = 250;

  constructor(trigger: KeyCode) {
    this.trigger = trigger;
  }

  bind(key: KeyCode) {
    return {
      to: (targetKey: KeyCode, modifiers?: ModifiersKeys[]) => {
        this.bindings[key] = {
          key_code: targetKey,
          ...(modifiers ? { modifiers } : {})
        };
        return this;
      }
    };
  }

  when(condition: Conditions) {
    this.conditions.push(condition);
    return this;
  }

  forApps(bundleIds: string[]) {
    this.conditions.push(forApp(bundleIds));
    return this;
  }

  unlessApps(bundleIds: string[]) {
    this.conditions.push(unlessApp(bundleIds));
    return this;
  }

  withThreshold(ms: number) {
    this.threshold = ms;
    return this;
  }

  build(): Manipulator[] {
    return createKeyLayer(this.trigger, this.bindings, {
      conditions: this.conditions,
      simultaneousThreshold: this.threshold
    });
  }
}

/**
 * Creates a key mapping configuration with fluent interface
 * @example
 * keymap("My Key Mappings")
 *   .remap("caps_lock").to("escape").whenAlone().otherwise("right_control")
 *   .remap("right_command").to("return_or_enter").whenAlone()
 *   .forApps(["com.apple.Terminal"])
 *     .remap("j", ["control"]).to("up_arrow")
 *   .build()
 */
export function keymap(description: string) {
  return new KeyMapBuilder(description);
}

class KeyMapBuilder {
  private description: string;
  private manipulators: Manipulator[] = [];
  private currentConditions: Conditions[] = [];

  constructor(description: string) {
    this.description = description;
  }

  remap(key: KeyCode, modifiers?: ModifiersKeys[]) {
    const builder = this;
    return {
      to: (targetKey: KeyCode, targetModifiers?: ModifiersKeys[]) => {
        const manip = manipulator()
          .from(key, modifiers ? { mandatory: modifiers } : undefined)
          .to(targetKey, { modifiers: targetModifiers });

        // Apply any active conditions
        this.currentConditions.forEach(condition => {
          manip.withCondition(condition);
        });

        this.manipulators.push(manip.build());

        return {
          whenAlone: () => {
            // Replace the last manipulator with a dual role one
            const lastIdx = this.manipulators.length - 1;
            const last = this.manipulators[lastIdx];

            this.manipulators[lastIdx] = manipulator()
              .from(key, modifiers ? { mandatory: modifiers } : undefined)
              .to(last.to![0].key_code!, { modifiers: last.to![0].modifiers })
              .toIfAlone(targetKey, targetModifiers)
              .build();

            return builder;
          },
          otherwise: (heldKey: KeyCode, heldModifiers?: ModifiersKeys[]) => {
            // Replace with dual role
            const lastIdx = this.manipulators.length - 1;

            this.manipulators[lastIdx] = manipulator()
              .from(key, modifiers ? { mandatory: modifiers } : undefined)
              .to(heldKey, { modifiers: heldModifiers })
              .toIfAlone(targetKey, targetModifiers)
              .build();

            return builder;
          }
        };
      }
    };
  }

  forApps(bundleIds: string[]) {
    const condition = forApp(bundleIds);
    this.currentConditions.push(condition);
    return this;
  }

  unlessApps(bundleIds: string[]) {
    const condition = unlessApp(bundleIds);
    this.currentConditions.push(condition);
    return this;
  }

  clearConditions() {
    this.currentConditions = [];
    return this;
  }

  build(): KarabinerRules {
    return createRule(this.description, this.manipulators);
  }
}

/**
 * Creates a simplified interface for mapping key combinations
 * with a more expressive and readable API
 */
export class KeyMappingBuilder {
  private manipulators: Manipulator[] = [];
  private description: string;

  constructor(description: string) {
    this.description = description;
  }

  /**
   * Map a key to another key
   */
  map(from: KeyCode, to: KeyCode): KeyMappingBuilder {
    this.manipulators.push(
      manipulator().from(from).to(to).build()
    );
    return this;
  }

  /**
   * Map a key with modifiers to another key with modifiers
   */
  mapWithModifiers(
    from: KeyCode,
    fromModifiers: ModifiersKeys[],
    to: KeyCode,
    toModifiers: ModifiersKeys[] = []
  ): KeyMappingBuilder {
    this.manipulators.push(
      manipulator()
        .fromWithModifiers(from, fromModifiers)
        .toWithModifiers(to, toModifiers)
        .build()
    );
    return this;
  }

  /**
   * Add a key that does one thing when pressed alone, another when held
   */
  mapDualRole(
    key: KeyCode,
    whenAlone: KeyCode,
    whenHeld: KeyCode,
    modifiersWhenAlone: ModifiersKeys[] = [],
    modifiersWhenHeld: ModifiersKeys[] = []
  ): KeyMappingBuilder {
    this.manipulators.push(
      manipulator()
        .from(key)
        .to(whenHeld, { modifiers: modifiersWhenHeld })
        .toIfAlone(whenAlone, modifiersWhenAlone)
        .build()
    );
    return this;
  }

  /**
   * Add a condition that applies to all following mappings until clearConditions is called
   */
  withCondition(condition: Conditions): KeyMappingBuilder {
    // Add the condition to the last manipulator
    if (this.manipulators.length > 0) {
      const lastManipulator = this.manipulators[this.manipulators.length - 1];
      if (!lastManipulator.conditions) {
        lastManipulator.conditions = [];
      }
      lastManipulator.conditions.push(condition);
    }
    return this;
  }

  /**
   * Create a rule from all the defined manipulators
   */
  build(): KarabinerRules {
    return createRule(this.description, this.manipulators);
  }
}

/**
 * Factory function to create a key mapping builder
 */
export function createKeyMapping(description: string): KeyMappingBuilder {
  return new KeyMappingBuilder(description);
}