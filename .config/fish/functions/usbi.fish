function usbi --description "Trimmed USB info from system_profiler"
set -l mode "default"
for arg in $argv
    switch $arg
    case --full
        set mode "full"
    case --speed
        set mode "speed"
    case --power
        set mode "power"
    case --problems
        set mode "problems"
    case --storage
        set mode "storage"
    case --summary
        set mode "summary"
    case --json
        set mode "json"
    case --help -h
        echo "Usage: usbi [MODE]"
        echo "Modes:"
        echo "  default:    Enhanced info with categories, vendor names, and health indicators"
        echo "  --full:     Complete system_profiler output with normalized whitespace"
        echo "  --speed:    Speed-focused tree with actual values [category speed]"
        echo "  --power:    Power-focused tree with usage warnings [req/avail mA]"
        echo "  --problems: Show only devices with issues (power, speed, driver problems)"
        echo "  --storage:  Focus on storage devices with detailed info"
        echo "  --summary:  Port utilization, power totals, device counts"
        echo "  --json:     Machine-readable JSON output for scripting"
        echo ""
        echo "Health Indicators:"
        echo "  🔴 Critical power usage (>95% of available)"
        echo "  🟡 High power usage (>80% of available)"
        echo "  ❌ Problem device (missing info or errors)"
        return 0
    case ""
    # ignore unknowns for now
    end
end
if test $mode = "full"
    # Use the same awk parsing logic but output everything with proper indentation
    system_profiler SPUSBDataType | awk '
        function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
        function indent(n){ s=""; for(i=0;i<n;i++) s=s "  "; return s }
        
        BEGIN { print "USB:" }
        
        {
            # Parse indentation
            sp = 0
            while (substr($0, sp+1, 1) == " ") sp++
            curr_level = int(sp/2)
            
            line = $0
            gsub(/\r/,"",line)
            line = trim(line)
            
            if (line == "") {
                print ""
                next
            }
            if (line == "USB:") next
            
            # Print with proper hierarchical indentation
            print indent(curr_level) line
        }
    '
    return $status
end

# Helper: categorize speed -> short tag
function __usb_cat_speed
    set -l s (string lower -- $argv[1])
    if string match -rq '1\\.5 *mb/s' -- $s
        echo "[low]"
    else if string match -rq '^up to *1\\.5 *mb/s' -- $s
        echo "[low]"
    else if string match -rq '12 *mb/s' -- $s
        echo "[full]"
    else if string match -rq '480 *mb/s' -- $s
        echo "[high]"
    else if string match -rq '5 *gb/s' -- $s
        echo "[ss]"
    else if string match -rq '10 *gb/s' -- $s
        echo "[ss+]"
    else if string match -rq '20 *gb/s' -- $s
        echo "[ss20]"
    else if string match -rq '40 *gb/s' -- $s
        echo "[ss40]"
    else
        echo "[]"
    end
end

