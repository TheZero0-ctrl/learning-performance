#![allow(dead_code)]
#![allow(unused_variables)]

use std::usize;

fn show_bytes<T: Copy>(val: T) {
    let bytes = unsafe {
        std::slice::from_raw_parts(
            &val as *const T as *const u8,
            std::mem::size_of::<T>(),
        )
    };
    for byte in bytes {
        print!("{:02x} ", byte);
    }
    println!();
}

fn inplace_swap(x: &mut i32, y: &mut i32) {
    *y = *x ^ *y;
    *x = *x ^ *y;
    *y = *x ^ *y;
}

fn show_str_bytes(s: &str) {
    for byte in s.as_bytes() {
        print!("{:02x} ", byte);
    }
    println!();
}

// given two hex, return the second hex but least significant of second is replace by that of first
fn swap_hex(h1: u32, h2: u32) {
    let result = (h2 & 0xFFFFFF00) | (h1 & 0xFF);

    println!("Result: 0x{:08X}", result)
}

fn set_lsb_to_1(x: u32) -> u32 {
    x | 0x00000001
}

fn get_lowest_byte(x: u32) -> u8 {
    (x & 0xFF) as u8
}

fn shift_lowest_byte_to_second(x: u32) -> u32 {
    (x & 0xFF) << 8
}

// 0XFF
// 00000000 00000000 00000000 11111111
// << 8 = 00000000 00000000 11111111 00000000

fn clear_byte(x: u32, i: usize) -> u32 {
    x & !(0xFF << (i * 8))
}

// function that inserts byte b (a u8) into byte i of x, assuming that byte i is already cleared (set to 0x00).
fn insert_byte(x: u32, i: usize, b: u8) -> u32 {
    x | (b as u32) << (i * 8)
}

// replace the byte at index i with b
fn replace_byte(x: u32, i: usize, b: u8) -> u32 {
    insert_byte(clear_byte(x, i), i, b)
}

fn swap_bytes(x: u32, i: usize, j: usize) -> u32 {
    let byte_i = (x & (0xFF << (i * 8))) >> (i * 8);
    let byte_j = (x & (0xFF << (j * 8))) >> (j * 8);
    let first = replace_byte(x, i, byte_j as u8);
    replace_byte(first, j, byte_i as u8)
}

fn main() {
    println!("Hello, world!");

    let x: i32 = 0x01234567;
    let ptr = &x as *const i32;

    println!("{}", x);
    println!("{:?}", ptr);

    if cfg!(target_endian = "little") {
        println!("System is little-endian");
    } else {
        println!("System is big-endian");
    }

    let x: i32 = 12345;
    let f: f32 = x as f32;
    let p: *const i32 = &x;

    println!("int:");
    show_bytes(x);

    println!("float:");
    show_bytes(f);

    println!("pointer:");
    show_bytes(p);

    let s = "12345";
    println!("string:");
    show_str_bytes(s);

    let s_2 = "abcdef";
    println!("string:");
    show_str_bytes(s_2);

    let a: u8 = 0x69 ^ 0x55;
    println!("0x69 ^ 0x55 = {:0x}", a);

    let mut x = 10;
    let mut y = 10;
    inplace_swap(&mut x, &mut y);
    println!("x = {}, y = {}", x, y);

    let x: u32 =  0x89ABCDEF;
    let y: u32 = 0x765432EF;

    swap_hex(x, y);

    set_lsb_to_1(x);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_set_lsb_to_1() {
        assert_eq!(set_lsb_to_1(0b1000), 0b1001);
        assert_eq!(set_lsb_to_1(0b1110), 0b1111);
        assert_eq!(set_lsb_to_1(0b1011), 0b1011);
    }

    #[test]
    fn test_lowest_byte() {
        assert_eq!(get_lowest_byte(0x12345678), 0x78);
        assert_eq!(get_lowest_byte(0xABCDEF00), 0x00);
        assert_eq!(get_lowest_byte(0x000000FF), 0xFF);
    }

    #[test]
    fn test_shift_lowest_byte_to_second() {
        assert_eq!(shift_lowest_byte_to_second(0x000000AB), 0x0000AB00);
        assert_eq!(shift_lowest_byte_to_second(0x00000001), 0x00000100);
        assert_eq!(shift_lowest_byte_to_second(0x000000FF), 0x0000FF00);
    }

    #[test]
    fn test_clear_byte() {
        assert_eq!(clear_byte(0x12345678, 0), 0x12345600);
        assert_eq!(clear_byte(0x12345678, 1), 0x12340078);
        assert_eq!(clear_byte(0xFFFFFFFF, 2), 0xFF00FFFF);
    }

    #[test]
    fn test_insert_byte() {
        assert_eq!(insert_byte(0x12340078, 1, 0x56), 0x12345678);
        assert_eq!(insert_byte(0x12345600, 0, 0xAB), 0x123456AB);
        assert_eq!(insert_byte(0x0000FFFF, 2, 0x12), 0x0012FFFF);
    }

    #[test]
    fn test_replace_byte() {
        assert_eq!(replace_byte(0x12345678, 0, 0xAB), 0x123456AB);
        assert_eq!(replace_byte(0x12345678, 1, 0xAB), 0x1234AB78);
        assert_eq!(replace_byte(0x12345678, 2, 0xAB), 0x12AB5678);
        assert_eq!(replace_byte(0x12345678, 3, 0xAB), 0xAB345678);
        assert_eq!(replace_byte(0xFFFFFFFF, 0, 0x00), 0xFFFFFF00);
        assert_eq!(replace_byte(0x00000000, 2, 0xFF), 0x00FF0000);
    }

    #[test]
    fn test_swap_bytes() {
        assert_eq!(swap_bytes(0x12345678, 0, 1), 0x12347856);
        assert_eq!(swap_bytes(0x12345678, 1, 2), 0x12563478);
        assert_eq!(swap_bytes(0xAABBCCDD, 0, 3), 0xDDBBCCAA);
    }
}

