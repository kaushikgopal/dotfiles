package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"sort"
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

	return false
}

func hasNonPowerProblems(device USBDevice) bool {
	// Missing critical info
	if device.Name == "" || device.Speed == "" {
		return true
	}

	// Power demand exceeds supply
	if device.PowerRequired > 0 && device.PowerAvailable > 0 {
		if device.PowerRequired > device.PowerAvailable {
			return true
		}
	}

	return false
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

// Parse system_profiler output
func macosUSBCommand() ([]USBDevice, error) {
	cmd := exec.Command("system_profiler", "SPUSBDataType")
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
				BusDriver: currentBusDriver,
			}
			currentBusDriver = ""
			continue
		}

		// Host Controller Driver
		if strings.HasPrefix(line, "Host Controller Driver:") {
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
			case "Speed":
				currentDevice.Speed = value
			case "Manufacturer":
				currentDevice.Manufacturer = value
			case "Vendor ID":
				currentDevice.VendorID = value
			case "Product ID":
				currentDevice.ProductID = value
			case "Current Required (mA)":
				if val, err := strconv.Atoi(regexp.MustCompile(`\d+`).FindString(value)); err == nil {
					currentDevice.PowerRequired = val
				}
			case "Current Available (mA)":
				if val, err := strconv.Atoi(regexp.MustCompile(`\d+`).FindString(value)); err == nil {
					currentDevice.PowerAvailable = val
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

// Rendering functions
func renderDevices(devices []USBDevice, opts DisplayOptions) {
	treeContinues := make([]bool, 20)

	for i, device := range devices {
		// Skip filtered devices based on mode
		if shouldSkipDevice(device, opts.Mode) {
			continue
		}

		// Determine if this is the last device at this level
		isLast := isLastAtLevel(devices, i, device.Level, device.IsBus)

		if device.IsBus {
			renderBus(device, opts)
		} else {
			renderDevice(device, isLast, opts, treeContinues)
		}
	}
}

func shouldSkipDevice(device USBDevice, mode string) bool {
	switch mode {
	case "problems":
		return !device.IsBus && !hasProblems(device)
	default:
		return false
	}
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

func computeDisplayLevel(rawLevel int) int {
	displayLevel := (rawLevel - 2) / 2
	if displayLevel < 1 {
		displayLevel = 1
	}
	return displayLevel
}

func renderBus(device USBDevice, opts DisplayOptions) {
	busName := blue(device.Name, opts.UseColor)
	if device.BusDriver != "" {
		busName += " [" + cyan(device.BusDriver, opts.UseColor) + "]"
	}
	fmt.Println(busName)
}

func renderDevice(device USBDevice, isLast bool, opts DisplayOptions, treeContinues []bool) {
	displayLevel := computeDisplayLevel(device.Level)
	prefix := getTreePrefix(displayLevel, isLast, opts.UseASCII, treeContinues)

	// Enhanced manufacturer info (used in problem detection)
	_ = getVendorName(device.VendorID, device.Manufacturer)

	// Device category and health indicators
	category := ""
	healthIndicators := ""

	if !isHub(device.Name) {
		category = categorizeDevice(device.Name, device.VendorID, device.ProductID)

		// Add slow speed indicator
		speedCat := categorizeSpeed(device.Speed)
		if opts.Mode != "power" && (speedCat == "USB 1.0" || speedCat == "USB 1.1" || speedCat == "USB 2.0") {
			healthIndicators += " *"
		}

		// Add problem marker for non-power problems
		if (opts.Mode == "problems" || opts.Mode == "default") && hasNonPowerProblems(device) {
			healthIndicators += " " + red("[Problem]", opts.UseColor)
		}
	}

	// Build display name
	displayName := device.Name
	if isHub(device.Name) {
		displayName = bold(device.Name, opts.UseColor)
	} else if category != "" && !strings.Contains(category, "Unknown") {
		displayName = category + " " + bold(device.Name, opts.UseColor)
	} else {
		displayName = bold(device.Name, opts.UseColor)
	}

	if healthIndicators != "" {
		displayName += healthIndicators
	}

	fmt.Println(prefix + displayName)

	// Render attributes
	attrIndent := getAttributeIndent(displayLevel, isLast, opts.UseASCII, treeContinues)
	renderDeviceAttributes(device, attrIndent, opts)
}

func renderDeviceAttributes(device USBDevice, indent string, opts DisplayOptions) {
	// Speed information
	if device.Speed != "" && opts.Mode != "power" && opts.Mode != "location" {
		speedCat := categorizeSpeed(device.Speed)
		transferRate := getTransferRate(speedCat)

		// Build the main part of the line without transfer rate
		mainLine := fmt.Sprintf("%s %s", "Speed:", device.Speed)
		if speedCat != "" {
			mainLine += fmt.Sprintf(" [%s]", speedCat)
		}

		// Color the main line based on speed category
		var colorFunc func(string, bool) string
		if speedCat != "" {
			switch speedCat {
			case "USB 1.0", "USB 1.1":
				colorFunc = red
			case "USB 2.0":
				colorFunc = yellow
			case "USB 3.0", "USB 3.1":
				colorFunc = green
			case "USB 3.2", "USB4":
				colorFunc = cyan
			}
			mainLine = colorFunc(mainLine, opts.UseColor)
		}

		// Add transfer rate in dimmed color if available
		if transferRate != "" {
			mainLine += " " + dim(transferRate, opts.UseColor)
		}

		fmt.Printf("%s%s\n", indent, mainLine)
	}

	// Manufacturer and Vendor ID
	if opts.Mode == "default" {
		if device.Manufacturer != "" {
			fmt.Printf("%s%s %s\n", indent, dim("Manufacturer:", opts.UseColor), device.Manufacturer)
		}
		if device.VendorID != "" {
			fmt.Printf("%s%s %s\n", indent, dim("Vendor ID:", opts.UseColor), device.VendorID)
		}
	} else {
		if device.VendorID != "" {
			fmt.Printf("%s%s %s\n", indent, dim("Vendor ID:", opts.UseColor), device.VendorID)
		}
	}

	// Power information
	if device.PowerRequired > 0 && device.PowerAvailable > 0 &&
		opts.Mode != "speed" && opts.Mode != "location" {
		usage := float64(device.PowerRequired) / float64(device.PowerAvailable) * 100
		
		// Build main power text without percentage
		mainPowerText := fmt.Sprintf("Power: %dmA/%dmA", device.PowerRequired, device.PowerAvailable)
		percentageText := fmt.Sprintf(" [%.1f%%]", usage)

		// Color the main power text based on usage
		var colorFunc func(string, bool) string
		if usage > 90 {
			colorFunc = red
		} else if usage > 50 {
			colorFunc = yellow
		} else {
			colorFunc = green
		}
		
		mainPowerText = colorFunc(mainPowerText, opts.UseColor)
		
		// Add dimmed percentage
		mainPowerText += dim(percentageText, opts.UseColor)

		fmt.Printf("%s%s\n", indent, mainPowerText)
	}

	// Location information (only in location mode)
	if device.LocationID != "" && opts.Mode == "location" {
		fmt.Printf("%s%s %s\n", indent, dim("Location:", opts.UseColor), dim(device.LocationID, opts.UseColor))
	}
}

func renderPowerSummary(summary Summary, useColor bool) {
	fmt.Println(blue("Power:", useColor))

	usagePct := float64(0)
	if summary.TotalPowerAvail > 0 {
		usagePct = float64(summary.TotalPowerUsed) / float64(summary.TotalPowerAvail) * 100
	}

	totalText := fmt.Sprintf("%dmA used / %dmA available [%.1f%%]",
		summary.TotalPowerUsed, summary.TotalPowerAvail, usagePct)

	if usagePct > 90 {
		totalText = red(totalText, useColor)
	} else if usagePct > 50 {
		totalText = yellow(totalText, useColor)
	} else {
		totalText = green(totalText, useColor)
	}

	fmt.Printf("  %-10s %s\n", "Total", totalText)
	fmt.Printf("                %s\n", green("< 50%", useColor))
	fmt.Printf("                %s\n", yellow("> 50%", useColor))
	fmt.Printf("                %s\n", red("> 90%", useColor))
}

func renderSpeedSummary(summary Summary, useColor bool) {
	fmt.Println(blue("Speed:", useColor))

	// Sort speed categories for consistent output
	var categories []string
	for cat := range summary.SpeedCategories {
		if summary.SpeedCategories[cat] > 0 {
			categories = append(categories, cat)
		}
	}
	sort.Strings(categories)

	speedInfo := map[string]struct {
		speed string
		color func(string, bool) string
	}{
		"USB 1.0": {"1.5 Mb/s", red},
		"USB 1.1": {"12 Mb/s", red},
		"USB 2.0": {"480 Mb/s", yellow},
		"USB 3.0": {"5 Gb/s", green},
		"USB 3.1": {"10 Gb/s", green},
		"USB 3.2": {"20 Gb/s", cyan},
		"USB4":    {"40 Gb/s", cyan},
	}

	for _, cat := range categories {
		info := speedInfo[cat]
		count := summary.SpeedCategories[cat]
		bracket := fmt.Sprintf("[%s]", cat)

		fmt.Printf("  %s %10s %14s %3d devices\n",
			info.color(bracket, useColor),
			info.speed,
			fmt.Sprintf("(%s)", cat),
			count)
	}
}

func printHelp() {
	fmt.Println(`Usage: usbi [MODE]
Modes:
  default:    Enhanced info with categories, vendor names, and health indicators
  --raw:      Raw system_profiler output with normalized whitespace
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
		cmd := exec.Command("system_profiler", "SPUSBDataType")
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
	devices, err := macosUSBCommand()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing USB data: %v\n", err)
		os.Exit(1)
	}

	summary := calculateSummary(devices)

	// Render based on mode
	if opts.Mode != "summary" {
		fmt.Println()
		renderDevices(devices, opts)
	}

	// Add mode-specific summaries
	switch opts.Mode {
	case "summary":
		fmt.Println()
		fmt.Println(blue("USB Summary:", opts.UseColor))
		fmt.Println("============")
		fmt.Printf("Total Devices: %d (excluding hubs)\n", summary.DeviceCount-summary.HubCount)
		fmt.Printf("Hubs: %d\n", summary.HubCount)
		fmt.Println()
		renderPowerSummary(summary, opts.UseColor)
		fmt.Println()
		renderSpeedSummary(summary, opts.UseColor)

	case "speed":
		fmt.Println()
		renderSpeedSummary(summary, opts.UseColor)

	case "power":
		fmt.Println()
		renderPowerSummary(summary, opts.UseColor)

	case "problems":
		fmt.Println()
		if summary.ProblemCount == 0 {
			fmt.Println(green("No USB problems detected!", opts.UseColor))
		} else {
			fmt.Printf("%s %d device(s) with problems\n",
				red("Found", opts.UseColor), summary.ProblemCount)
		}

	case "default":
		fmt.Println()
		renderPowerSummary(summary, opts.UseColor)
		fmt.Println()
		renderSpeedSummary(summary, opts.UseColor)
	}
}
