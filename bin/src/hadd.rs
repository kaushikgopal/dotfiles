use std::io::{self, BufRead, Write};

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = io::stdout();

    for raw_line in stdin.lock().lines() {
        let line = raw_line?;
        let trimmed = line.trim();

        if trimmed.is_empty() {
            // The Python version emits a lone marker when callers send spacing lines, so we preserve that contract verbatim.
            writeln!(stdout, "#")?;
        } else {
            // We intentionally stack comment markers so repeated passes through this tool make the accumulated quoting explicit and reversible via commremove.
            writeln!(stdout, "# {trimmed}")?;
        }
    }

    stdout.flush()?; // Flushing intentionally mirrors the python script's immediate stdout behavior so pipelines never block on buffered data.
    Ok(())
}
