package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
)

// Core data structures
type USBDevice struct {
	Name           string
	Level          int
	Speed          string
	Manufacturer   string
	VendorID       string
	ProductID      string
	PowerRequired  int
	PowerAvailable int
	LocationID     string
	IsBus          bool
	BusDriver      string
}

type DisplayOptions struct {
	Mode     string
	UseColor bool
	UseASCII bool
}

type Summary struct {
	DeviceCount     int
	HubCount        int
	TotalPowerUsed  int
	TotalPowerAvail int
	ProblemCount    int
	SpeedCategories map[string]int
}

// Content structures for unified rendering
type DeviceContent struct {
	Name             string
	Category         string
	HealthIndicators string
	Speed            string
	SpeedCategory    string
	TransferRate     string
	Manufacturer     string
	VendorID         string
	PowerText        string
	PowerUsage       float64
	Location         string
	HasProblems      bool
	HasSpeedProblems bool
	HasPowerProblems bool
	IsHub            bool
	IsBus            bool
	BusDriver        string
	Level            int
	TreePrefix       string
	AttributeIndent  string
}

// Color functions
func colorize(text, color string, useColor bool) string {
	if !useColor {
		return text
	}

	colors := map[string]string{
		"red":     "\033[31m",
		"green":   "\033[32m",
		"yellow":  "\033[33m",
		"blue":    "\033[34m",
		"magenta": "\033[35m",
		"cyan":    "\033[36m",
		"white":   "\033[37m",
		"bold":    "\033[1m",
		"dim":     "\033[2m",
		"reset":   "\033[0m",
	}

	if code, exists := colors[color]; exists {
		return code + text + colors["reset"]
	}
	return text
}

func red(text string, useColor bool) string    { return colorize(text, "red", useColor) }
func green(text string, useColor bool) string  { return colorize(text, "green", useColor) }
func yellow(text string, useColor bool) string { return colorize(text, "yellow", useColor) }
func blue(text string, useColor bool) string   { return colorize(text, "blue", useColor) }
func cyan(text string, useColor bool) string   { return colorize(text, "cyan", useColor) }
func white(text string, useColor bool) string  { return colorize(text, "white", useColor) }
func bold(text string, useColor bool) string   { return colorize(text, "bold", useColor) }
func dim(text string, useColor bool) string    { return colorize(text, "dim", useColor) }

// Vendor database
func getVendorName(vendorID, originalName string) string {
	vendorMap := map[string]string{
		"0x18d1": "Google",
		"0x05ac": "Apple",
		"0x1532": "Razer",
		"0x046d": "Logitech",
		"0x8087": "Intel",
		"0x2188": "CalDigit",
		"0x1a40": "Terminus Tech",
		"0x1a86": "QinHeng Electronics",
		"0x0781": "SanDisk",
		"0x0930": "Toshiba",
		"0x152d": "JMicron",
		"0x174c": "ASMedia",
		"0x1058": "Western Digital",
		"0x04e8": "Samsung",
		"0x0bc2": "Seagate",
	}

	if vendor, exists := vendorMap[strings.ToLower(vendorID)]; exists {
		return vendor
	}
	return originalName
}

// Device to USB standard mapping
func getDeviceMaxUSBStandard(deviceName, vendorID string) string {
	nameLower := strings.ToLower(deviceName)

	// Google Pixel devices (based on common specifications)
	pixelDevices := map[string]string{
		"pixel 9 pro": "USB 3.2", // USB 3.2 Gen 2 (10 Gbps)
		"pixel 9":     "USB 3.2", // USB 3.2 Gen 2 (10 Gbps)
		"pixel 8 pro": "USB 3.2", // USB 3.2 Gen 2 (10 Gbps)
		"pixel 8":     "USB 3.0", // USB 3.0/3.1 Gen 1 (5 Gbps)
		"pixel 7 pro": "USB 3.1", // USB 3.1 Gen 1 (5 Gbps)
		"pixel 7":     "USB 3.0", // USB 3.0 (5 Gbps)
		"pixel 6 pro": "USB 3.1", // USB 3.1 Gen 1 (5 Gbps)
		"pixel 6":     "USB 3.0", // USB 3.0 (5 Gbps)
		"pixel 5":     "USB 3.0", // USB 3.0 (5 Gbps)
		"pixel 4":     "USB 3.0", // USB 3.0 (5 Gbps)
		"pixel 3":     "USB 2.0", // USB 2.0 (480 Mbps)
		"pixel 2":     "USB 2.0", // USB 2.0 (480 Mbps)
	}

	// Check for Pixel devices
	for deviceKey, usbStandard := range pixelDevices {
		if strings.Contains(nameLower, deviceKey) {
			return usbStandard
		}
	}

	// Common device patterns
	if strings.Contains(nameLower, "ssd") || strings.Contains(nameLower, "nvme") {
		return "USB 3.1" // Modern SSDs typically support USB 3.1+
	}
	if strings.Contains(nameLower, "hdd") || strings.Contains(nameLower, "drive") {
		return "USB 3.0" // HDDs typically USB 3.0
	}
	if strings.Contains(nameLower, "mouse") || strings.Contains(nameLower, "keyboard") {
		return "USB 2.0" // Input devices typically USB 2.0
	}

	// Default: assume USB 2.0 for unknown devices
	return "USB 2.0"
}

