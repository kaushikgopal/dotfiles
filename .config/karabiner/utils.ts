import { To, KeyCode, Manipulator, KarabinerRules } from "./types";

/**
 * Custom way to describe a command in a layer
 */
export interface LayerCommand {
  to: To[];
  description?: string;
}

type HyperKeySublayer = {
  // The ? is necessary, otherwise we'd have to define something for _every_ key code
  [key_code in KeyCode]?: LayerCommand;
};

/**
 * Create a Hyper Key sublayer, where every command is prefixed with a key
 * e.g. Hyper + O ("Open") is the "open applications" layer, I can press
 * e.g. Hyper + O + G ("Google Chrome") to open Chrome
 */
export function createHyperSubLayer(
  sublayer_key: KeyCode,
  commands: HyperKeySublayer,
  allSubLayerVariables: string[]
): Manipulator[] {
  const subLayerVariableName = generateSubLayerVariableName(sublayer_key);

  return [
    // When Hyper + sublayer_key is pressed, set the variable to 1; on key_up, set it to 0 again
    {
      description: `Toggle Hyper sublayer ${sublayer_key}`,
      type: "basic",
      from: {
        key_code: sublayer_key,
        modifiers: {
          optional: ["any"],
        },
      },
      to_after_key_up: [
        {
          set_variable: {
            name: subLayerVariableName,
            // The default value of a variable is 0: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/variable/
            // That means by using 0 and 1 we can filter for "0" in the conditions below and it'll work on startup
            value: 0,
          },
        },
      ],
      to: [
        {
          set_variable: {
            name: subLayerVariableName,
            value: 1,
          },
        },
      ],
      // This enables us to press other sublayer keys in the current sublayer
      // (e.g. Hyper + O > M even though Hyper + M is also a sublayer)
      // basically, only trigger a sublayer if no other sublayer is active
      conditions: [
        ...allSubLayerVariables
          .filter(
            (subLayerVariable) => subLayerVariable !== subLayerVariableName
          )
          .map((subLayerVariable) => ({
            type: "variable_if" as const,
            name: subLayerVariable,
            value: 0,
          })),
        {
          type: "variable_if",
          name: "hyper",
          value: 1,
        },
      ],
    },
    // Define the individual commands that are meant to trigger in the sublayer
    ...(Object.keys(commands) as (keyof typeof commands)[]).map(
      (command_key): Manipulator => ({
        ...commands[command_key],
        type: "basic" as const,
        from: {
          key_code: command_key,
          modifiers: {
            optional: ["any"],
          },
        },
        // Only trigger this command if the variable is 1 (i.e., if Hyper + sublayer is held)
        conditions: [
          {
            type: "variable_if",
            name: subLayerVariableName,
            value: 1,
          },
        ],
      })
    ),
  ];
}

/**
 * Create all hyper sublayers. This needs to be a single function, as well need to
 * have all the hyper variable names in order to filter them and make sure only one
 * activates at a time
 */
export function createHyperSubLayers(subLayers: {
  [key_code in KeyCode]?: HyperKeySublayer | LayerCommand;
}): KarabinerRules[] {
  const allSubLayerVariables = (
    Object.keys(subLayers) as (keyof typeof subLayers)[]
  ).map((sublayer_key) => generateSubLayerVariableName(sublayer_key));

  return Object.entries(subLayers).map(([key, value]) =>
    "to" in value
      ? {
          description: `Hyper Key + ${key}`,
          manipulators: [
            {
              ...value,
              type: "basic" as const,
              from: {
                key_code: key as KeyCode,
                modifiers: {
                  optional: ["any"],
                },
              },
              conditions: [
                {
                  type: "variable_if",
                  name: "hyper",
                  value: 1,
                },
                ...allSubLayerVariables.map((subLayerVariable) => ({
                  type: "variable_if" as const,
                  name: subLayerVariable,
                  value: 0,
                })),
              ],
            },
          ],
        }
      : {
          description: `Hyper Key sublayer "${key}"`,
          manipulators: createHyperSubLayer(
            key as KeyCode,
            value,
            allSubLayerVariables
          ),
        }
  );
}

function generateSubLayerVariableName(key: KeyCode) {
  return `hyper_sublayer_${key}`;
}

