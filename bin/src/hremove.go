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
			// Downstream consumers expect literal blank lines to remain blank so quoted blocks can be round-tripped without introducing phantom text.
			fmt.Println()
		} else {
			if trimmed == "#" {
				// The lone marker is our empty-line sentinel from commadd, so we intentionally erase it to restore the caller's empty spacing contract.
				fmt.Println()
			} else {
				stripped := strings.TrimPrefix(trimmed, "# ")
				if stripped != trimmed {
					// The prefix was present and removed
					if stripped == "" {
						// When the prefix removal collapses the string, we emit a blank line so tooling never mistakes an intentionally empty comment for content.
						fmt.Println()
					} else {
						// We return the de-prefixed payload so callers regain their original text and can re-quote later if needed.
						fmt.Println(stripped)
					}
				} else {
					// Inputs that were already quoted without a space are deliberate user intent, so we propagate them untouched to avoid second-guessing manual formatting.
					fmt.Println(trimmed)
				}
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "error reading input: %v\n", err)
		os.Exit(1)
	}
}
