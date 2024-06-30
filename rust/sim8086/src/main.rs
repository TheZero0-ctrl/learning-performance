use std::fmt::Display;
use std::fs::File;
use std::io::Read;
use std::env;

const REGISTERS_W0: [&str; 8] = ["al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"];
const REGISTERS_W1: [&str; 8] = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"];
const MEMORY: [&str; 8] = ["bx + si", "bx + di", "bp + si", "bp + di", "si", "di", "bp", "bx"];

struct Instruction {
    opcode: String,
    mov: Mov,
    reg: String,
    rm: Option<String>,
    d: Option<bool>,
    data: Option<u16>,
}

impl Display for Instruction {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self.mov {
            Mov::RegMem => {
                if self.d.unwrap() {
                    write!(f, "{} {}, {}", self.opcode, self.reg, self.rm.as_ref().unwrap())
                } else {
                    write!(f, "{} {}, {}", self.opcode, self.rm.as_ref().unwrap(), self.reg)
                }
            },
            Mov::ImmReg => write!(f, "{} {}, {}", self.opcode, self.reg, self.data.unwrap()),
        }
    }
}

enum Mov {
    RegMem,
    ImmReg
}

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
    let mut values: Vec<u8> = Vec::new();
    file.read_to_end(&mut values).expect("Failed to read file");

    println!("bits 16\n");

    let mut index = 0;
    while let Some(value) = values.get(index) {
        if (value >> 4) & 0b1111 == 0b1011 { 
            let w = (value >> 3) & 0b1 != 0;
            let reg = ((value) & 0b111) as usize;
            let data:u16 = match w {
                true => {
                    index += 3;
                    u16::from_le_bytes([values[index - 2], values[index - 1]])
                },
                false => {
                    index += 2;
                    values[index - 1] as u16
                }
            };
            let instruction  = Instruction {
                opcode: "mov".to_string(),
                mov: Mov::ImmReg,
                reg: look_up_reg(reg, w),
                rm: None,
                d: None,
                data: Some(data),
            };
            println!("{}", instruction);
        } else {
            let w = value & 0b1 != 0;
            let d = (value >> 1) & 0b1 != 0;
            let reg = ((values[index + 1] >> 3) & 0b111) as usize;
            let rm = (values[index + 1] & 0b111) as usize;
            let instruction = match (values[index + 1] >> 6) & 0b11 {
                0b00 => {
                    let rm_value: String;
                    if rm == 6 {
                        let displacement = u16::from_le_bytes([values[index + 2], values[index + 3]]);
                        index += 4;
                        rm_value = if displacement == 0 {
                            format!("[{}]", MEMORY[rm])
                        } else {
                            format!("[{} + {}]", MEMORY[rm], displacement)
                        };
                    } else {
                        rm_value = format!("[{}]", MEMORY[rm]);
                        index += 2;
                    }

                    Instruction {
                        opcode: "mov".to_string(),
                        mov: Mov::RegMem,
                        reg: look_up_reg(reg, w),
                        rm: Some(rm_value), 
                        d: Some(d),
                        data: None,
                    }
                },
                0b01 => {
                    let displacement = values[index + 2] as u16;
                    let rm_value = if displacement == 0 {
                        format!("[{}]", MEMORY[rm])
                    } else {
                        format!("[{} + {}]", MEMORY[rm], displacement)
                    };
                    index += 3;
                    Instruction {
                        opcode: "mov".to_string(),
                        mov: Mov::RegMem,
                        reg: look_up_reg(reg, w),
                        rm: Some(rm_value),
                        d: Some(d),
                        data: None,
                    }
                },
                0b10 => {
                    let displacement = u16::from_le_bytes([values[index + 2], values[index + 3]]);
                    let rm_value = if displacement == 0 {
                        format!("[{}]", MEMORY[rm])
                    } else {
                        format!("[{} + {}]", MEMORY[rm], displacement)
                    };
                    index += 4;
                    Instruction {
                        opcode: "mov".to_string(),
                        mov: Mov::RegMem,
                        reg: look_up_reg(reg, w),
                        rm: Some(rm_value),
                        d: Some(d),
                        data: None,
                    }
                },
                0b11 => {
                    index += 2;
                    Instruction {
                        opcode: "mov".to_string(),
                        mov: Mov::RegMem,
                        reg: look_up_reg(reg, w),
                        rm: Some(look_up_reg(rm, w)),
                        d: Some(d),
                        data: None,
                    }
                },
                _ => panic!("Invalid mod"),
            };
            println!("{}", instruction);
        }
    };
}
