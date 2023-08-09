# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_OF_MODULES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RO_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.NUM_OF_MODULES { PARAM_VALUE.NUM_OF_MODULES } {
	# Procedure called to update NUM_OF_MODULES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_MODULES { PARAM_VALUE.NUM_OF_MODULES } {
	# Procedure called to validate NUM_OF_MODULES
	return true
}

proc update_PARAM_VALUE.RO_SIZE { PARAM_VALUE.RO_SIZE } {
	# Procedure called to update RO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RO_SIZE { PARAM_VALUE.RO_SIZE } {
	# Procedure called to validate RO_SIZE
	return true
}


proc update_MODELPARAM_VALUE.NUM_OF_MODULES { MODELPARAM_VALUE.NUM_OF_MODULES PARAM_VALUE.NUM_OF_MODULES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_MODULES}] ${MODELPARAM_VALUE.NUM_OF_MODULES}
}

proc update_MODELPARAM_VALUE.RO_SIZE { MODELPARAM_VALUE.RO_SIZE PARAM_VALUE.RO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RO_SIZE}] ${MODELPARAM_VALUE.RO_SIZE}
}

