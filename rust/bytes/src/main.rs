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
}

