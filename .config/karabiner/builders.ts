import { KarabinerRules, Manipulator, From, To, KeyCode, Modifiers, Conditions, Parameters, SimultaneousOptions, SimultaneousFrom } from "./types";
import { DEVICE, DEVICE_COMBO } from "./devices";

/**
 * Builder class for creating Karabiner manipulator objects
 */
export class ManipulatorBuilder {
  private manipulator: Partial<Manipulator> = { type: "basic" };

  /**
   * Specify the source key and optional modifiers
   */
  fromKey(key: KeyCode, modifiers?: Partial<Modifiers>): ManipulatorBuilder {
    this.manipulator.from = { key_code: key };
    if (modifiers) this.manipulator.from.modifiers = modifiers;
    return this;
  }

  /**
   * Specify simultaneous key combination
   */
  fromSimultaneous(
    keys: KeyCode[],
    options?: SimultaneousOptions
  ): ManipulatorBuilder {
    this.manipulator.from = {
      simultaneous: keys.map(key => ({ key_code: key })),
    };
    if (options) {
      this.manipulator.from.simultaneous_options = options;
    }
    return this;
  }

  /**
   * Set the target key or commands when the key is pressed
   */
  to(keyOrCommands: KeyCode | To | To[]): ManipulatorBuilder {
    if (typeof keyOrCommands === 'string') {
      this.manipulator.to = [{ key_code: keyOrCommands as KeyCode }];
    } else if (!Array.isArray(keyOrCommands)) {
      this.manipulator.to = [keyOrCommands];
    } else {
      this.manipulator.to = keyOrCommands;
    }
    return this;
  }

  /**
   * Set the target key or commands when the key is pressed alone
   */
  toIfAlone(keyOrCommands: KeyCode | To | To[]): ManipulatorBuilder {
    if (typeof keyOrCommands === 'string') {
      this.manipulator.to_if_alone = [{ key_code: keyOrCommands as KeyCode }];
    } else if (!Array.isArray(keyOrCommands)) {
      this.manipulator.to_if_alone = [keyOrCommands];
    } else {
      this.manipulator.to_if_alone = keyOrCommands;
    }
    return this;
  }

  /**
   * Set actions to execute after key up
   */
  toAfterKeyUp(actions: To | To[]): ManipulatorBuilder {
    if (!Array.isArray(actions)) {
      this.manipulator.to_after_key_up = [actions];
    } else {
      this.manipulator.to_after_key_up = actions;
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
   * Can accept:
   * - A predefined device group from DEVICE_COMBO
   * - A single device identifier from DEVICE
   * - A raw array of device identifiers
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

type ModifiersKeys =
  | "caps_lock"
  | "left_command"
  | "left_control"
  | "left_option"
  | "left_shift"
  | "right_command"
  | "right_control"
  | "right_option"
  | "right_shift"
  | "fn"
  | "command"
  | "control"
  | "option"
  | "shift"
  | "left_alt"
  | "left_gui"
  | "right_alt"
  | "right_gui"
  | "any";

/**
 * Helper function to create F key layer combinations
 */
export function createFKeyCombo(targetKey: KeyCode, output: To | To[]): Manipulator[] {
  const outputs = Array.isArray(output) ? output : [output];
  const modalVar = "f-mode";

  return [
    // When f-mode is active
    manipulator()
      .fromKey(targetKey)
      .to(outputs)
      .ifVariable(modalVar, 1)
      .build(),

    // Simultaneous press
    manipulator()
      .fromSimultaneous(["f", targetKey], {
        detect_key_down_uninterruptedly: true,
        key_down_order: "strict",
        key_up_order: "strict_inverse",
        key_up_when: "any",
        to_after_key_up: [{ set_variable: { name: modalVar, value: 0 } }]
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
 * Helper function to create J key layer combinations
 */
export function createJKeyCombo(targetKey: KeyCode, output: To | To[]): Manipulator[] {
  const outputs = Array.isArray(output) ? output : [output];
  const modalVar = "j-mode";

  return [
    // When j-mode is active
    manipulator()
      .fromKey(targetKey)
      .to(outputs)
      .ifVariable(modalVar, 1)
      .build(),

    // Simultaneous press
    manipulator()
      .fromSimultaneous(["j", targetKey], {
        detect_key_down_uninterruptedly: true,
        key_down_order: "strict",
        key_up_order: "strict_inverse",
        key_up_when: "any",
        to_after_key_up: [{ set_variable: { name: modalVar, value: 0 } }]
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
 * Helper for creating key combinations that behave differently in terminal vs other apps
 */
export function createAppSpecificJKeyCombo(
  targetKey: KeyCode,
  terminalOutput: To | To[],
  otherAppsOutput: To | To[]
): Manipulator[] {
  return [
    ...createJKeyCombo(targetKey, terminalOutput).map(m => {
      if (!m.conditions) m.conditions = [];
      m.conditions.push(forTerminal());
      return m;
    }),
    ...createJKeyCombo(targetKey, otherAppsOutput).map(m => {
      if (!m.conditions) m.conditions = [];
      m.conditions.push(unlessTerminal());
      return m;
    })
  ];
}