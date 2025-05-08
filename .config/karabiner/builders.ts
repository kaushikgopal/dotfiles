import { KarabinerRules, Manipulator, To, KeyCode, Modifiers, Conditions, SimultaneousOptions, ModifiersKeys } from "./types";
import { DEVICE, DEVICE_COMBO } from "./devices";

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
 * Helper function to create key layer combinations
 */
export function createKeyCombo(
  layer_key: KeyCode,
  targetKey: KeyCode | Array<{key: KeyCode, output: To | To[]}>,
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
  targetKey: KeyCode | Array<{key: KeyCode, terminalOutput: To | To[], otherAppsOutput: To | To[]}>,
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
  return {
    type: "frontmost_application_if",
    bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
  } as Conditions;
}

/**
 * Helper for excluding terminal applications
 */
export function unlessTerminal(): Conditions {
  return {
    type: "frontmost_application_unless",
    bundle_identifiers: ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"]
  } as Conditions;
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
  combos: { [key: string]: { key_code: KeyCode; modifiers?: ModifiersKeys[] } },
  options: {
    conditions?: Conditions[];
  } = {}
): Manipulator[] {
  const { conditions = [] } = options;
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
        .withParameter("basic.simultaneous_threshold_milliseconds", 250)
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