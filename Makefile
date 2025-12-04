TARGET     = temp_display_final
TOP        = temp_display_top_final
BUILD_DIR  = build

DIR_LED    = LedDisplay
DIR_SENSOR = SensorTemp

LPF_FILE   = $(DIR_LED)/colorlight_5a.lpf

# Archivos del profesor (necesarios)
LED_CTRL = $(DIR_LED)/count.v \
           $(DIR_LED)/comp.v \
           $(DIR_LED)/ctrl_lp4k.v \
           $(DIR_LED)/lsr_led.v \
           $(DIR_LED)/mux_led.v

# Archivos nuevos
LED_NEW  = $(DIR_LED)/led_temp_simple.v \
           $(DIR_LED)/digit_5x7_rom.v \
           $(DIR_LED)/temp_display_top_final.v

# Sensor
SENSOR_SRCS = $(DIR_SENSOR)/i2c_master.v \
              $(DIR_SENSOR)/clkgen_200KHz.v \
              $(DIR_SENSOR)/temp_converter.v \
              $(DIR_SENSOR)/add_32.v \
              $(DIR_SENSOR)/divide_by_5.v \
              $(DIR_SENSOR)/multiply_by_9.v

ALL_SRCS = $(LED_CTRL) $(LED_NEW) $(SENSOR_SRCS)

TB_SRCS = $(DIR_SENSOR)/i2c_slave_lm75_model.v \
          $(DIR_LED)/tb_final.v

.PHONY: all clean sim prog

all: $(BUILD_DIR)/$(TARGET).bit

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) *.vcd a.out

sim:
	@echo "=== Compilando ==="
	iverilog -o a.out $(TB_SRCS) $(ALL_SRCS)
	@echo "=== Simulando ==="
	vvp a.out
	@echo "=== Abriendo GTKWave ==="
	gtkwave final_test.vcd &

$(BUILD_DIR)/$(TARGET).json: $(ALL_SRCS) | $(BUILD_DIR)
	yosys -p "read_verilog $(ALL_SRCS); synth_ecp5 -top $(TOP) -json $@" -l $(BUILD_DIR)/synth.log

$(BUILD_DIR)/$(TARGET).config: $(BUILD_DIR)/$(TARGET).json
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $< --lpf $(LPF_FILE) --textcfg $@ --lpf-allow-unconstrained --timing-allow-fail --log $(BUILD_DIR)/pnr.log

$(BUILD_DIR)/$(TARGET).bit: $(BUILD_DIR)/$(TARGET).config
	ecppack --compress $< --bit $@

prog: $(BUILD_DIR)/$(TARGET).bit
	sudo openFPGALoader -c ft232RL --pins=TXD:CTS:DTR:RXD -m $