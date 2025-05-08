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
 * Configuration for creating a key layer
 */
export interface KeyLayerConfig {
  [key: string]: { key_code: KeyCode; modifiers?: ModifiersKeys[]; appTarget?: string };
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
    // Extract the to output without any appTarget property
    const toOutput = {
      key_code: output.key_code,
      ...(output.modifiers ? { modifiers: output.modifiers } : {})
    };

    // Add mode-based handler
    manipulators.push(
      manipulator()
        .from(key as KeyCode)
        .to(toOutput)
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
          toOutput
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
  private bindings: Record<string, { key_code: KeyCode, modifiers?: ModifiersKeys[], appTarget?: string }> = {};
  private conditions: Conditions[] = [];
  private threshold: number = 250;

  constructor(trigger: KeyCode) {
    this.trigger = trigger;
  }

  bind(key: KeyCode) {
    return {
      to: (targetKey: KeyCode, modifiers?: ModifiersKeys[], appTarget?: string) => {
        // If this key is already bound, we need to create a unique key in the bindings object
        const bindingKey = appTarget ? `${key}_${appTarget}` : key;
        this.bindings[bindingKey] = {
          key_code: targetKey,
          ...(modifiers ? { modifiers } : {}),
          ...(appTarget ? { appTarget } : {})
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
    const result: Manipulator[] = [];

    // Process each binding to create the appropriate manipulators
    Object.entries(this.bindings).forEach(([key, binding]) => {
      // Extract the actual key and remove any app target suffix
      const actualKey = key.split('_')[0] as KeyCode;

      // Create a base layer binding
      const manipulators = createKeyLayer(this.trigger, { [actualKey]: binding }, {
        conditions: this.conditions,
        simultaneousThreshold: this.threshold
      });

      // If there's an app target, add the appropriate condition
      if (binding.appTarget) {
        manipulators.forEach(m => {
          if (!m.conditions) m.conditions = [];

          if (binding.appTarget === "terminal") {
            m.conditions.push(forApp(["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]));
          } else if (binding.appTarget === "other") {
            m.conditions.push(unlessApp(["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]));
          }
        });
      }

      result.push(...manipulators);
    });

    return result;
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