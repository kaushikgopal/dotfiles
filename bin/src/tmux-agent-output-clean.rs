use std::io::{self, BufRead, Write};

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let stdout = io::stdout();
    let mut out = stdout.lock();

    let mut prev_line: Option<String> = None;
    let mut empty_count = 0;

    for raw_line in stdin.lock().lines() {
        let line = raw_line?;
        let cleaned = clean_line(&line);

        // Skip lines that become empty after cleaning
        if cleaned.is_empty() {
            empty_count += 1;
            continue;
        }

        // Emit a single blank line if we had a run of empties
        if empty_count > 0 {
            if prev_line.is_some() {
                writeln!(out)?;
            }
            empty_count = 0;
        }

        // Collapse consecutive duplicate lines
        if let Some(ref prev) = prev_line {
            if prev == &cleaned {
                continue;
            }
        }

        writeln!(out, "{cleaned}")?;
        prev_line = Some(cleaned);
    }

    out.flush()?;
    Ok(())
}

fn clean_line(line: &str) -> String {
    let mut s = line.to_string();

    // Order matters: strip escapes first, then patterns, then normalize
    s = strip_ansi_escapes(&s);
    s = strip_terminal_control(&s);
    s = strip_invisible_unicode(&s);
    s = strip_box_drawing(&s);
    s = strip_progress_indicators(&s);
    s = strip_timestamp_timing(&s);
    s = strip_truncation_markers(&s);
    s = strip_claude_code(&s);
    s = strip_codex(&s);
    s = strip_gemini(&s);
    s = normalize_whitespace(&s);

    s
}

/// Strip ANSI color/style escape sequences
fn strip_ansi_escapes(s: &str) -> String {
    let mut result = String::with_capacity(s.len());
    let mut chars = s.chars().peekable();

    while let Some(c) = chars.next() {
        if c == '\x1b' {
            // ESC sequence
            if let Some(&next) = chars.peek() {
                if next == '[' {
                    chars.next(); // consume '['
                    // Consume until we hit a letter (the terminator)
                    while let Some(&ch) = chars.peek() {
                        chars.next();
                        if ch.is_ascii_alphabetic() || ch == '~' || ch == '@' {
                            break;
                        }
                    }
                    continue;
                } else if next == ']' {
                    // OSC sequence (e.g., title setting) - consume until BEL or ST
                    chars.next();
                    while let Some(ch) = chars.next() {
                        if ch == '\x07' {
                            break;
                        }
                        if ch == '\x1b' {
                            if let Some(&'\\') = chars.peek() {
                                chars.next();
                                break;
                            }
                        }
                    }
                    continue;
                } else if next == '(' || next == ')' {
                    // Character set designation
                    chars.next();
                    chars.next(); // consume the charset identifier
                    continue;
                } else if next == '=' || next == '>' {
                    // Keypad mode
                    chars.next();
                    continue;
                }
            }
            continue; // Skip bare ESC
        }
        result.push(c);
    }

    result
}

/// Strip terminal control characters and sequences
fn strip_terminal_control(s: &str) -> String {
    let mut result = String::with_capacity(s.len());

    for c in s.chars() {
        match c {
            // Control characters to strip
            '\x00'..='\x08' | '\x0b'..='\x0c' | '\x0e'..='\x1a' | '\x1c'..='\x1f' | '\x7f' => {}
            // Keep normal chars, tabs, newlines, carriage returns
            _ => result.push(c),
        }
    }

    // Strip carriage returns (often from terminal redraws)
    result.replace('\r', "")
}

/// Strip zero-width and invisible Unicode characters
fn strip_invisible_unicode(s: &str) -> String {
    s.chars()
        .filter(|&c| {
            !matches!(
                c,
                '\u{200B}'          // Zero-width space
                | '\u{200C}'        // Zero-width non-joiner
                | '\u{200D}'        // Zero-width joiner
                | '\u{200E}'        // Left-to-right mark
                | '\u{200F}'        // Right-to-left mark
                | '\u{2060}'        // Word joiner
                | '\u{2061}'        // Function application
                | '\u{2062}'        // Invisible times
                | '\u{2063}'        // Invisible separator
                | '\u{2064}'        // Invisible plus
                | '\u{FEFF}'        // BOM / zero-width no-break space
                | '\u{00AD}'        // Soft hyphen
                | '\u{034F}'        // Combining grapheme joiner
                | '\u{061C}'        // Arabic letter mark
                | '\u{2028}'        // Line separator
                | '\u{2029}'        // Paragraph separator
                | '\u{202A}'..='\u{202E}'  // Bidirectional formatting
                | '\u{2066}'..='\u{2069}'  // Bidirectional isolates
            )
        })
        .collect()
}