/**
 * Shortcut for "open" shell command
 */
export function open(...what: string[]): LayerCommand {
  return {
    to: what.map((w) => ({
      shell_command: `open ${w}`,
    })),
    description: `Open ${what.join(" & ")}`,
  };
}

/**
 * Utility function to create a LayerCommand from a tagged template literal
 * where each line is a shell command to be executed.
 */
export function shell(
  strings: TemplateStringsArray,
  ...values: any[]
): LayerCommand {
  const commands = strings.reduce((acc, str, i) => {
    const value = i < values.length ? values[i] : "";
    const lines = (str + value)
      .split("\n")
      .filter((line) => line.trim() !== "");
    acc.push(...lines);
    return acc;
  }, [] as string[]);

  return {
    to: commands.map((command) => ({
      shell_command: command.trim(),
    })),
    description: commands.join(" && "),
  };
}

/**
 * Shortcut for managing window sizing with Rectangle
 */
export function rectangle(name: string): LayerCommand {
  return {
    to: [
      {
        shell_command: `open -g rectangle://execute-action?name=${name}`,
      },
    ],
    description: `Window: ${name}`,
  };
}

/**
 * Shortcut for "Open an app" command (of which there are a bunch)
 */
export function app(name: string): LayerCommand {
  return open(`-a '${name}.app'`);
}

/**
 * Creates a key combination layer with a more elegant syntax
 * @param trigger The trigger key that starts the combo
 * @param combos Object mapping target keys to their outputs
 */
export type ModifierKey =
  | "left_command" | "left_control" | "left_option" | "left_shift"
  | "right_command" | "right_control" | "right_option" | "right_shift";

export type KeyComboDefinition = {
  [key: string]: {
    output: KeyCode | number;
    modifiers?: ModifierKey[];
  } | [KeyCode | number, ModifierKey[]?];
};

export function createKeyLayerCombo(trigger: KeyCode, combos: KeyComboDefinition): Manipulator[] {
  return Object.entries(combos).map(([key, value]) => {
    // Handle both object and array formats
    let output: { key_code: KeyCode; modifiers?: ModifierKey[] };

    if (Array.isArray(value)) {
      // Array format: [output, modifiers?]
      const [outputValue, modifiers] = value;
      output = {
        key_code: String(outputValue) as KeyCode,
        ...(modifiers && { modifiers }),
      };
    } else if (typeof value === 'object') {
      // Object format: { output, modifiers? }
      output = {
        key_code: String(value.output) as KeyCode,
        ...(value.modifiers && { modifiers: value.modifiers }),
      };
    } else {
      throw new Error('Invalid combo definition');
    }

    return {
      type: "basic" as const,
      from: {
        key_code: trigger,
        modifiers: {
          mandatory: [key] as ModifierKey[],
        },
      },
      to: [output],
    };
  });
}

/**
 * Creates a key combination layer using simultaneous key presses and variable mode
 * @param trigger The trigger key that starts the combo
 * @param combos Object mapping target keys to their outputs
 */
export type SimultaneousKeyComboDefinition = {
  [key: string]: {
    key_code: KeyCode;
    modifiers?: ModifierKey[];
  };
};

export function createSimultaneousKeyCombo(trigger: KeyCode, combos: SimultaneousKeyComboDefinition): Manipulator[] {
  const variableName = `${trigger}-mode`;
  const manipulators: Manipulator[] = [];

  // Add individual key handlers when in the mode
  Object.entries(combos).forEach(([key, output]) => {
    manipulators.push({
      type: "basic",
      from: {
        key_code: key as KeyCode,
      },
      to: [output],
      conditions: [
        {
          type: "variable_if",
          name: variableName,
          value: 1,
        },
      ],
    });

    // Add simultaneous key press handlers
    manipulators.push({
      type: "basic",
      from: {
        simultaneous: [
          { key_code: trigger },
          { key_code: key as KeyCode },
        ],
        simultaneous_options: {
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
        },
      },
      to: [
        {
          set_variable: {
            name: variableName,
            value: 1,
          },
        },
        output,
      ],
      parameters: {
        "basic.simultaneous_threshold_milliseconds": 250,
      },
    });
  });

  return manipulators;
}
