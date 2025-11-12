package main

import (
	"fmt"
	"os"
	"strings"
	"unicode"
)

func main() {
	dictionary := map[rune]string{
		'a': "Alfa", 'b': "Bravo", 'c': "Charlie", 'd': "Delta",
		'e': "Echo", 'f': "Foxtrot", 'g': "Golf", 'h': "Hotel",
		'i': "India", 'j': "Juliett", 'k': "Kilo", 'l': "Lima",
		'm': "Mike", 'n': "November", 'o': "Oscar", 'p': "Papa",
		'q': "Quebec", 'r': "Romeo", 's': "Sierra", 't': "Tango",
		'u': "Uniform", 'v': "Victor", 'w': "Whiskey", 'x': "X-ray",
		'y': "Yankee", 'z': "Zulu",
		'1': "One", '2': "Two", '3': "Three", '4': "Four", '5': "Five",
		'6': "Six", '7': "Seven", '8': "Eight", '9': "Nine", '0': "Zero",
	}

	args := os.Args[1:]
	var words []string
	for _, arg := range args {
		words = append(words, strings.Fields(arg)...)
	}

	for _, word := range words {
		var letters []string
		for _, c := range word {
			lower := unicode.ToLower(c)
			if natoWord, ok := dictionary[lower]; ok {
				letters = append(letters, natoWord)
			} else {
				letters = append(letters, string(c))
			}
		}
		fmt.Println(strings.Join(letters, " "))
	}
}