// USB standard to maximum speed mapping
func getUSBStandardMaxSpeed(standard string) string {
	speedMap := map[string]string{
		"USB 1.0": "1.5 Mb/s",
		"USB 1.1": "12 Mb/s",
		"USB 2.0": "480 Mb/s",
		"USB 3.0": "5 Gb/s",
		"USB 3.1": "10 Gb/s", // USB 3.1 Gen 2
		"USB 3.2": "20 Gb/s", // USB 3.2 Gen 2x2
		"USB4":    "40 Gb/s",
	}

	if speed, exists := speedMap[standard]; exists {
		return speed
	}
	return "Unknown"
}

// Check if device is running at suboptimal speed
func isSpeedSuboptimal(deviceName, vendorID, currentSpeed string) bool {
	maxStandard := getDeviceMaxUSBStandard(deviceName, vendorID)
	currentStandard := categorizeSpeed(currentSpeed)

	// If we can't determine standards, assume it's fine
	if maxStandard == "USB 2.0" || currentStandard == "" {
		return false
	}

	// Compare standards - device should be running at or near its max capability
	standardOrder := map[string]int{
		"USB 1.0": 1,
		"USB 1.1": 2,
		"USB 2.0": 3,
		"USB 3.0": 4,
		"USB 3.1": 5,
		"USB 3.2": 6,
		"USB4":    7,
	}

	maxOrder, maxExists := standardOrder[maxStandard]
	currentOrder, currentExists := standardOrder[currentStandard]

	if !maxExists || !currentExists {
		return false
	}

	// Flag as suboptimal if running more than one standard below capability
	return currentOrder < (maxOrder - 1)
}

// Device categorization
func categorizeDevice(name, vendorID, productID string) string {
	nameLower := strings.ToLower(name)

	categories := map[string][]string{
		"Hub":              {"hub"},
		"Mouse/Trackpad":   {"mouse", "trackpad", "touchpad"},
		"Keyboard":         {"keyboard"},
		"Phone":            {"phone", "pixel", "iphone", "android"},
		"Storage":          {"drive", "disk", "storage", "ssd", "hdd"},
		"Camera":           {"camera", "webcam"},
		"Audio":            {"audio", "speaker", "headphone", "microphone"},
		"Printer":          {"printer"},
		"Adapter":          {"adapter", "dongle"},
		"Composite Device": {"composite"},
	}

	for category, keywords := range categories {
		for _, keyword := range keywords {
			if strings.Contains(nameLower, keyword) {
				return category
			}
		}
	}

	return "Unknown Device"
}

// Speed categorization
func categorizeSpeed(speed string) string {
	speedLower := strings.ToLower(speed)

	if strings.Contains(speedLower, "1.5 mb/s") {
		return "USB 1.0"
	}
	if strings.Contains(speedLower, "12 mb/s") {
		return "USB 1.1"
	}
	if strings.Contains(speedLower, "480 mb/s") {
		return "USB 2.0"
	}
	if strings.Contains(speedLower, "5 gb/s") {
		return "USB 3.0"
	}
	if strings.Contains(speedLower, "10 gb/s") {
		return "USB 3.1"
	}
	if strings.Contains(speedLower, "20 gb/s") {
		return "USB 3.2"
	}
	if strings.Contains(speedLower, "40 gb/s") {
		return "USB4"
	}

	return ""
}

