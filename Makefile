.PHONY: sim questa questa-gui synth map sta gate clean

sim:
	./scripts/run_rtl_sim.sh

questa:
	./scripts/run_questa_rtl.sh

questa-gui:
	vsim -do scripts/questa_rtl.do

synth:
	./scripts/run_synth.sh

map:
	./scripts/run_map.sh

sta:
	./scripts/run_sta.sh

gate:
	./scripts/run_gate_sim.sh

clean:
	./scripts/clean.sh