# Parse system_profiler and emit the desired formats.
# We’ll use awk for structured parsing and formatting.
system_profiler SPUSBDataType | awk -v MODE="$mode" '
    function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
    function indent(n){ s=""; for(i=0;i<n;i++) s=s "  "; return s }

    # Enhanced vendor database
    function get_vendor_name(vid, orig_name) {
        vid = tolower(vid)
        if (vid ~ /0x18d1/) return "Google"
        if (vid ~ /0x05ac/) return "Apple"
        if (vid ~ /0x1532/) return "Razer"
        if (vid ~ /0x046d/) return "Logitech"
        if (vid ~ /0x8087/) return "Intel"
        if (vid ~ /0x2188/) return "CalDigit"
        if (vid ~ /0x1a40/) return "Terminus Tech"
        if (vid ~ /0x1a86/) return "QinHeng Electronics"
        if (vid ~ /0x0781/) return "SanDisk"
        if (vid ~ /0x0930/) return "Toshiba"
        if (vid ~ /0x152d/) return "JMicron"
        if (vid ~ /0x174c/) return "ASMedia"
        if (vid ~ /0x1058/) return "Western Digital"
        if (vid ~ /0x04e8/) return "Samsung"
        if (vid ~ /0x0bc2/) return "Seagate"
        return orig_name  # fallback to original
    }

    # Device categorization
    function categorize_device(name, vid, pid) {
        name_lower = tolower(name)
        if (name_lower ~ /hub/) return "🔌 Hub"
        if (name_lower ~ /mouse|trackpad|touchpad/) return "🖱️  Mouse/Trackpad"
        if (name_lower ~ /keyboard/) return "⌨️  Keyboard"
        if (name_lower ~ /phone|pixel|iphone|android/) return "📱 Phone"
        if (name_lower ~ /drive|disk|storage|ssd|hdd/) return "💾 Storage"
        if (name_lower ~ /camera|webcam/) return "📷 Camera"
        if (name_lower ~ /audio|speaker|headphone|microphone/) return "🎵 Audio"
        if (name_lower ~ /printer/) return "🖨️  Printer"
        if (name_lower ~ /adapter|dongle/) return "🔌 Adapter"
        if (name_lower ~ /composite/) return "🔧 Composite Device"
        return "❓ Unknown Device"
    }

    # Health indicator functions
    function get_power_indicator(req, avail) {
        if (req == "" || avail == "" || avail == 0) return ""
        usage = (req / avail) * 100
        if (usage > 95) return "🔴"
        if (usage > 80) return "🟡"
        return ""
    }

    function has_problems(name, speed, manuf, curr_req, curr_avail, vid, location) {
        # Missing critical info
        if (name == "" || speed == "") return 1
        # Power problems
        if (curr_req != "" && curr_avail != "" && curr_req > curr_avail) return 1
        # Very high power usage
        if (curr_req != "" && curr_avail != "" && (curr_req/curr_avail) > 0.95) return 1
        return 0
    }

    function has_non_power_problems(name, speed, manuf, curr_req, curr_avail, vid, location) {
        # Missing critical info
        if (name == "" || speed == "") return 1
        # Power demand exceeds supply (different from high usage)
        if (curr_req != "" && curr_avail != "" && curr_req > curr_avail) return 1
        # Could add other non-power issues here like speed mismatches, driver issues, etc.
        return 0
    }
    function cat_speed(spd,   lspd){
        lspd=tolower(spd)
        if (lspd ~ /1\.5 *mb\/s/) return "[low]"
        if (lspd ~ /12 *mb\/s/)  return "[full]"
        if (lspd ~ /480 *mb\/s/) return "[high]"
        if (lspd ~ /5 *gb\/s/)   return "[ss]"
        if (lspd ~ /10 *gb\/s/)  return "[ss+]"
        if (lspd ~ /20 *gb\/s/)  return "[ss20]"
        if (lspd ~ /40 *gb\/s/)  return "[ss40]"
        return "[]"
    }
    function is_hub(name){
        return (name ~ /Hub:?$/ || name ~ / Hub:?$/)
    }
    function flush_device(){
        if (dev_name == "") return

        # Increment counters
        if (!is_bus) {
            device_count++
            if (is_hub(dev_name)) hub_count++
            if (dev_curr_req != "") total_power_used += dev_curr_req
            if (dev_curr_avail != "") total_power_available += dev_curr_avail

            speed_cat = cat_speed(dev_speed)
            gsub(/\[|\]/, "", speed_cat)  # Remove brackets
            if (speed_cat != "") speed_categories[speed_cat]++

            if (has_problems(dev_name, dev_speed, dev_manuf, dev_curr_req, dev_curr_avail, dev_vid, dev_location)) {
                problem_count++
            }
        }

        # Determine slow mark: non-hub and category [low] or [full]
        slow_mark = ""
        if (!is_hub(dev_name)) {
            if (cat_speed(dev_speed) == "[low]" || cat_speed(dev_speed) == "[full]") slow_mark=" *"
        }
        spcat = (dev_speed != "" ? cat_speed(dev_speed) : "")
        if (MODE == "default") {
            if (is_bus) {
                if (bus_driver != "") print indent(level) dev_name " [" bus_driver "]"
                else print indent(level) dev_name
            } else {
                # Enhanced vendor info
                enhanced_manuf = dev_manuf
                if (dev_vid != "" && dev_manuf != "") {
                    enhanced_vendor = get_vendor_name(dev_vid, dev_manuf)
                    if (enhanced_vendor != dev_manuf) {
                        enhanced_manuf = enhanced_vendor
                    }
                }

                # Get device category and health indicators
                category = ""
                health_indicators = ""

                if (!is_hub(dev_name)) {
                    category = categorize_device(dev_name, dev_vid, dev_pid)

                    # Power health indicator
                    power_indicator = get_power_indicator(dev_curr_req, dev_curr_avail)
                    if (power_indicator != "") health_indicators = health_indicators " " power_indicator

                    # Add slow mark for non-hubs
                    if (cat_speed(dev_speed) == "[low]" || cat_speed(dev_speed) == "[full]") {
                        health_indicators = health_indicators " *"
                    }
                }

                # Enhanced device display with category and health indicators
                display_name = dev_name
                if (category != "" && category !~ /Unknown/) {
                    display_name = category " " dev_name
                }
                if (health_indicators != "") {
                    display_name = display_name health_indicators
                }

                print indent(level) display_name

                # Speed line with category
                if (dev_speed != "") {
                    printf "%s%-14s %s %s\n", indent(level+1), "Speed:", dev_speed, spcat
                }
                # Enhanced manufacturer info
                if (enhanced_manuf != "") printf "%s%-14s %s\n", indent(level+1), "Manufacturer:", enhanced_manuf
                # Enhanced power info with percentage
                if (dev_curr_req != "" && dev_curr_avail != "") {
                    usage = (dev_curr_req / dev_curr_avail) * 100
                    printf "%s%-14s %dmA / %dmA (%.1f%%)\n", indent(level+1), "Power:", dev_curr_req, dev_curr_avail, usage
                }
                # Location info
                if (dev_location != "") printf "%s%-14s %s\n", indent(level+1), "Location:", dev_location
            }
        } else if (MODE == "speed") {
            # Speed-focused mode - same format as default but only show speed info
            if (is_bus) {
                if (bus_driver != "") print indent(level) dev_name " [" bus_driver "]"
                else print indent(level) dev_name
            } else {
                # Enhanced vendor info (same as default)
                enhanced_manuf = dev_manuf
                if (dev_vid != "" && dev_manuf != "") {
                    enhanced_vendor = get_vendor_name(dev_vid, dev_manuf)
                    if (enhanced_vendor != dev_manuf) {
                        enhanced_manuf = enhanced_vendor
                    }
                }
                
                # Get device category (same as default)
                category = ""
                if (!is_hub(dev_name)) {
                    category = categorize_device(dev_name, dev_vid, dev_pid)
                }
                
                # Enhanced device display (same as default)
                display_name = dev_name
                if (category != "" && category !~ /Unknown/) {
                    display_name = category " " dev_name
                }
                
                print indent(level) display_name
                
                # Only show speed line (simplified)
                if (dev_speed != "") {
                    printf "%s%-14s %s %s\n", indent(level+1), "Speed:", dev_speed, spcat
                }
            }
        } else if (MODE == "power") {
            # Power-focused output
            if (is_bus) {
                # For bus nodes, show driver inline
                if (bus_driver != "") print indent(level) dev_name " [" bus_driver "]"
                else print indent(level) dev_name
            } else {
                # For devices and hubs, show power info with indicators
                power_info = ""
                power_indicator = get_power_indicator(dev_curr_req, dev_curr_avail)
                if (dev_curr_req != "" && dev_curr_avail != "") {
                    usage = (dev_curr_req / dev_curr_avail) * 100
                    power_info = " [" dev_curr_req "/" dev_curr_avail "mA " sprintf("%.0f%%", usage) "]"
                    if (power_indicator != "") power_info = power_info " " power_indicator
                } else if (dev_curr_req != "") {
                    power_info = " [" dev_curr_req "mA req]"
                } else if (dev_curr_avail != "") {
                    power_info = " [" dev_curr_avail "mA avail]"
                }
                print indent(level) dev_name power_info
            }
        } else if (MODE == "problems") {
            # Problems mode - only show devices with issues
            if (is_bus) {
                if (bus_driver != "") print indent(level) dev_name " [" bus_driver "]"
                else print indent(level) dev_name
            } else if (has_problems(dev_name, dev_speed, dev_manuf, dev_curr_req, dev_curr_avail, dev_vid, dev_location)) {
                # Enhanced vendor info
                enhanced_manuf = dev_manuf
                if (dev_vid != "" && dev_manuf != "") {
                    enhanced_vendor = get_vendor_name(dev_vid, dev_manuf)
                    if (enhanced_vendor != dev_manuf) {
                        enhanced_manuf = enhanced_vendor
                    }
                }

                category = categorize_device(dev_name, dev_vid, dev_pid)
                health_indicators = ""
                power_indicator = get_power_indicator(dev_curr_req, dev_curr_avail)
                if (power_indicator != "") health_indicators = health_indicators " " power_indicator

                # Only add ❌ for non-power problems (missing info, power demand > supply, etc.)
                if (has_non_power_problems(dev_name, dev_speed, enhanced_manuf, dev_curr_req, dev_curr_avail, dev_vid, dev_location)) {
                    health_indicators = health_indicators " ❌"
                }

                display_name = dev_name
                if (category != "" && category !~ /Unknown/) {
                    display_name = category " " dev_name
                }
                display_name = display_name health_indicators

                print indent(level) display_name
                if (dev_speed != "") printf "%s%-14s %s %s\n", indent(level+1), "Speed:", dev_speed, cat_speed(dev_speed)
                if (enhanced_manuf != "") printf "%s%-14s %s\n", indent(level+1), "Manufacturer:", enhanced_manuf
                if (dev_curr_req != "" && dev_curr_avail != "") {
                    usage = (dev_curr_req / dev_curr_avail) * 100
                    printf "%s%-14s %dmA / %dmA (%.1f%%)\n", indent(level+1), "Power:", dev_curr_req, dev_curr_avail, usage
                }
                if (dev_location != "") printf "%s%-14s %s\n", indent(level+1), "Location:", dev_location
            }
        } else if (MODE == "storage") {
            # Storage mode - focus on storage devices
            if (is_bus) {
                if (bus_driver != "") print indent(level) dev_name " [" bus_driver "]"
                else print indent(level) dev_name
            } else if (categorize_device(dev_name, dev_vid, dev_pid) ~ /💾 Storage/ || dev_name ~ /drive|disk|storage|ssd|hdd/i) {
                category = categorize_device(dev_name, dev_vid, dev_pid)
                health_indicators = ""
                power_indicator = get_power_indicator(dev_curr_req, dev_curr_avail)
                if (power_indicator != "") health_indicators = health_indicators " " power_indicator

                print indent(level) category " " dev_name health_indicators
                if (dev_speed != "") {
                    speed_cat = cat_speed(dev_speed)
                    gsub(/\[|\]/, "", speed_cat)  # Remove brackets
                    printf "%s%-14s %s [%s]\n", indent(level+1), "Speed:", dev_speed, speed_cat
                    # Estimate transfer rates
                    if (speed_cat == "high") printf "%s%-14s ~60 MB/s max\n", indent(level+1), "Transfer Rate:"
                    else if (speed_cat == "ss") printf "%s%-14s ~625 MB/s max\n", indent(level+1), "Transfer Rate:"
                    else if (speed_cat == "ss+") printf "%s%-14s ~1.25 GB/s max\n", indent(level+1), "Transfer Rate:"
                }

                enhanced_manuf = dev_manuf
                if (dev_vid != "" && dev_manuf != "") {
                    enhanced_vendor = get_vendor_name(dev_vid, dev_manuf)
                    if (enhanced_vendor != dev_manuf) {
                        enhanced_manuf = enhanced_vendor
                    }
                }
                if (enhanced_manuf != "") printf "%s%-14s %s\n", indent(level+1), "Manufacturer:", enhanced_manuf
                if (dev_curr_req != "" && dev_curr_avail != "") {
                    usage = (dev_curr_req / dev_curr_avail) * 100
                    printf "%s%-14s %dmA / %dmA (%.1f%%)\n", indent(level+1), "Power:", dev_curr_req, dev_curr_avail, usage
                }
                if (dev_location != "") printf "%s%-14s %s\n", indent(level+1), "Location:", dev_location
            }
        } else if (MODE == "json" && !is_bus) {
            # JSON output for devices only (not buses)
            if (!json_first) print ","
            json_first = 0

            enhanced_manuf = dev_manuf
            if (dev_vid != "" && dev_manuf != "") {
                enhanced_vendor = get_vendor_name(dev_vid, dev_manuf)
                if (enhanced_vendor != dev_manuf) {
                    enhanced_manuf = enhanced_vendor
                }
            }
            category = categorize_device(dev_name, dev_vid, dev_pid)

            print "    {"
            print "      \"name\": \"" dev_name "\","
            print "      \"category\": \"" category "\","
            print "      \"speed\": \"" dev_speed "\","
            speed_cat = cat_speed(dev_speed); gsub(/\[|\]/, "", speed_cat)
            print "      \"speed_category\": \"" speed_cat "\","
            print "      \"manufacturer\": \"" enhanced_manuf "\","
            print "      \"vendor_id\": \"" dev_vid "\","
            print "      \"product_id\": \"" dev_pid "\","
            print "      \"location_id\": \"" dev_location "\","
            print "      \"power_required\": " (dev_curr_req != "" ? dev_curr_req : "null") ","
            print "      \"power_available\": " (dev_curr_avail != "" ? dev_curr_avail : "null") ","
            print "      \"has_problems\": " (has_problems(dev_name, dev_speed, enhanced_manuf, dev_curr_req, dev_curr_avail, dev_vid, dev_location) ? "true" : "false") ","
            print "      \"level\": " level
            printf "    }"
        }
        # reset fields for next device
        dev_name=""; dev_speed=""; dev_manuf=""; dev_curr_req=""; dev_curr_avail=""; dev_location=""; dev_vid=""; dev_pid=""; is_bus=0; bus_driver=""
    }
    BEGIN{
        level=0; in_usb_root=0
        # Global counters for summary
        device_count = 0
        hub_count = 0
        total_power_used = 0
        total_power_available = 0
        problem_count = 0
        speed_categories["low"] = 0
        speed_categories["full"] = 0
        speed_categories["high"] = 0
        speed_categories["ss"] = 0
        speed_categories["ss+"] = 0
        speed_categories["ss20"] = 0
        speed_categories["ss40"] = 0

        if (MODE == "json") {
            print "{"
            print "  \"usb_devices\": ["
            json_first = 1
        } else if (MODE != "summary") {
            print "USB:"
        }
    }
    {
        # Keep original indentation width (2 spaces per nesting in SP output is typical but can vary).
        # Determine the indent level based on leading spaces divided by 2, but clamp non-negative.
        sp = 0
        while (substr($0, sp+1, 1) == " ") sp++
        curr_level = int(sp/2)

        line = $0
        gsub(/\r/,"",line)
        line = trim(line)

        # Blank lines just flush if needed (no-op here)
        if (line == "") next

        # USB root header
        if (line == "USB:") {
            # Already printed our own USB: header once
            next
        }

        # Detect Bus line with optional colon and handle driver info
        if (line ~ /^USB [0-9]+\.[0-9]+ Bus(:)?$/) {
            flush_device()
            level = curr_level
            dev_name = line; sub(/:$/,"",dev_name)
            is_bus=1
            next
        }

        # Host Controller Driver: for last seen bus
        if (line ~ /^Host Controller Driver:/) {
            split(line, a, ":"); bus_driver = trim(a[2])
            next
        }

        # Device name lines end with a colon in SP; keep name without colon
        if (line ~ /:$/) {
            flush_device()
            level = curr_level
            dev_name = line; sub(/:$/,"",dev_name)
            next
        }

        # Collect fields for current device
        if (line ~ /^Speed:/) {
            dev_speed = trim(substr(line, index(line,":")+1))
            next
        }
        if (line ~ /^Manufacturer:/) {
            dev_manuf = trim(substr(line, index(line,":")+1))
            next
        }
        if (line ~ /^Vendor ID:/) {
            dev_vid = trim(substr(line, index(line,":")+1))
            next
        }
        if (line ~ /^Product ID:/) {
            dev_pid = trim(substr(line, index(line,":")+1))
            next
        }
        if (line ~ /^Current Required \(mA\):/) {
            v = trim(substr(line, index(line,":")+1)); gsub(/[^0-9]/,"",v); dev_curr_req = v
            next
        }
        if (line ~ /^Current Available \(mA\):/) {
            v = trim(substr(line, index(line,":")+1)); gsub(/[^0-9]/,"",v); dev_curr_avail = v
            next
        }
        if (line ~ /^Location ID:/) {
            dev_location = trim(substr(line, index(line,":")+1))
            next
        }

        # On any other field, ignore in default/speed modes
    }
    END{
        flush_device()

        # Summary mode
        if (MODE == "summary") {
            print "USB Summary:"
            print "============"
            printf "Total Devices: %d (excluding hubs)\n", device_count - hub_count
            printf "Hubs: %d\n", hub_count
            print ""
            printf "Power Usage: %dmA used / %dmA available", total_power_used, total_power_available
            if (total_power_available > 0) {
                printf " (%.1f%%)\n", (total_power_used / total_power_available) * 100
            } else {
                print ""
            }
            print ""
            print "Speed Distribution:"
            if (speed_categories["low"] > 0) printf "  USB 1.0 (1.5 Mb/s):   %d devices\n", speed_categories["low"]
            if (speed_categories["full"] > 0) printf "  USB 1.1 (12 Mb/s):    %d devices\n", speed_categories["full"]
            if (speed_categories["high"] > 0) printf "  USB 2.0 (480 Mb/s):   %d devices\n", speed_categories["high"]
            if (speed_categories["ss"] > 0) printf "  USB 3.0 (5 Gb/s):     %d devices\n", speed_categories["ss"]
            if (speed_categories["ss+"] > 0) printf "  USB 3.1 (10 Gb/s):    %d devices\n", speed_categories["ss+"]
            if (speed_categories["ss20"] > 0) printf "  USB 3.2 (20 Gb/s):    %d devices\n", speed_categories["ss20"]
            if (speed_categories["ss40"] > 0) printf "  USB4 (40 Gb/s):       %d devices\n", speed_categories["ss40"]
        }
        else if (MODE == "speed") {
            print ""
            print "Speed Legend:"
            print "  [low]:  1.5 Mb/s   (USB 1.0 - very old mice, basic devices)"
            print "  [full]: 12 Mb/s    (USB 1.1 - keyboards, basic mice)"
            print "  [high]: 480 Mb/s   (USB 2.0 - most phones, drives, common devices)"
            print "  [ss]:   5 Gb/s     (USB 3.0 - fast external drives)"
            print "  [ss+]:  10 Gb/s    (USB 3.1 - very fast drives, hubs)"
            print "  [ss20]: 20 Gb/s    (USB 3.2 - high-end drives)"
            print "  [ss40]: 40 Gb/s    (USB4/Thunderbolt - fastest possible)"
        } else if (MODE == "power") {
            print ""
            print "Power Info:"
            print "  Format: [required/available mA percentage] - how much power device needs vs provides"
            print "  <80% = Normal usage 🟢"
            print "  >80% = High usage 🟡"
            print "  >95% = Critical usage 🔴"
            print "  Common values: 100mA (mice), 500mA (phones/drives), 900mA+ (fast charging/hubs)"
        } else if (MODE == "problems") {
            print ""
            if (problem_count == 0) {
                print "✅ No USB problems detected!"
            } else {
                printf "Found %d device(s) with problems\n", problem_count
                print "🔴 = Critical power usage (>95%)"
                print "🟡 = High power usage (>80%)"
                print "❌ = Missing info or errors"
            }
        } else if (MODE == "storage") {
            print ""
            print "Storage Device Legend:"
            print "  Transfer rates are theoretical maximums"
            print "  Actual speeds depend on device and data type"
            print "  USB 2.0: ~60 MB/s max"
            print "  USB 3.0: ~625 MB/s max"
            print "  USB 3.1+: ~1.25+ GB/s max"
        } else if (MODE == "json") {
            print ""
            print "  ],"
            printf "  \"summary\": {\n"
            printf "    \"total_devices\": %d,\n", device_count - hub_count
            printf "    \"hubs\": %d,\n", hub_count
            printf "    \"problems\": %d,\n", problem_count
            printf "    \"power_used\": %d,\n", total_power_used
            printf "    \"power_available\": %d\n", total_power_available
            printf "  }\n"
            print "}"
        }
    }
'
end
