# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_OF_COARSE_MODULES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_OF_FINE_MODULES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SIZE_PER_COARSE_MODULE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SIZE_PER_FINE_MODULE" -parent ${Page_0}


}

proc update_PARAM_VALUE.NUM_OF_COARSE_MODULES { PARAM_VALUE.NUM_OF_COARSE_MODULES } {
	# Procedure called to update NUM_OF_COARSE_MODULES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_COARSE_MODULES { PARAM_VALUE.NUM_OF_COARSE_MODULES } {
	# Procedure called to validate NUM_OF_COARSE_MODULES
	return true
}

proc update_PARAM_VALUE.NUM_OF_FINE_MODULES { PARAM_VALUE.NUM_OF_FINE_MODULES } {
	# Procedure called to update NUM_OF_FINE_MODULES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_FINE_MODULES { PARAM_VALUE.NUM_OF_FINE_MODULES } {
	# Procedure called to validate NUM_OF_FINE_MODULES
	return true
}

proc update_PARAM_VALUE.SIZE_PER_COARSE_MODULE { PARAM_VALUE.SIZE_PER_COARSE_MODULE } {
	# Procedure called to update SIZE_PER_COARSE_MODULE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIZE_PER_COARSE_MODULE { PARAM_VALUE.SIZE_PER_COARSE_MODULE } {
	# Procedure called to validate SIZE_PER_COARSE_MODULE
	return true
}

proc update_PARAM_VALUE.SIZE_PER_FINE_MODULE { PARAM_VALUE.SIZE_PER_FINE_MODULE } {
	# Procedure called to update SIZE_PER_FINE_MODULE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIZE_PER_FINE_MODULE { PARAM_VALUE.SIZE_PER_FINE_MODULE } {
	# Procedure called to validate SIZE_PER_FINE_MODULE
	return true
}


proc update_MODELPARAM_VALUE.NUM_OF_COARSE_MODULES { MODELPARAM_VALUE.NUM_OF_COARSE_MODULES PARAM_VALUE.NUM_OF_COARSE_MODULES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_COARSE_MODULES}] ${MODELPARAM_VALUE.NUM_OF_COARSE_MODULES}
}

proc update_MODELPARAM_VALUE.NUM_OF_FINE_MODULES { MODELPARAM_VALUE.NUM_OF_FINE_MODULES PARAM_VALUE.NUM_OF_FINE_MODULES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_FINE_MODULES}] ${MODELPARAM_VALUE.NUM_OF_FINE_MODULES}
}

proc update_MODELPARAM_VALUE.SIZE_PER_COARSE_MODULE { MODELPARAM_VALUE.SIZE_PER_COARSE_MODULE PARAM_VALUE.SIZE_PER_COARSE_MODULE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIZE_PER_COARSE_MODULE}] ${MODELPARAM_VALUE.SIZE_PER_COARSE_MODULE}
}

proc update_MODELPARAM_VALUE.SIZE_PER_FINE_MODULE { MODELPARAM_VALUE.SIZE_PER_FINE_MODULE PARAM_VALUE.SIZE_PER_FINE_MODULE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIZE_PER_FINE_MODULE}] ${MODELPARAM_VALUE.SIZE_PER_FINE_MODULE}
}