/// Strip box drawing and border characters
fn strip_box_drawing(s: &str) -> String {
    s.chars()
        .filter(|&c| {
            !matches!(
                c,
                // Box Drawing block (U+2500 - U+257F)
                '\u{2500}'..='\u{257F}'
                // Block Elements (U+2580 - U+259F) - often used for progress
                | '\u{2580}'..='\u{259F}'
                // Some geometric shapes used as borders
                | '\u{25A0}'..='\u{25A1}'  // Black/white square
            )
        })
        .collect()
}

/// Strip progress indicators (spinners, bars, percentages)
fn strip_progress_indicators(s: &str) -> String {
    let mut result = s.to_string();

    // Braille spinner characters (U+2800 - U+28FF)
    result = result
        .chars()
        .filter(|&c| !('\u{2800}'..='\u{28FF}').contains(&c))
        .collect();

    // ASCII spinners - only if they appear to be standalone
    // Be careful not to strip legitimate uses of | / - \
    // Strip common spinner patterns
    for spinner in &["[|]", "[/]", "[-]", "[\\]", "( )", "(o)", "(O)"] {
        result = result.replace(spinner, "");
    }

    // Progress bar patterns: [=====>    ], [###       ], etc.
    result = strip_progress_bars(&result);

    // Percentage patterns like (3/10), 45%, 100%
    result = strip_percentage_patterns(&result);

    result
}

fn strip_progress_bars(s: &str) -> String {
    let mut result = String::with_capacity(s.len());
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        if chars[i] == '[' {
            // Look for progress bar pattern
            if let Some(end) = find_progress_bar_end(&chars, i) {
                i = end + 1;
                continue;
            }
        }
        result.push(chars[i]);
        i += 1;
    }

    result
}

fn find_progress_bar_end(chars: &[char], start: usize) -> Option<usize> {
    // Progress bars: [=====>    ], [###...], [***   ], etc.
    let mut i = start + 1;
    let mut has_progress_char = false;
    let mut has_space = false;

    while i < chars.len() && i - start < 60 {
        match chars[i] {
            ']' => {
                // Valid progress bar if it had progress chars and was reasonable length
                if has_progress_char && i - start >= 3 {
                    return Some(i);
                }
                return None;
            }
            '=' | '#' | '*' | '>' | '-' => has_progress_char = true,
            ' ' => has_space = true,
            '.' if has_progress_char => {}
            _ => {
                // Non-progress character, probably not a progress bar
                if !has_space && !has_progress_char {
                    return None;
                }
            }
        }
        i += 1;
    }

    None
}

fn strip_percentage_patterns(s: &str) -> String {
    let mut result = String::new();
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        // Check for (N/M) pattern
        if chars[i] == '(' {
            if let Some(end) = find_fraction_pattern(&chars, i) {
                i = end + 1;
                continue;
            }
        }

        // Check for N% pattern (but keep if part of larger context)
        if chars[i].is_ascii_digit() {
            if let Some(end) = find_percentage_pattern(&chars, i) {
                // Only strip if it looks standalone (surrounded by spaces or at boundaries)
                let before_ok = i == 0 || chars[i - 1].is_whitespace();
                let after_ok = end + 1 >= chars.len() || chars[end + 1].is_whitespace();
                if before_ok && after_ok {
                    i = end + 1;
                    continue;
                }
            }
        }

        result.push(chars[i]);
        i += 1;
    }

    result
}

fn find_fraction_pattern(chars: &[char], start: usize) -> Option<usize> {
    // Match (N/M) where N and M are numbers
    let mut i = start + 1;

    // First number
    if i >= chars.len() || !chars[i].is_ascii_digit() {
        return None;
    }
    while i < chars.len() && chars[i].is_ascii_digit() {
        i += 1;
    }

    // Slash
    if i >= chars.len() || chars[i] != '/' {
        return None;
    }
    i += 1;

    // Second number
    if i >= chars.len() || !chars[i].is_ascii_digit() {
        return None;
    }
    while i < chars.len() && chars[i].is_ascii_digit() {
        i += 1;
    }

    // Closing paren
    if i >= chars.len() || chars[i] != ')' {
        return None;
    }

    Some(i)
}