func getTransferRate(speedCategory string) string {
	rates := map[string]string{
		"USB 1.0": "~0.2 MB/s max",
		"USB 1.1": "~1.5 MB/s max",
		"USB 2.0": "~60 MB/s max",
		"USB 3.0": "~625 MB/s max",
		"USB 3.1": "~1.25 GB/s max",
		"USB 3.2": "~2.5 GB/s max",
		"USB4":    "~5 GB/s max",
	}

	return rates[speedCategory]
}

// Problem detection
func hasProblems(device USBDevice) bool {
	// Missing critical info
	if device.Name == "" || device.Speed == "" {
		return true
	}

	// Power problems
	if device.PowerRequired > 0 && device.PowerAvailable > 0 {
		if device.PowerRequired > device.PowerAvailable {
			return true
		}
		usage := float64(device.PowerRequired) / float64(device.PowerAvailable)
		if usage > 0.95 {
			return true
		}
	}

	// Speed problems - device running significantly below capability
	if isSpeedSuboptimal(device.Name, device.VendorID, device.Speed) {
		return true
	}

	return false
}

func hasNonPowerProblems(device USBDevice) bool {
	// Missing critical info
	if device.Name == "" || device.Speed == "" {
		return true
	}

	// Power demand exceeds supply (but not high usage)
	if device.PowerRequired > 0 && device.PowerAvailable > 0 {
		if device.PowerRequired > device.PowerAvailable {
			return true
		}
	}

	// Speed problems - device running significantly below capability
	if isSpeedSuboptimal(device.Name, device.VendorID, device.Speed) {
		return true
	}

	return false
}

func hasPowerProblems(device USBDevice) bool {
	if device.PowerRequired > 0 && device.PowerAvailable > 0 {
		if device.PowerRequired > device.PowerAvailable {
			return true
		}
		usage := float64(device.PowerRequired) / float64(device.PowerAvailable)
		if usage > 0.95 {
			return true
		}
	}
	return false
}

func hasSpeedProblems(device USBDevice) bool {
	return isSpeedSuboptimal(device.Name, device.VendorID, device.Speed)
}

func isHub(name string) bool {
	return strings.HasSuffix(name, "Hub") || strings.HasSuffix(name, "Hub:")
}

// Tree rendering helpers
func getTreePrefix(level int, isLast bool, useASCII bool, treeContinues []bool) string {
	if level == 0 {
		return ""
	}

	var vert, branch, lastBranch string
	if useASCII {
		vert = "|"
		branch = "+-"
		lastBranch = "\\-"
	} else {
		vert = "│"
		branch = "├─"
		lastBranch = "└─"
	}

	prefix := ""
	for i := 1; i < level; i++ {
		if i < len(treeContinues) && treeContinues[i] {
			prefix += vert + "  "
		} else {
			prefix += "   "
		}
	}

	if isLast {
		prefix += lastBranch + " "
		if level < len(treeContinues) {
			treeContinues[level] = false
		}
	} else {
		prefix += branch + " "
		if level < len(treeContinues) {
			treeContinues[level] = true
		}
	}

	return prefix
}

func getAttributeIndent(displayLevel int, isLast bool, useASCII bool, treeContinues []bool) string {
	indent := ""
	vert := "│"
	if useASCII {
		vert = "|"
	}

	for i := 1; i <= displayLevel; i++ {
		if i < displayLevel && i < len(treeContinues) && treeContinues[i] {
			indent += vert + "  "
		} else if i < displayLevel {
			indent += "   "
		} else if !isLast {
			indent += vert + "  "
		} else {
			indent += "   "
		}
	}

	return indent
}

func computeDisplayLevel(rawLevel int) int {
	displayLevel := (rawLevel - 2) / 2
	if displayLevel < 1 {
		displayLevel = 1
	}
	return displayLevel
}

func isLastAtLevel(devices []USBDevice, currentIndex, level int, isBus bool) bool {
	for i := currentIndex + 1; i < len(devices); i++ {
		if devices[i].IsBus && !isBus {
			break
		}

		if isBus {
			if devices[i].IsBus {
				return false
			}
		} else {
			displayLevel := computeDisplayLevel(level)
			nextDisplayLevel := computeDisplayLevel(devices[i].Level)

			if nextDisplayLevel <= displayLevel {
				if nextDisplayLevel == displayLevel {
					return false
				}
				break
			}
		}
	}
	return true
}

