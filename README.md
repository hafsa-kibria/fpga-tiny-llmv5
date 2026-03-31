# FPGA Implementation of a Tiny LLM (Inference Only)
**DCPS Lab, University of Missouri — Spring 2026**

## Project Overview
Inference-only accelerator for TinyStories-1M transformer on FPGA
using open-source tools only. No Vivado, Quartus, or proprietary EDA.

## Quick Start (from clean clone)
```bash
# Install tools
apt-get install -y iverilog yosys gtkwave
pip install transformers torch cocotb numpy

# Run all simulations
make task2   # Task 2: arithmetic modules
make task3   # Task 3: transformer block
make task4   # Task 4: full model

# Run synthesis
make synth
```

## Repository Structure
```
rtl/               Verilog source files
  fp_multiplier.v  Fixed-point multiplier (Q8.8)
  dot_product.v    Dot-product unit
  softmax_lut.v    LUT-based softmax
  layer_norm.v     LayerNorm
  kv_cache.v       KV-cache (block RAM)
  attention_block.v Multi-head attention
  ffn.v            Feed-forward network
  transformer_block.v Transformer decoder block
  embedding.v      Token embedding ROM
  argmax_fsm.v     Argmax token generation FSM
  model_top.v      Full model top-level

tb/                Testbenches
  tb_task2.v       Task 2 testbench
  tb_task3.v       Task 3 testbench
  tb_task4.v       Task 4 testbench

weights/           Q8.8 quantized model weights (.bin)
waveforms/         VCD simulation outputs
report/            Synthesis results and verification report
```

## Tools Used
- Icarus Verilog — simulation
- Yosys          — synthesis and area analysis
- GTKWave        — waveform viewing
- cocotb         — Python testbenches
- PyTorch        — reference model

## Results Summary
| Metric | Value |
|--------|-------|
| Total cells (Yosys) | 233969 |
| Memory bits (BRAM)  | 0 |
| Cycles per token    | 33 |
| FPGA time per token | 0.0007 ms @ 50MHz |
| CPU PyTorch time    | 50.22 ms |
| Estimated speedup   | 76087x |

## References
- Vaswani et al., "Attention is All You Need", NeurIPS 2017
- TinyStories: roneneldan/TinyStories-1M (HuggingFace)
- Yosys: github.com/YosysHQ/yosys
- Icarus Verilog: github.com/steveicarus/iverilog
