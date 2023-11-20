use std::env;
use std::fs::{File, OpenOptions};
use std::io::{self, BufRead, BufReader, Write};

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        println!("Usage: fact <number>");
        return Ok(());
    }

    let num: u64 = match args[1].parse() {
        Ok(n) => n,
        Err(_) => {
            println!("Please provide a valid number");
            return Ok(());
        }
    };

    if num == 0 {
        println!("factorial(0) = 1");
        return Ok(());
    }

    let file_name = ".facts";
    let mut facts: Vec<u64> = Vec::new();

    if let Ok(file) = File::open(file_name) {
        let reader = BufReader::new(file);
        for line in reader.lines() {
            if let Ok(value) = line.unwrap().parse() {
                facts.push(value);
            }
        }
        // println!("Values up to {} read from cache", facts.len());
    }
    else {
        // println!("Cache not found, creating");
    }

    if num <= facts.len() as u64 {
        // println!("Using value from cache");
        println!("factorial({}) = {}", num, facts[num as usize - 1]);
        return Ok(());
    }

    let mut file = OpenOptions::new()
        .write(true)
        .create(true)
        .append(true)
        .open(file_name)
        .expect("Cache writing error");
    
    let mut result = if let Some(last_fact) = facts.last() {
        *last_fact
    } else {
        1
    };
    for i in (facts.len() + 1)..=(num as usize) {
        println!("{}", i);
        result *= i as u64;
        let _ = writeln!(file, "{}", result);
    }
    
    println!("factorial({}) = {}", num, result);

    Ok(())
}