// Get the system-specific command to retrieve USB information
// This function centralizes platform and version detection logic
// Future: Add Linux support (lsusb), Windows support (devcon), etc.
func getSystemProfilerCommand() *exec.Cmd {
	// Detect OS - currently only macOS is supported
	// Future: check runtime.GOOS for "linux", "windows", etc.

	// Get macOS version to determine correct command
	versionCmd := exec.Command("sw_vers", "-productVersion")
	output, err := versionCmd.Output()
	if err != nil {
		// Default to older command if we can't detect version
		return exec.Command("system_profiler", "SPUSBDataType")
	}

	version := strings.TrimSpace(string(output))
	parts := strings.Split(version, ".")
	if len(parts) == 0 {
		return exec.Command("system_profiler", "SPUSBDataType")
	}

	// Parse major version
	major, err := strconv.Atoi(parts[0])
	if err != nil {
		return exec.Command("system_profiler", "SPUSBDataType")
	}

	// macOS 26 (Tahoe) and later use SPUSBHostDataType
	// macOS 15 (Sequoia) and earlier use SPUSBDataType
	if major >= 26 {
		return exec.Command("system_profiler", "SPUSBHostDataType")
	}

	// Older versions use SPUSBDataType
	return exec.Command("system_profiler", "SPUSBDataType")
}

// Parse system_profiler output
func runSystemCommand() ([]USBDevice, error) {
	cmd := getSystemProfilerCommand()
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to run system_profiler: %v", err)
	}

	var devices []USBDevice
	var currentDevice USBDevice
	var currentBusDriver string

	scanner := bufio.NewScanner(strings.NewReader(string(output)))

	for scanner.Scan() {
		line := strings.TrimRight(scanner.Text(), "\r\n")

		// Skip empty lines and USB: header
		if line == "" || line == "USB:" {
			continue
		}

		// Calculate indentation level
		level := 0
		for i, char := range line {
			if char != ' ' {
				level = i / 2
				line = strings.TrimSpace(line)
				break
			}
		}

		// Bus detection
		busRegex := regexp.MustCompile(`^USB \d+\.\d+ Bus:?$`)
		if busRegex.MatchString(line) {
			if currentDevice.Name != "" {
				devices = append(devices, currentDevice)
			}

			currentDevice = USBDevice{
				Name:      strings.TrimSuffix(line, ":"),
				Level:     level,
				IsBus:     true,
				BusDriver: "", // Driver will be set by subsequent "Host Controller Driver:" or "Driver:" line
			}
			currentBusDriver = ""
			continue
		}

		// Host Controller Driver (old format) or Driver (new format)
		if strings.HasPrefix(line, "Host Controller Driver:") || strings.HasPrefix(line, "Driver:") {
			parts := strings.SplitN(line, ":", 2)
			if len(parts) == 2 {
				currentBusDriver = strings.TrimSpace(parts[1])
				currentDevice.BusDriver = currentBusDriver
			}
			continue
		}

		// Device name (ends with colon)
		if strings.HasSuffix(line, ":") {
			if currentDevice.Name != "" {
				devices = append(devices, currentDevice)
			}

			currentDevice = USBDevice{
				Name:  strings.TrimSuffix(line, ":"),
				Level: level,
			}
			continue
		}

		// Device attributes
		if strings.Contains(line, ":") {
			parts := strings.SplitN(line, ":", 2)
			if len(parts) != 2 {
				continue
			}

			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])

			switch key {
			// Speed - handles both old "Speed:" and new "Link Speed:" formats
			case "Speed", "Link Speed":
				currentDevice.Speed = value
			case "Manufacturer":
				currentDevice.Manufacturer = value
			// Vendor ID - handles both old "Vendor ID:" and new "USB Vendor ID:" formats
			// Old format: "0x05ac (Apple Inc.)" - extract just the hex code
			// New format: "0x05ac" - already clean
			case "Vendor ID", "USB Vendor ID":
				// Extract just the hex code, ignoring any vendor name in parentheses
				if matches := regexp.MustCompile(`(0x[0-9a-fA-F]+)`).FindStringSubmatch(value); len(matches) > 0 {
					currentDevice.VendorID = strings.ToLower(matches[1])
				} else {
					currentDevice.VendorID = value
				}
			// Product ID - handles both old "Product ID:" and new "USB Product ID:" formats
			// Same extraction logic as Vendor ID
			case "Product ID", "USB Product ID":
				if matches := regexp.MustCompile(`(0x[0-9a-fA-F]+)`).FindStringSubmatch(value); len(matches) > 0 {
					currentDevice.ProductID = strings.ToLower(matches[1])
				} else {
					currentDevice.ProductID = value
				}
			// Old power format: "Current Required (mA):"
			case "Current Required (mA)":
				if val, err := strconv.Atoi(regexp.MustCompile(`\d+`).FindString(value)); err == nil {
					currentDevice.PowerRequired = val
				}
			// Old power format: "Current Available (mA):"
			case "Current Available (mA)":
				if val, err := strconv.Atoi(regexp.MustCompile(`\d+`).FindString(value)); err == nil {
					currentDevice.PowerAvailable = val
				}
			// New power format: "Power Allocated: 2.5 W (500 mA)"
			case "Power Allocated":
				// Extract mA value from format like "2.5 W (500 mA)"
				if matches := regexp.MustCompile(`\((\d+)\s*mA\)`).FindStringSubmatch(value); len(matches) > 1 {
					if val, err := strconv.Atoi(matches[1]); err == nil {
						currentDevice.PowerRequired = val
					}
				}
			// New power format: "Power Sink Capability: 12 W (2400 mA)"
			case "Power Sink Capability":
				// Extract mA value from format like "12 W (2400 mA)"
				if matches := regexp.MustCompile(`\((\d+)\s*mA\)`).FindStringSubmatch(value); len(matches) > 1 {
					if val, err := strconv.Atoi(matches[1]); err == nil {
						currentDevice.PowerAvailable = val
					}
				}
			case "Location ID":
				currentDevice.LocationID = value
			}
		}
	}

	// Don't forget the last device
	if currentDevice.Name != "" {
		devices = append(devices, currentDevice)
	}

	return devices, nil
}

