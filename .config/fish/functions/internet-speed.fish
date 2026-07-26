function internet-speed --description 'Test and summarize internet quality'
    for tool in gum jq networkQuality
        if not type -q $tool
            echo "internet-speed: required command not found: $tool" >&2
            return 1
        end
    end

    set -l limit 15
    set -l started (date +%s)
    set -l json (gum spin --spinner pulse --title "Testing internet connection (up to $limit seconds)…" --show-stdout -- networkQuality -M $limit -c | string collect)
    set -l elapsed (math (date +%s) - $started)

    if not printf '%s' "$json" | jq -e . >/dev/null 2>&1
        gum style --foreground 196 --bold 'The network test did not return valid results.'
        return 1
    end

    set -l metrics (printf '%s' "$json" | jq -r '[(((.dl_throughput / 1000000) * 10 | round) / 10), (((.dl_throughput / 8000000) * 10 | round) / 10), (((.ul_throughput / 1000000) * 10 | round) / 10), (((.ul_throughput / 8000000) * 10 | round) / 10), ((.base_rtt * 10 | round) / 10), ((.responsiveness * 10 | round) / 10), .interface_name] | .[]')

    if test (count $metrics) -ne 7
        gum style --foreground 196 --bold 'The network test returned incomplete results.'
        return 1
    end

    set -l interface $metrics[7]
    set -l ssid
    if type -q ipconfig
        set ssid (command ipconfig getsummary "$interface" 2>/dev/null | command awk '/^[[:space:]]*SSID[[:space:]]*:/{sub(/^[^:]*:[[:space:]]*/, ""); print; exit}')
        set ssid (string replace -ar '[[:cntrl:]]' '' -- "$ssid")
    end

    set -l connection_text "Interface: $interface"
    if test -n "$ssid"; and not string match -qr '^<(unknown|redacted)>$' -- "$ssid"
        set connection_text "Wi-Fi: $ssid · Interface: $interface"
    end

    set -l rpm_rating Low
    set -l rpm_whole (math "floor($metrics[6])")
    if test $rpm_whole -ge 600
        set rpm_rating High
    else if test $rpm_whole -ge 200
        set rpm_rating Medium
    end

    echo
    set -l duration "$elapsed"s
    gum style --bold 'Network quality'
    gum style --faint "$connection_text · Test: $duration"
    echo
    printf '%s\n' \
        "Download,$metrics[1] Mbps,$metrics[2] MB/s file speed" \
        "Upload,$metrics[3] Mbps,$metrics[4] MB/s file speed" \
        "Latency,$metrics[5] ms,Reply delay while quiet · lower is better" \
        "Responsiveness,$metrics[6] RPM,$rpm_rating · response while busy · higher is better" \
        | gum table --print --columns 'Metric,Result,Meaning' --widths 18,14,44 --border rounded
end
