use std::fs::File;
use std::io::Read;
use std::{env, usize};

const REGISTERS_W0: [&str; 8] = ["al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"];
const REGISTERS_W1: [&str; 8] = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"];

fn look_up_reg(reg: usize, w: bool) -> String {
   if w {
       REGISTERS_W1[reg as usize].to_string()
   } else {
       REGISTERS_W0[reg as usize].to_string()
   } 
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut file = File::open(&args[1]).expect("file not found");
    let mut contents  = Vec::new();
    file.read_to_end(&mut contents).expect("Failed to read file");

    let values: Vec<u16> = contents
        .chunks(2)
        .map(|x| u16::from_be_bytes([x[0], x[1]]))
        .collect();


    println!("bits 16\n");

    for value in values {
        let opcode = match (value >> 10) & 0b111111 {
            0b100010 => "mov",
            _ => panic!("Unknown opcode")
        };
        let w = ((value >> 8) & 0b1) != 0;
        let d = ((value >> 9) & 0b1) != 0;
        let reg = ((value >> 3) & 0b111) as usize;
        let rm = (value & 0b111) as usize;

        if d {
            println!("{} {}, {}", opcode, look_up_reg(reg, w), look_up_reg(rm, w));
        } else {
            println!("{} {}, {}", opcode, look_up_reg(rm, w), look_up_reg(reg, w));
        }
    }
}