// Generate unified content for all devices
func generateDeviceContent(devices []USBDevice, opts DisplayOptions) []DeviceContent {
	var content []DeviceContent
	treeContinues := make([]bool, 20)

	for i, device := range devices {
		// Skip problem filtering - show all devices in unified content
		if device.Name == "" {
			continue
		}

		isLast := isLastAtLevel(devices, i, device.Level, device.IsBus)

		if device.IsBus {
			content = append(content, generateBusContent(device, opts))
		} else {
			content = append(content, generateSingleDeviceContent(device, isLast, opts, treeContinues))
		}
	}

	return content
}

func generateBusContent(device USBDevice, opts DisplayOptions) DeviceContent {
	return DeviceContent{
		Name:      device.Name,
		BusDriver: device.BusDriver,
		IsBus:     true,
		Level:     device.Level,
	}
}

func generateSingleDeviceContent(device USBDevice, isLast bool, opts DisplayOptions, treeContinues []bool) DeviceContent {
	displayLevel := computeDisplayLevel(device.Level)
	prefix := getTreePrefix(displayLevel, isLast, opts.UseASCII, treeContinues)
	attrIndent := getAttributeIndent(displayLevel, isLast, opts.UseASCII, treeContinues)

	// Generate all content regardless of mode
	category := ""
	healthIndicators := ""

	if !isHub(device.Name) {
		category = categorizeDevice(device.Name, device.VendorID, device.ProductID)

		// Add slow speed indicator for legacy speeds
		speedCat := categorizeSpeed(device.Speed)
		if speedCat == "USB 1.0" || speedCat == "USB 1.1" || speedCat == "USB 2.0" {
			healthIndicators += " *"
		}

		// Keep only the legacy speed indicator and generic non-speed/power problems
		if hasNonPowerProblems(device) && !hasSpeedProblems(device) && !hasPowerProblems(device) {
			healthIndicators += " [Problem]"
		}
	}

	// Generate power text
	var powerText string
	var powerUsage float64
	if device.PowerRequired > 0 && device.PowerAvailable > 0 {
		powerUsage = float64(device.PowerRequired) / float64(device.PowerAvailable) * 100
		powerText = fmt.Sprintf("Power: %dmA/%dmA [%.1f%%]", device.PowerRequired, device.PowerAvailable, powerUsage)
	}

	// Generate speed text
	speedCat := categorizeSpeed(device.Speed)
	speedText := ""
	if device.Speed != "" {
		speedText = fmt.Sprintf("Speed: %s", device.Speed)
		if speedCat != "" {
			speedText += fmt.Sprintf(" [%s]", speedCat)
		}

		// Add theoretical max speed for devices we specifically know about
		maxStandard := getDeviceMaxUSBStandard(device.Name, device.VendorID)
		// Show theoretical max for known devices or when there's a speed mismatch
		shouldShowMax := false

		// Always show for known Pixel devices and other specific devices
		nameLower := strings.ToLower(device.Name)
		if strings.Contains(nameLower, "pixel") || strings.Contains(nameLower, "ssd") || strings.Contains(nameLower, "nvme") {
			shouldShowMax = true
		}

		// Also show when device capability exceeds current speed (speed problem)
		if maxStandard != "USB 2.0" && isSpeedSuboptimal(device.Name, device.VendorID, device.Speed) {
			shouldShowMax = true
		}

		if shouldShowMax {
			maxSpeed := getUSBStandardMaxSpeed(maxStandard)
			if maxSpeed != "Unknown" {
				speedText += fmt.Sprintf(" (max: %s)", maxSpeed)
			}
		}
	}

	transferRate := getTransferRate(speedCat)

	return DeviceContent{
		Name:             device.Name,
		Category:         category,
		HealthIndicators: healthIndicators,
		Speed:            speedText,
		SpeedCategory:    speedCat,
		TransferRate:     transferRate,
		Manufacturer:     device.Manufacturer,
		VendorID:         device.VendorID,
		PowerText:        powerText,
		PowerUsage:       powerUsage,
		Location:         device.LocationID,
		HasProblems:      hasProblems(device),
		HasSpeedProblems: hasSpeedProblems(device),
		HasPowerProblems: hasPowerProblems(device),
		IsHub:            isHub(device.Name),
		IsBus:            false,
		Level:            device.Level,
		TreePrefix:       prefix,
		AttributeIndent:  attrIndent,
	}
}

