# ==========================================
# Configuración del Proyecto
# ==========================================
TARGET     = temp_display
TOP        = temp_display_top
BUILD_DIR  = build

# Directorios de fuentes
DIR_LED    = LedDisplay
DIR_SENSOR = SensorTemp

# Archivo de Restricciones (Debe estar en la carpeta LedDisplay o raíz)
# Asegúrate de tener este archivo con los pines correctos
LPF_FILE   = $(DIR_LED)/colorlight_5a.lpf

# ==========================================
# Definición de Archivos Fuente
# ==========================================

# Pantalla (LedDisplay)
LED_OBJS =  $(DIR_LED)/count.v \
            $(DIR_LED)/ctrl_lp4k.v \
            $(DIR_LED)/digit_5x7_rom.v \
            $(DIR_LED)/comp.v \
            $(DIR_LED)/lsr_led.v \
            $(DIR_LED)/mux_led.v \
            $(DIR_LED)/temp_pixel_generator.v \
            $(DIR_LED)/led_panel_temp_display.v \
            $(DIR_LED)/temp_display_top.v

# Sensor (SensorTemp) - Archivos que mencionaste faltaban
SENSOR_OBJS = $(DIR_SENSOR)/i2c_master.v \
              $(DIR_SENSOR)/clkgen_200KHz.v \
              $(DIR_SENSOR)/temp_converter.v \
			  $(DIR_SENSOR)/add_32.v \
			  $(DIR_SENSOR)/divide_by_5.v \
			  $(DIR_SENSOR)/i2c_slave_lm75_model.v \
			  $(DIR_SENSOR)/multiply_by_9.v \
			  $(DIR_SENSOR)/top.v \

# Todos los fuentes juntos
ALL_SRCS = $(LED_OBJS) $(SENSOR_OBJS)

# ==========================================
# Reglas Principales
# ==========================================

.PHONY: all clean sim prog

all: $(BUILD_DIR)/$(TARGET).bit

# Crear directorio de build si no existe
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Limpieza
clean:
	rm -rf $(BUILD_DIR) *.vcd a.out

# ==========================================
# Simulación (Icarus Verilog)
# ==========================================
sim:
	iverilog -DBENCH -o a.out -s $(TOP)_TB $(DIR_LED)/$(TOP)_TB.v $(ALL_SRCS)
	vvp a.out
	gtkwave $(TOP)_TB.vcd &

# ==========================================
# Flujo LATTICE ECP5 (Colorlight 5A)
# ==========================================

# 1. Síntesis (Yosys)
$(BUILD_DIR)/$(TARGET).json: $(ALL_SRCS) | $(BUILD_DIR)
	yosys -p "read_verilog $(ALL_SRCS); synth_ecp5 -top $(TOP) -json $@" -l $(BUILD_DIR)/synth.log

# 2. Place & Route (Nextpnr)
# Ajustado para Colorlight 5A (ECP5-25k, encapsulado CABGA256)
$(BUILD_DIR)/$(TARGET).config: $(BUILD_DIR)/$(TARGET).json
	nextpnr-ecp5 \
		--25k \
		--package CABGA256 \
		--speed 6 \
		--json $< \
		--lpf $(LPF_FILE) \
		--textcfg $@ \
		--lpf-allow-unconstrained \
		--timing-allow-fail \
		--log $(BUILD_DIR)/pnr.log

# 3. Empaquetado (Ecppack)
$(BUILD_DIR)/$(TARGET).bit: $(BUILD_DIR)/$(TARGET).config
	ecppack --bootaddr 0 --compress $< --bit $@ --svf $(BUILD_DIR)/$(TARGET).svf

# 4. Programación (openFPGALoader)
# Ajusta los pines (--pins) si usas un cable FT232 diferente
prog: $(BUILD_DIR)/$(TARGET).bit
	sudo openFPGALoader -c ft232RL --pins=TXD:CTS:DTR:RXD -m $<