use std::fmt::Display;
use crate::REGISTERS_W1;

#[derive(Debug)]
pub struct Instruction {
    pub opcode: &'static str,
    pub oprand_type: OperandType,
    pub reg: Option<String>,
    pub rm: Option<String>,
    pub d: Option<bool>,
    pub data: Option<u16>,
    pub negative_data: Option<i32>,
}

#[derive(Debug)]
pub enum OperandType {
    RegMem,  // Register/Memory to/from Register
    ImmReg,  // Immediate to Register
    ImmRm,   // Immediate to Register/Memory
    Jump,    // Jump
}

impl Display for Instruction {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self.oprand_type {
            OperandType::RegMem => {
                if self.d.unwrap() {
                    write!(f, "{} {}, {}", self.opcode, self.reg.as_ref().unwrap(), self.rm.as_ref().unwrap())
                } else {
                    write!(f, "{} {}, {}", self.opcode, self.rm.as_ref().unwrap(), self.reg.as_ref().unwrap())
                }
            },
            OperandType::ImmReg => {
                match self.negative_data {
                    Some(data) => write!(f, "{} {}, {}", self.opcode, self.reg.as_ref().unwrap(), data),
                    None => write!(f, "{} {}, {}", self.opcode, self.reg.as_ref().unwrap(), self.data.unwrap()),
                }
            },
            OperandType::ImmRm => {
                match self.negative_data {
                    Some(data) => write!(f, "{} {}, {}", self.opcode, self.rm.as_ref().unwrap(), data),
                    None => write!(f, "{} {}, {}", self.opcode, self.rm.as_ref().unwrap(), self.data.unwrap()),
                }
            },
            OperandType::Jump => {
                match self.negative_data {
                    Some(data) => write!(f, "{} {}", self.opcode, data),
                    None => write!(f, "{} {}", self.opcode, self.data.unwrap()),
                }
            },
        }
    }
}

