use std::io::{self, BufRead, Write};

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = io::stdout();

    for raw_line in stdin.lock().lines() {
        let line = raw_line?;
        let trimmed = line.trim();

        if trimmed.is_empty() {
            // The Python version emits a lone marker when callers send spacing lines, so we preserve that contract verbatim.
            writeln!(stdout, ">")?;
        } else {
            // Stacking markers keeps re-quoting explicit and ensures mdquote injects a visible depth level every run so consumers can unnest by counting prefixes.
            writeln!(stdout, "> {trimmed}")?;
        }
    }

    stdout.flush()?; // Flushing intentionally mirrors the python script's immediate stdout behavior so pipelines never block on buffered data.
    Ok(())
}
