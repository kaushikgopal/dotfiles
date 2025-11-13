//go:build ignore

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
			fmt.Println("#")
		} else {
			// We intentionally stack comment markers so repeated passes through this tool make the accumulated quoting explicit and reversible via commremove.
			fmt.Printf("# %s\n", trimmed)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "error reading input: %v\n", err)
		os.Exit(1)
	}
}