impl Instruction {
    pub fn execute(&self, registers: &mut Vec<i32>, flag_registers: &mut Vec<u8>, ip: &mut usize, prev_ip: &mut usize) {
        match self.opcode {
            "mov" => {
                match self.oprand_type {
                    OperandType::ImmReg => {
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let data = self.data.unwrap() as i32;
                        println!(
                            "mov {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x}",
                            reg_text,
                            data,
                            reg_text,
                            registers[reg],
                            data,
                            *prev_ip,
                            *ip
                        );
                        registers[reg] = data 
                    },
                    OperandType::RegMem => {
                        // currently only supports register to register
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let rm_text = self.rm.as_ref().unwrap();
                        let rm = REGISTERS_W1.iter().position(|&r| r == rm_text).unwrap();
                        if self.d.unwrap() {
                            println!(
                                "mov {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x}",
                                reg_text,
                                rm_text,
                                reg_text,
                                registers[reg],
                                registers[rm],
                                *prev_ip,
                                *ip
                            );
                            registers[reg] = registers[rm]
                        } else {
                            println!(
                                "mov {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x}",
                                rm_text,
                                reg_text,
                                rm_text,
                                registers[rm],
                                registers[reg],
                                *prev_ip,
                                *ip
                            );
                            registers[rm] = registers[reg]
                        }
                    },
                    _ => {
                        println!("Unimplemented");
                    }
                }
            },
            "add" => {
                match self.oprand_type {
                    OperandType::ImmReg => {
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let data = self.data.unwrap() as i32;
                        let result = registers[reg] + data;
                        let flags = update_flag(flag_registers, result);
                        println!(
                            "add {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                            reg_text,
                            data,
                            reg_text,
                            registers[reg],
                            result,
                            *prev_ip,
                            *ip,
                            flags,
                        );
                        registers[reg] = result
                    },
                    OperandType::RegMem => {
                        // currently only supports register to register
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let rm_text = self.rm.as_ref().unwrap();
                        let rm = REGISTERS_W1.iter().position(|&r| r == rm_text).unwrap();
                        if self.d.unwrap() {
                            let result = registers[reg] + registers[rm];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "add {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                                reg_text,
                                rm_text,
                                reg_text,
                                registers[reg],
                                result,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                            registers[reg] = result
                        } else {
                            let result = registers[rm] + registers[reg];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "add {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                                rm_text,
                                reg_text,
                                rm_text,
                                registers[rm],
                                result,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                            registers[rm] = result
                        }
                    },
                    _ => {
                        println!("Unimplemented");
                    }
                }
            },
            "sub" => {
                match self.oprand_type {
                    OperandType::ImmReg => {
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let data = self.data.unwrap() as i32;
                        let result = registers[reg] - data;
                        let flags = update_flag(flag_registers, result);
                        println!(
                            "sub {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                            reg_text,
                            data,
                            reg_text,
                            registers[reg],
                            result,
                            *prev_ip,
                            *ip,
                            flags,
                        );
                        registers[reg] = result
                    },
                    OperandType::RegMem => {
                        // currently only supports register to register
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let rm_text = self.rm.as_ref().unwrap();
                        let rm = REGISTERS_W1.iter().position(|&r| r == rm_text).unwrap();
                        if self.d.unwrap() {
                            let result = registers[reg] - registers[rm];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "sub {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                                reg_text,
                                rm_text,
                                reg_text,
                                registers[reg],
                                result,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                            registers[reg] = result
                        } else {
                            let result = registers[rm] - registers[reg];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "sub {}, {} ; {}:0x{:x}->0x{:x} ip:0x{:x}->0x{:x} {}",
                                rm_text,
                                reg_text,
                                rm_text,
                                registers[rm],
                                result,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                            registers[rm] = result
                        }
                    },
                    _ => {
                        println!("Unimplemented");
                    }
                }
            },
            "cmp" => {
                match self.oprand_type {
                    OperandType::ImmReg => {
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let data = self.data.unwrap() as i32;
                        let result = registers[reg] - data;
                        let flags = update_flag(flag_registers, result);
                        println!(
                            "cmp {}, {} ip:0x{:x}->0x{:x} {}",
                            reg_text,
                            data,
                            *prev_ip,
                            *ip,
                            flags,
                        );
                    },
                    OperandType::RegMem => {
                        // currently only supports register to register
                        let reg_text = self.reg.as_ref().unwrap();
                        let reg = REGISTERS_W1.iter().position(|&r| r == reg_text).unwrap();
                        let rm_text = self.rm.as_ref().unwrap();
                        let rm = REGISTERS_W1.iter().position(|&r| r == rm_text).unwrap();
                        if self.d.unwrap() {
                            let result = registers[reg] - registers[rm];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "cmp {}, {} ip:0x{:x}->0x{:x} {}",
                                reg_text,
                                rm_text,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                        } else {
                            let result = registers[rm] - registers[reg];
                            let flags = update_flag(flag_registers, result);
                            println!(
                                "cmp {}, {} ip:0x{:x}->0x{:x} {}",
                                rm_text,
                                reg_text,
                                *prev_ip,
                                *ip,
                                flags,
                            );
                        }
                    },
                    _ => {
                        println!("Unimplemented");
                    }
                }
            }
            "jne" => {
                let data = match self.negative_data {
                    Some(data) => data,
                    None => self.data.unwrap() as i32,
                };
                let difference = *ip as i32 - *prev_ip as i32;
                let current_ip = *prev_ip;
                if flag_registers[0] == 0 {
                    *ip = (*ip as i32 + data) as usize;
                    *prev_ip = *ip;
                }
                println!("jne ${} ; ip:0x{:x}->0x{:x}", data + difference, current_ip, *ip,);
            },
            _ => {
                println!("Unimplemented");
            }
        }
    }
}

fn update_flag(flag_registers: &mut Vec<u8>, result: i32) -> String {
    let mut flags = String::new();
    if result == 0 {
        if flag_registers[0] == 0 {
            flag_registers[0] = 1;
            flags.push_str("flags:-> Z");
        }
    } else {
        if flag_registers[0] == 1 {
            flag_registers[0] = 0;
            flags.push_str("flags:Z->");
        }
    }

    if result as u16 & 0b1000_0000_0000_0000 != 0 {
        if flag_registers[1] == 0 {
            flag_registers[1] = 1;
            flags.push_str("flags:-> S");
        }
    } else {
        if flag_registers[1] == 1 {
            flag_registers[1] = 0;
            flags.push_str("flags:S->");
        }
    }
    flags
}