fn find_percentage_pattern(chars: &[char], start: usize) -> Option<usize> {
    let mut i = start;

    // Digits
    while i < chars.len() && chars[i].is_ascii_digit() {
        i += 1;
    }

    // Optional decimal
    if i < chars.len() && chars[i] == '.' {
        i += 1;
        while i < chars.len() && chars[i].is_ascii_digit() {
            i += 1;
        }
    }

    // Percent sign
    if i < chars.len() && chars[i] == '%' {
        return Some(i);
    }

    None
}

/// Strip timestamp and timing patterns
fn strip_timestamp_timing(s: &str) -> String {
    let mut result = s.to_string();

    // [HH:MM:SS] pattern
    let mut new_result = String::new();
    let chars: Vec<char> = result.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        if chars[i] == '[' && i + 9 < chars.len() {
            // Check for [HH:MM:SS] pattern
            if is_timestamp_bracket(&chars, i) {
                i += 10; // Skip [HH:MM:SS]
                continue;
            }
        }
        new_result.push(chars[i]);
        i += 1;
    }
    result = new_result;

    // "took Xs" or "took X.Xs" or "took Xms" patterns
    result = strip_took_patterns(&result);

    // Duration patterns like "2.3s", "100ms" when standalone
    result = strip_standalone_durations(&result);

    result
}

fn is_timestamp_bracket(chars: &[char], start: usize) -> bool {
    // [HH:MM:SS]
    if start + 9 >= chars.len() {
        return false;
    }
    chars[start] == '['
        && chars[start + 1].is_ascii_digit()
        && chars[start + 2].is_ascii_digit()
        && chars[start + 3] == ':'
        && chars[start + 4].is_ascii_digit()
        && chars[start + 5].is_ascii_digit()
        && chars[start + 6] == ':'
        && chars[start + 7].is_ascii_digit()
        && chars[start + 8].is_ascii_digit()
        && chars[start + 9] == ']'
}

fn strip_took_patterns(s: &str) -> String {
    let mut result = String::new();
    let lower = s.to_lowercase();
    let chars: Vec<char> = s.chars().collect();
    let lower_chars: Vec<char> = lower.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        // Look for "took " pattern
        if i + 5 < lower_chars.len()
            && lower_chars[i..i + 5].iter().collect::<String>() == "took "
        {
            let start = i;
            i += 5;
            // Skip number
            while i < chars.len() && (chars[i].is_ascii_digit() || chars[i] == '.') {
                i += 1;
            }
            // Skip unit (s, ms, sec, etc.)
            let unit_start = i;
            while i < chars.len() && chars[i].is_ascii_alphabetic() {
                i += 1;
            }
            let unit: String = chars[unit_start..i].iter().collect();
            if matches!(unit.to_lowercase().as_str(), "s" | "ms" | "sec" | "secs" | "second" | "seconds" | "m" | "min" | "mins" | "minute" | "minutes") {
                continue; // Successfully stripped "took Xs"
            }
            // Not a timing pattern, restore
            i = start;
        }
        result.push(chars[i]);
        i += 1;
    }

    result
}

fn strip_standalone_durations(s: &str) -> String {
    // This is conservative - only strip durations that are clearly standalone
    // Preserve leading whitespace
    let leading: String = s.chars().take_while(|c| c.is_whitespace()).collect();
    let rest = &s[leading.len()..];

    let words: Vec<&str> = rest.split_whitespace().collect();
    let filtered: Vec<&str> = words
        .into_iter()
        .filter(|w| !is_standalone_duration(w))
        .collect();

    format!("{}{}", leading, filtered.join(" "))
}

fn is_standalone_duration(s: &str) -> bool {
    let s = s.trim_matches(|c: char| c == '(' || c == ')' || c == ',' || c == '.');

    // Check for patterns like "2.3s", "100ms", "5m"
    let mut has_digit = false;
    let mut digit_end = 0;

    for (i, c) in s.chars().enumerate() {
        if c.is_ascii_digit() || c == '.' {
            has_digit = true;
            digit_end = i + 1;
        } else {
            break;
        }
    }

    if !has_digit || digit_end == 0 {
        return false;
    }

    let suffix = &s[digit_end..];
    matches!(
        suffix.to_lowercase().as_str(),
        "s" | "ms" | "sec" | "secs" | "m" | "min" | "mins" | "h" | "hr" | "hrs"
    )
}

