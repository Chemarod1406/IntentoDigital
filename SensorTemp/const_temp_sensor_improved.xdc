# Restricciones XDC para Colorlight 5A-75B (25MHz Clock)
# 
# NOTA IMPORTANTE: 
# - La Colorlight NO tiene un display de 7-segmentos incorporado. 
# - Los pines I2C (TMP_SDA/TMP_SCL) se han asignado a los pines del conector J1 (Pmod) como EJEMPLO. 
# - AJUSTE los pines SEG, AN, TMP_SDA y TMP_SCL segun su hardware.

## Clock signal (25MHz)
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }]; 
create_clock -add -name sys_clk_pin -period 40.000 -waveform {0 20} [get_ports {CLK100MHZ}]; 
# 40.000 ns periodo = 25 MHz

## LEDs de usuario (16 LEDs en la Colorlight 5A-75B)
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; # LED 1
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; # LED 2
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; # LED 3
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; # LED 4
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { LED[4] }]; # LED 5
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { LED[5] }]; # LED 6
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { LED[6] }]; # LED 7
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { LED[7] }]; # LED 8
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { LED[8] }]; # LED 9
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { LED[9] }]; # LED 10
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { LED[10] }]; # LED 11
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { LED[11] }]; # LED 12
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { LED[12] }]; # LED 13
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { LED[13] }]; # LED 14
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { LED[14] }]; # LED 15
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { LED[15] }]; # LED 16 (Usaremos estos para mostrar la temperatura binaria)

## I2C Pins (Ejemplo: Conector J1 de la Colorlight 5A-75B)
# Si usa otro sensor en otro conector, cambie estos pines.
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS33 } [get_ports { TMP_SCL }]; # Ejemplo Pmod J1-1
set_property -dict { PACKAGE_PIN H10 IOSTANDARD LVCMOS33 } [get_ports { TMP_SDA }]; # Ejemplo Pmod J1-2

## 7-Segment Display (EJEMPLO: PINES NO USADOS. Debe mapear a su adaptador)
# Estos pines DEBEN ser cambiados si usa un display de 7-segmentos externo.
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; #
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; #
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; #
set_property -dict { PACKAGE_PIN D16   IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; #
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; #
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; #
set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; #

set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { AN[0] }]; #
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { AN[1] }]; #
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { AN[2] }]; #
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { AN[3] }]; #
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { AN[4] }]; #
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { AN[5] }]; #
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { AN[6] }]; #
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { AN[7] }]; #