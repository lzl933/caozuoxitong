#![no_std]
#![no_main]

#[macro_use]
extern crate user_lib;

#[unsafe(no_mangle)]
fn main() -> i32 {
    let mut sum = 0;
    for i in 1..=10 {
        sum += i;
    }
    println!("sum(1..=10)={}", sum);
    0
}
