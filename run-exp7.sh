#!/bin/bash
# GardenerOS 老师仓库 实验7 一键运行
# 仓库: https://gitee.com/gardeneros/gardeneros.git
set -e
export RUSTUP_NO_SELF_UPDATE=1
export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rust/rustup

PROJ="${PROJ:-/mnt}"

echo "===== 1. Cargo 镜像（清华 sparse）====="
mkdir -p ~/.cargo
cp -f "$PROJ/.cargo/config.toml" ~/.cargo/config.toml

source ~/.cargo/env
cd "$PROJ"

echo "===== 2. Rust 工具链 ====="
rustup toolchain install nightly-2024-09-01 --profile minimal || true
rustup default nightly-2024-09-01
rustup target add riscv64gc-unknown-none-elf
rustup component add llvm-tools-preview
rustc -V

echo "===== 3. 检查 bootloader ====="
test -f bootloader/opensbi.bin || { echo "缺少 bootloader/opensbi.bin"; exit 1; }

echo "===== 4. 编译用户程序（ELF，勿用 make build 生成 .bin）====="
cd user
cargo build --release
cd ../os

echo "===== 5. 编译内核 ====="
cargo build --release
rust-objcopy --binary-architecture=riscv64 \
  target/riscv64gc-unknown-none-elf/release/os \
  --strip-all -O binary \
  target/riscv64gc-unknown-none-elf/release/os.bin

echo "===== 6. 运行 QEMU（OpenSBI）====="
echo "退出: Ctrl+A 再按 X"
echo "Shell 中可输入: usertests  或  forktest  或  hello_world"
qemu-system-riscv64 \
  -machine virt -nographic \
  -bios ../bootloader/opensbi.bin \
  -device loader,file=target/riscv64gc-unknown-none-elf/release/os.bin,addr=0x80200000