// Mode-specific color application
func applyModeColors(content DeviceContent, mode string, useColor bool) {
	if content.IsBus {
		renderBusWithColors(content, mode, useColor)
		return
	}

	// Device name line
	displayName := content.Name
	if content.IsHub {
		displayName = bold(content.Name, useColor)
	} else if content.Category != "" && !strings.Contains(content.Category, "Unknown") {
		displayName = content.Category + " " + bold(content.Name, useColor)
	} else {
		displayName = bold(content.Name, useColor)
	}

	// Always show hub and device names in white, generic problems in red
	if content.HasProblems && strings.Contains(content.HealthIndicators, "[Problem]") {
		healthPart := strings.Replace(content.HealthIndicators, "[Problem]", red("[Problem]", useColor), 1)
		displayName = white(displayName, useColor) + healthPart
	} else {
		displayName = white(displayName+content.HealthIndicators, useColor)
	}

	fmt.Println(content.TreePrefix + displayName)

	// Render attributes with mode-specific coloring
	renderAttributesWithColors(content, mode, useColor)
}

func renderBusWithColors(content DeviceContent, mode string, useColor bool) {
	busName := content.Name
	if content.BusDriver != "" {
		busName += " [" + content.BusDriver + "]"
	}

	// Always show bus names in white
	fmt.Println(white(busName, useColor))
}

