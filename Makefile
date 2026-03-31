# FPGA TinyLLM — Makefile
# Usage:
#   make task2   — simulate Task 2 arithmetic modules
#   make task3   — simulate Task 3 transformer block
#   make task4   — simulate Task 4 full model
#   make synth   — run Yosys synthesis
#   make clean   — remove simulation files

IVERILOG = iverilog
VVP      = vvp
YOSYS    = yosys

RTL = rtl/fp_multiplier.v rtl/layer_norm.v rtl/kv_cache.v \
      rtl/attention_block.v rtl/ffn.v rtl/transformer_block.v

task2:
	$(IVERILOG) -g2012 -o sim_task2 $(RTL) \
	    rtl/dot_product.v rtl/softmax_lut.v \
	    tb/tb_task2.v
	$(VVP) sim_task2

task3:
	$(IVERILOG) -g2012 -o sim_task3 $(RTL) tb/tb_task3.v
	$(VVP) sim_task3

task4:
	$(IVERILOG) -g2012 -o sim_task4 $(RTL) \
	    rtl/embedding.v rtl/argmax_fsm.v rtl/model_top.v \
	    tb/tb_task4.v
	$(VVP) sim_task4

synth:
	$(YOSYS) -s run_synth.ys

clean:
	rm -f sim_task2 sim_task3 sim_task4
	rm -f waveforms/*.vcd
