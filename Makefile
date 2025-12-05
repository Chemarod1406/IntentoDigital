# ==========================================
# Configuración del Proyecto
# ==========================================
TARGET     = temp_display_final
TOP        = temp_display_top_final
BUILD_DIR  = build

# Directorios
DIR_LED    = LedDisplay
DIR_SENSOR = SensorTemp

# Archivo de restricciones (pines de la FPGA)
LPF_FILE   = $(DIR_LED)/colorlight_5a.lpf

# ==========================================
# Archivos de Control (del profesor)
# ==========================================
LED_CTRL = $(DIR_LED)/count.v \
           $(DIR_LED)/comp.v \
           $(DIR_LED)/ctrl_lp4k.v \
           $(DIR_LED)/lsr_led.v \
           $(DIR_LED)/mux_led.v

# ==========================================
# Archivos de Display (nuevos)
# ==========================================
LED_NEW  = $(DIR_LED)/led_temp_with_display.v \
           $(DIR_LED)/temp_pixel_generator.v \
           $(DIR_LED)/digit_5x7_rom.v \
           $(DIR_LED)/temp_display_top_final.v

# ==========================================
# Archivos del Sensor I2C
# ==========================================
SENSOR_SRCS = $(DIR_SENSOR)/i2c_master.v \
              $(DIR_SENSOR)/clkgen_200KHz.v \
              $(DIR_SENSOR)/temp_converter.v \
              $(DIR_SENSOR)/add_32.v \
              $(DIR_SENSOR)/divide_by_5.v \
              $(DIR_SENSOR)/multiply_by_9.v

# Todos los archivos de síntesis
ALL_SRCS = $(LED_CTRL) $(LED_NEW) $(SENSOR_SRCS)

# Archivos de testbench (solo para simulación)
TB_SRCS = $(DIR_SENSOR)/i2c_slave_lm75_model.v \
          $(DIR_LED)/tb_final.v

# ==========================================
# Reglas Principales
# ==========================================
.PHONY: all clean sim prog info

# Regla por defecto: compilar bitstream
all: $(BUILD_DIR)/$(TARGET).bit

# Crear directorio de build
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Limpiar archivos generados
clean:
	rm -rf $(BUILD_DIR) *.vcd a.out

# ==========================================
# Simulación con Icarus Verilog
# ==========================================
sim:
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     COMPILANDO SIMULACIÓN             ║"
	@echo "╚═══════════════════════════════════════╝"
	iverilog -o a.out $(TB_SRCS) $(ALL_SRCS)
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     EJECUTANDO SIMULACIÓN             ║"
	@echo "╚═══════════════════════════════════════╝"
	vvp a.out
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     ABRIENDO GTKWAVE                  ║"
	@echo "╚═══════════════════════════════════════╝"
	gtkwave final_test.vcd &

# ==========================================
# Flujo de Síntesis para FPGA
# ==========================================

# Paso 1: Síntesis con Yosys
$(BUILD_DIR)/$(TARGET).json: $(ALL_SRCS) | $(BUILD_DIR)
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     PASO 1: SÍNTESIS (YOSYS)          ║"
	@echo "╚═══════════════════════════════════════╝"
	yosys -p "read_verilog $(ALL_SRCS); synth_ecp5 -top $(TOP) -json $@" -l $(BUILD_DIR)/synth.log
	@echo "✓ Síntesis completada. Ver: $(BUILD_DIR)/synth.log"

# Paso 2: Place & Route con NextPNR
$(BUILD_DIR)/$(TARGET).config: $(BUILD_DIR)/$(TARGET).json
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     PASO 2: PLACE & ROUTE (NEXTPNR)   ║"
	@echo "╚═══════════════════════════════════════╝"
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
	@echo "✓ Place & Route completado. Ver: $(BUILD_DIR)/pnr.log"

# Paso 3: Empaquetado con Ecppack
$(BUILD_DIR)/$(TARGET).bit: $(BUILD_DIR)/$(TARGET).config
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     PASO 3: EMPAQUETADO (ECPPACK)     ║"
	@echo "╚═══════════════════════════════════════╝"
	ecppack --compress $< --bit $@
	@echo "✓ Bitstream generado: $@"

# ==========================================
# Programación de la FPGA
# ==========================================
prog: $(BUILD_DIR)/$(TARGET).bit
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     PROGRAMANDO FPGA                  ║"
	@echo "╚═══════════════════════════════════════╝"
	sudo openFPGALoader -c ft232RL --pins=TXD:CTS:DTR:RXD -m $<
	@echo "✓ FPGA programada exitosamente"

# ==========================================
# Información del proyecto
# ==========================================
info:
	@echo ""
	@echo "╔═══════════════════════════════════════╗"
	@echo "║     INFORMACIÓN DEL PROYECTO          ║"
	@echo "╚═══════════════════════════════════════╝"
	@echo "Target:          $(TARGET)"
	@echo "Top Module:      $(TOP)"
	@echo "FPGA:            ECP5-25k (Colorlight 5A-75B)"
	@echo "Clock:           25 MHz"
	@echo ""
	@echo "Archivos LED:    $(words $(LED_CTRL) $(LED_NEW))"
	@echo "Archivos Sensor: $(words $(SENSOR_SRCS))"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make sim       - Ejecutar simulación"
	@echo "  make all       - Compilar bitstream"
	@echo "  make prog      - Programar FPGA"
	@echo "  make clean     - Limpiar archivos"
	@echo "  make info      - Ver esta información"
	@echo "