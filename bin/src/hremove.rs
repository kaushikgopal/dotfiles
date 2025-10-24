use std::io::{self, BufRead, Write};

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = io::stdout();

    for raw_line in stdin.lock().lines() {
        let line = raw_line?;
        let trimmed = line.trim();

        if trimmed.is_empty() {
            // Downstream consumers expect literal blank lines to remain blank so quoted blocks can be round-tripped without introducing phantom text.
            writeln!(stdout)?;
        } else {
            if trimmed == "#" {
                // The lone marker is our empty-line sentinel from commadd, so we intentionally erase it to restore the caller's empty spacing contract.
                writeln!(stdout)?;
            } else {
                if let Some(stripped) = trimmed.strip_prefix("# ") {
                    if stripped.is_empty() {
                        // When the prefix removal collapses the string, we emit a blank line so tooling never mistakes an intentionally empty comment for content.
                        writeln!(stdout)?;
                    } else {
                        // We return the de-prefixed payload so callers regain their original text and can re-quote later if needed.
                        writeln!(stdout, "{stripped}")?;
                    }
                } else {
                    // Inputs that were already quoted without a space are deliberate user intent, so we propagate them untouched to avoid second-guessing manual formatting.
                    writeln!(stdout, "{trimmed}")?;
                }
            }
        }
    }

    stdout.flush()?; // Flushing guarantees pipelines observing us from the other end never block waiting for deferred buffers.
    Ok(())
}
