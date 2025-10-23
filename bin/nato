#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! ```

use std::collections::HashMap;
use std::env;

fn main() {
    let dictionary: HashMap<char, &str> = [
        ('a', "Alfa"),
        ('b', "Bravo"),
        ('c', "Charlie"),
        ('d', "Delta"),
        ('e', "Echo"),
        ('f', "Foxtrot"),
        ('g', "Golf"),
        ('h', "Hotel"),
        ('i', "India"),
        ('j', "Juliett"),
        ('k', "Kilo"),
        ('l', "Lima"),
        ('m', "Mike"),
        ('n', "November"),
        ('o', "Oscar"),
        ('p', "Papa"),
        ('q', "Quebec"),
        ('r', "Romeo"),
        ('s', "Sierra"),
        ('t', "Tango"),
        ('u', "Uniform"),
        ('v', "Victor"),
        ('w', "Whiskey"),
        ('x', "X-ray"),
        ('y', "Yankee"),
        ('z', "Zulu"),
        ('1', "One"),
        ('2', "Two"),
        ('3', "Three"),
        ('4', "Four"),
        ('5', "Five"),
        ('6', "Six"),
        ('7', "Seven"),
        ('8', "Eight"),
        ('9', "Nine"),
        ('0', "Zero"),
    ]
    .iter()
    .copied()
    .collect();

    let args: Vec<String> = env::args().skip(1).collect();
    let words: Vec<&str> = args.iter().flat_map(|s| s.split_whitespace()).collect();

    for word in words {
        let letters: Vec<String> = word
            .chars()
            .map(|c| {
                let lower = c.to_ascii_lowercase();
                dictionary
                    .get(&lower)
                    .map(|s| s.to_string())
                    .unwrap_or_else(|| c.to_string())
            })
            .collect();

        println!("{}", letters.join(" "));
    }
}
