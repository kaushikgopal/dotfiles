package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		line := scanner.Text()
		trimmed := strings.TrimSpace(line)

		if trimmed == "" {
			// The Python version emits a lone marker when callers send spacing lines, so we preserve that contract verbatim.
			fmt.Println(">")
		} else {
			// Stacking markers keeps re-quoting explicit and ensures mdquote injects a visible depth level every run so consumers can unnest by counting prefixes.
			fmt.Printf("> %s\n", trimmed)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "error reading input: %v\n", err)
		os.Exit(1)
	}
}