func renderAttributesWithColors(content DeviceContent, mode string, useColor bool) {
	indent := content.AttributeIndent

	// Speed information
	if content.Speed != "" {
		switch mode {
		case "speed":
			// Color speed info based on category, dim transfer rate
			line := content.Speed
			if content.TransferRate != "" {
				line += " " + dim(content.TransferRate, useColor)
			}

			// Apply speed-based coloring
			switch content.SpeedCategory {
			case "USB 1.0", "USB 1.1":
				line = red(line, useColor)
			case "USB 2.0":
				line = yellow(line, useColor)
			case "USB 3.0", "USB 3.1":
				line = green(line, useColor)
			case "USB 3.2", "USB4":
				line = cyan(line, useColor)
			default:
				line = dim(line, useColor)
			}
			fmt.Printf("%s%s\n", indent, line)
		case "default":
			// Show speed problems in red for default mode, otherwise dim
			line := content.Speed
			if content.TransferRate != "" {
				line += " " + content.TransferRate
			}

			if content.HasSpeedProblems {
				fmt.Printf("%s%s\n", indent, red(line, useColor))
			} else {
				fmt.Printf("%s%s\n", indent, dim(line, useColor))
			}
		default:
			// Other modes: always dim speed info (no problem highlighting)
			line := content.Speed
			if content.TransferRate != "" {
				line += " " + content.TransferRate
			}
			fmt.Printf("%s%s\n", indent, dim(line, useColor))
		}
	}

	// Manufacturer and Vendor ID
	if content.Manufacturer != "" {
		fmt.Printf("%s%s %s\n", indent, dim("Manufacturer:", useColor), dim(content.Manufacturer, useColor))
	}
	if content.VendorID != "" {
		fmt.Printf("%s%s %s\n", indent, dim("Vendor ID:", useColor), dim(content.VendorID, useColor))
	}

	// Power information
	if content.PowerText != "" {
		switch mode {
		case "power":
			// Color power info based on usage, dim percentage
			mainPart := fmt.Sprintf("Power: %dmA/%dmA",
				extractPowerRequired(content.PowerText),
				extractPowerAvailable(content.PowerText))
			percentPart := fmt.Sprintf(" [%.1f%%]", content.PowerUsage)

			// Apply coloring to main part, then add dimmed percentage
			var line string
			if content.PowerUsage > 90 {
				line = red(mainPart, useColor) + dim(percentPart, useColor)
			} else if content.PowerUsage > 50 {
				line = yellow(mainPart, useColor) + dim(percentPart, useColor)
			} else {
				line = green(mainPart, useColor) + dim(percentPart, useColor)
			}

			fmt.Printf("%s%s\n", indent, line)
		case "default":
			// Show power problems in red for default mode, otherwise dim
			if content.HasPowerProblems {
				fmt.Printf("%s%s\n", indent, red(content.PowerText, useColor))
			} else {
				fmt.Printf("%s%s\n", indent, dim(content.PowerText, useColor))
			}
		default:
			// Other modes: always dim power info (no problem highlighting)
			fmt.Printf("%s%s\n", indent, dim(content.PowerText, useColor))
		}
	}

	// Location information
	if content.Location != "" {
		switch mode {
		case "location":
			fmt.Printf("%s%s %s\n", indent, dim("Location:", useColor), white(content.Location, useColor))
		default:
			fmt.Printf("%s%s %s\n", indent, dim("Location:", useColor), dim(content.Location, useColor))
		}
	}
}

// Helper functions to extract power values from formatted text
func extractPowerRequired(powerText string) int {
	re := regexp.MustCompile(`(\d+)mA/`)
	matches := re.FindStringSubmatch(powerText)
	if len(matches) > 1 {
		if val, err := strconv.Atoi(matches[1]); err == nil {
			return val
		}
	}
	return 0
}

func extractPowerAvailable(powerText string) int {
	re := regexp.MustCompile(`/(\d+)mA`)
	matches := re.FindStringSubmatch(powerText)
	if len(matches) > 1 {
		if val, err := strconv.Atoi(matches[1]); err == nil {
			return val
		}
	}
	return 0
}

// Calculate summary statistics
func calculateSummary(devices []USBDevice) Summary {
	summary := Summary{
		SpeedCategories: make(map[string]int),
	}

	for _, device := range devices {
		if device.IsBus {
			continue
		}

		summary.DeviceCount++

		if isHub(device.Name) {
			summary.HubCount++
		}

		if device.PowerRequired > 0 {
			summary.TotalPowerUsed += device.PowerRequired
		}
		if device.PowerAvailable > 0 {
			summary.TotalPowerAvail += device.PowerAvailable
		}

		if device.Speed != "" {
			speedCat := categorizeSpeed(device.Speed)
			if speedCat != "" {
				summary.SpeedCategories[speedCat]++
			}
		}

		if hasProblems(device) {
			summary.ProblemCount++
		}
	}

	return summary
}

func renderSummary(summary Summary, mode string, useColor bool) {
	fmt.Println()

	switch mode {
	case "summary":
		// Only show basic stats and problem count for summary mode
		fmt.Printf("Total Devices: %d (excluding hubs)\n", summary.DeviceCount-summary.HubCount)
		fmt.Printf("Hubs: %d\n", summary.HubCount)
		fmt.Println()
		if summary.ProblemCount == 0 {
			fmt.Println(green("No USB problems detected!", useColor))
		} else {
			fmt.Printf("%s %d device(s) with problems\n", red("Found", useColor), summary.ProblemCount)
		}
	case "power":
		// Show power legend
		renderPowerLegend(useColor)
	case "speed":
		// Show speed legend
		renderSpeedLegend(useColor)
	}
}