/// Strip truncation markers
fn strip_truncation_markers(s: &str) -> String {
    let markers = [
        "... (truncated)",
        "...(truncated)",
        "[truncated]",
        "[output truncated]",
        "(truncated)",
        "... (output truncated)",
        "[...truncated...]",
        "── truncated ──",
        "-- truncated --",
    ];

    let mut result = s.to_string();
    let lower = s.to_lowercase();

    for marker in &markers {
        if lower.contains(&marker.to_lowercase()) {
            // Case-insensitive removal
            let marker_lower = marker.to_lowercase();
            let mut new_result = String::new();
            let mut remaining = result.to_lowercase();
            let mut orig_remaining = result.as_str();

            while let Some(pos) = remaining.find(&marker_lower) {
                new_result.push_str(&orig_remaining[..pos]);
                remaining = remaining[pos + marker_lower.len()..].to_string();
                orig_remaining = &orig_remaining[pos + marker.len()..];
            }
            new_result.push_str(orig_remaining);
            result = new_result;
        }
    }

    result
}

/// Strip Claude Code specific patterns
fn strip_claude_code(s: &str) -> String {
    let mut result = s.to_string();

    // Status bar patterns (bottom bar with model/tokens info)
    // Usually contains patterns like "Claude 3.5 Sonnet" or token counts
    if is_claude_status_line(&result) {
        return String::new();
    }

    // Thinking indicators
    let thinking_patterns = [
        "Thinking...",
        "thinking...",
        "Processing...",
        "processing...",
    ];
    for pattern in &thinking_patterns {
        result = result.replace(pattern, "");
    }

    // Tool invocation chrome - lines that are purely decorative
    if is_tool_chrome_line(&result) {
        return String::new();
    }

    // Info lines starting with specific markers
    let trimmed = result.trim();
    if trimmed.starts_with("ℹ") && !trimmed.contains(':') {
        // Pure info marker without content
        return String::new();
    }

    result
}

fn is_claude_status_line(s: &str) -> bool {
    let lower = s.to_lowercase();

    // Status lines typically contain model names and token info
    let has_model = lower.contains("sonnet")
        || lower.contains("opus")
        || lower.contains("haiku")
        || lower.contains("claude");
    let has_tokens = lower.contains("tokens") || lower.contains("token");
    let has_cost = lower.contains("cost") || lower.contains("$");

    // If it has model + tokens/cost info and is relatively short, it's likely a status line
    if has_model && (has_tokens || has_cost) && s.len() < 200 {
        return true;
    }

    // Auto-compact mode indicator
    if lower.contains("auto-compact") || lower.contains("context window") {
        return true;
    }

    false
}

fn is_tool_chrome_line(s: &str) -> bool {
    let trimmed = s.trim();

    // Lines that are only decorative characters
    if trimmed.chars().all(|c| {
        matches!(
            c,
            '─' | '━' | '│' | '┃' | '┌' | '┐' | '└' | '┘' | '├' | '┤' | '┬' | '┴' | '┼' | '═'
                | '║' | '╔' | '╗' | '╚' | '╝' | ' ' | '·' | '•'
        )
    }) && !trimmed.is_empty()
    {
        return true;
    }

    // Tool use headers that don't contain useful info
    if trimmed.starts_with("───") || trimmed.starts_with("━━━") {
        return true;
    }

    false
}

/// Strip Codex specific patterns
fn strip_codex(s: &str) -> String {
    let lower = s.to_lowercase();

    // Sandbox notices
    if lower.contains("sandbox") && lower.contains("enabled") {
        return String::new();
    }

    // Codex status indicators
    if lower.contains("codex") && (lower.contains("ready") || lower.contains("waiting")) {
        return String::new();
    }

    // Container/environment notices that aren't useful for context
    if lower.contains("running in container") || lower.contains("docker environment") {
        return String::new();
    }

    s.to_string()
}

/// Strip Gemini specific patterns
fn strip_gemini(s: &str) -> String {
    let lower = s.to_lowercase();

    // Gemini-specific status/chrome patterns
    if lower.contains("gemini") && (lower.contains("ready") || lower.contains("model:")) {
        // Check if it's a status line vs actual content
        if s.len() < 100 {
            return String::new();
        }
    }

    s.to_string()
}

/// Normalize whitespace
fn normalize_whitespace(s: &str) -> String {
    // Trim trailing whitespace
    let trimmed = s.trim_end();

    // Collapse multiple spaces into one (but preserve leading indentation)
    let mut result = String::with_capacity(trimmed.len());
    let mut chars = trimmed.chars().peekable();
    let mut in_leading = true;
    let mut prev_space = false;

    while let Some(c) = chars.next() {
        if c == ' ' || c == '\t' {
            if in_leading {
                // Preserve leading whitespace
                result.push(c);
            } else if !prev_space {
                result.push(' ');
                prev_space = true;
            }
            // else: collapse consecutive spaces
        } else {
            in_leading = false;
            prev_space = false;
            result.push(c);
        }
    }

    result
}
