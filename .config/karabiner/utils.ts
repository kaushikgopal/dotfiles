import { To, KeyCode, Manipulator, KarabinerRules, Conditions } from "./types";
import type { ModifiersKeys } from "./types";

/**
 * Custom way to describe a command in a layer
 */
export interface LayerCommand {
  to: To[];
  description?: string;
}

/**
 * Create a Hyper Key sublayer, where every command is prefixed with a key
 * e.g. Hyper + O ("Open") is the "open applications" layer, I can press
 * e.g. Hyper + O + G ("Google Chrome") to open Chrome
 */
function createHyperSubLayer(
  sublayer_key: KeyCode,
  commands: { [key_code in KeyCode]?: LayerCommand },
  allSubLayerVariables: string[]
): Manipulator[] {
  const subLayerVariableName = `hyper_sublayer_${sublayer_key}`;

  return [
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
      conditions: [
        ...allSubLayerVariables
          .filter((subLayerVariable) => subLayerVariable !== subLayerVariableName)
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
  [key_code in KeyCode]?: { [key_code in KeyCode]?: LayerCommand } | LayerCommand;
}): KarabinerRules[] {
  const allSubLayerVariables = (
    Object.keys(subLayers) as (keyof typeof subLayers)[]
  ).map((sublayer_key) => `hyper_sublayer_${sublayer_key}`);

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
function shell(
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
 * Creates a key combination layer with configurable behavior.
 * When a trigger key is provided, useSimultaneous and variableMode are automatically set to true.
 * @param trigger The trigger key
 * @param combos The key combinations to create
 * @param options Optional configuration:
 *   - conditions: Additional conditions to apply
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
    // Base from configuration
    const baseFrom = {
      key_code: key as KeyCode,
    };

    // Base to configuration
    const baseTo = [output];

    // Add mode-based handler
    manipulators.push({
      type: "basic",
      from: baseFrom,
      to: baseTo,
      conditions: [
        {
          type: "variable_if",
          name: variableName,
          value: 1,
        },
        ...conditions,
      ],
    });

    // Add simultaneous handler
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
      conditions,
    });
  });

  return manipulators;
}