func renderPowerLegend(useColor bool) {
	fmt.Println(blue("Power Legend:", useColor))
	fmt.Printf("  %s - Low usage, efficient\n", green("< 50%", useColor))
	fmt.Printf("  %s - Moderate usage, monitor\n", yellow("> 50%", useColor))
	fmt.Printf("  %s - High usage, may cause issues\n", red("> 90%", useColor))
}

func renderSpeedLegend(useColor bool) {
	fmt.Println(blue("Speed Legend:", useColor))
	fmt.Printf("  %s - Very slow, legacy devices\n", red("USB 1.0/1.1", useColor))
	fmt.Printf("  %s - Slower, older devices\n", yellow("USB 2.0", useColor))
	fmt.Printf("  %s - Fast, modern devices\n", green("USB 3.0/3.1", useColor))
	fmt.Printf("  %s - Very fast, latest devices\n", cyan("USB 3.2/USB4", useColor))
}

func printHelp() {
	fmt.Println(`Usage: usbi [MODE]
Modes:
  default:    Enhanced info with categories, vendor names, and health indicators
  --raw:      Raw system_profiler output with normalized whitespace (auto-detects SPUSBDataType/SPUSBHostDataType)
  --speed:    Speed-focused tree with actual values [category speed]
  --power:    Power-focused tree with usage warnings [req/avail mA]
  --problems: Show only devices with issues (power, speed, driver problems)
  --location: Show location info along with manufacturer details
  --summary:  Port utilization, power totals, device counts
  --no-color: Disable colored output

Color thresholds (power): red >90%, yellow >50%, green otherwise`)
}

func main() {
	opts := DisplayOptions{
		Mode:     "default",
		UseColor: true,
		UseASCII: false,
	}

	// Parse command line arguments
	for _, arg := range os.Args[1:] {
		switch arg {
		case "--raw":
			opts.Mode = "raw"
		case "--speed":
			opts.Mode = "speed"
		case "--power":
			opts.Mode = "power"
		case "--problems":
			opts.Mode = "problems"
		case "--location":
			opts.Mode = "location"
		case "--summary":
			opts.Mode = "summary"
		case "--no-color":
			opts.UseColor = false
		case "--help", "-h":
			printHelp()
			return
		}
	}

	// Disable colors if output is not to a terminal
	if opts.UseColor {
		if fileInfo, _ := os.Stdout.Stat(); (fileInfo.Mode() & os.ModeCharDevice) == 0 {
			opts.UseColor = false
		}
	}

	// Handle raw mode separately (mimics original bash behavior)
	if opts.Mode == "raw" {
		cmd := getSystemProfilerCommand()
		output, err := cmd.Output()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error running system_profiler: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("USB:")
		scanner := bufio.NewScanner(strings.NewReader(string(output)))
		for scanner.Scan() {
			line := strings.TrimRight(scanner.Text(), "\r\n")
			if line == "" {
				fmt.Println()
				continue
			}
			if line == "USB:" {
				continue
			}

			// Calculate and preserve indentation
			spaces := 0
			for i, char := range line {
				if char != ' ' {
					spaces = i
					break
				}
			}
			level := spaces / 2
			indent := strings.Repeat("  ", level)

			fmt.Printf("%s%s\n", indent, strings.TrimSpace(line))
		}
		return
	}

	// Parse USB devices
	devices, err := runSystemCommand()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing USB data: %v\n", err)
		os.Exit(1)
	}

	// Filter for problems mode only
	if opts.Mode == "problems" {
		var filteredDevices []USBDevice
		for _, device := range devices {
			if device.IsBus || hasProblems(device) {
				filteredDevices = append(filteredDevices, device)
			}
		}
		devices = filteredDevices
	}

	// Generate unified content
	content := generateDeviceContent(devices, opts)
	summary := calculateSummary(devices)

	// Render devices with mode-specific colors
	fmt.Println()
	for _, deviceContent := range content {
		applyModeColors(deviceContent, opts.Mode, opts.UseColor)
	}

	// Render summary only for specific modes
	if opts.Mode == "speed" || opts.Mode == "power" || opts.Mode == "summary" {
		renderSummary(summary, opts.Mode, opts.UseColor)
	}
}
