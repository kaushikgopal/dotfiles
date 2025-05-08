// Define individual device identifiers
export const DEVICE = {
  // Apple devices
  APPLE_BUILT_IN: { is_built_in_keyboard: true },
  APPLE: { vendor_id: 1452 },
  KEYCHRON: { vendor_id: 76 },

  // Other keyboards
  ANNE_PRO2: { vendor_id: 1241, product_id: 41618 },
  MS_SCULPT: { vendor_id: 1118, product_id: 1957 },
  TADA68: { vendor_id: 65261, product_id: 4611 },
  KINESIS: { vendor_id: 10730 },
  LOGITECH_G915: { vendor_id: 1133 },

  // Specific Logitech devices from original code
  LOGITECH_DEVICE: {
    is_keyboard: true,
    is_pointing_device: true,
    product_id: 45919,
    vendor_id: 1133
  },
  POINTING_DEVICE: {
    is_pointing_device: true
  },
  LOGITECH_IGNORED: {
    is_keyboard: true,
    product_id: 50475,
    vendor_id: 1133
  }
};

// Define device combinations that reference the individual identifiers
export const DEVICE_COMBO = {
  // Device groups
  APPLE_ALL: [
    DEVICE.APPLE,
    DEVICE.KEYCHRON,
    DEVICE.APPLE_BUILT_IN
  ],

  ALL_KEYBOARDS: [
    DEVICE.APPLE,
    DEVICE.KEYCHRON,
    DEVICE.APPLE_BUILT_IN,
    DEVICE.ANNE_PRO2,
    DEVICE.MS_SCULPT,
    DEVICE.TADA68,
    DEVICE.KINESIS,
    DEVICE.LOGITECH_G915
  ],

  ALL_EXCEPT_KINESIS: [
    DEVICE.APPLE,
    DEVICE.KEYCHRON,
    DEVICE.APPLE_BUILT_IN,
    DEVICE.ANNE_PRO2,
    DEVICE.MS_SCULPT,
    DEVICE.TADA68,
    DEVICE.LOGITECH_G915
  ]
};

// Device configurations for Karabiner
export const DEVICE_CONFIGS = [
  {
    identifiers: DEVICE.LOGITECH_DEVICE,
    ignore: false,
    manipulate_caps_lock_led: false,
  },
  {
    identifiers: DEVICE.POINTING_DEVICE,
    simple_modifications: [
      {
        from: { key_code: "right_command" },
        to: [{ key_code: "right_control" }],
      },
    ],
  },
  {
    identifiers: DEVICE.LOGITECH_IGNORED,
    ignore: true,
  },
];
