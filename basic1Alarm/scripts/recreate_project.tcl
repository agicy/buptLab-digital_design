set origin_dir "../"
set proj_name "basic1Alarm"
set orig_proj_dir "[file normalize "$origin_dir/prj"]"

# Create project
create_project ${proj_name} ${orig_proj_dir} -part xc7a100tfgg484-1
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${proj_name}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "part" -value "xc7a100tfgg484-1" -objects $obj
set_property -name "revised_directory_structure" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${proj_name}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
  [list "${origin_dir}/src/hdl/config.svh" "Verilog Header"] \
  [list "${origin_dir}/../util/combinational/segment_decoder.sv" "SystemVerilog"] \
  [list "${origin_dir}/../util/sequential/debouncer.sv" "SystemVerilog"] \
  [list "${origin_dir}/../util/sequential/divider.sv" "SystemVerilog"] \
  [list "${origin_dir}/../util/sequential/synchronizer.sv" "SystemVerilog"] \
  [list "${origin_dir}/../util/sequential/timing.sv" "SystemVerilog"] \
  [list "${origin_dir}/../util/sequential/v_divider.sv" "SystemVerilog"] \
  [list "${origin_dir}/../module/audio_generator.sv" "SystemVerilog"] \
  [list "${origin_dir}/../module/buttons.sv" "SystemVerilog"] \
  [list "${origin_dir}/../module/digital_tube.sv" "SystemVerilog"] \
  [list "${origin_dir}/../module/keyboards.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/audio_output_generator.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/controller.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/data_modifier.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/display_data_generator.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/input_receiver.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/pointer_modifier.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/controller/state_machine.sv" "SystemVerilog"] \
  [list "${origin_dir}/src/hdl/top_module.sv" "SystemVerilog"] \
]
foreach file_type $files {
  set file [lindex $file_type 0]
  set type [lindex $file_type 1]
  set normalized_file [file normalize $file]
  puts "Processing file: $normalized_file"
  add_files -norecurse -fileset $obj $normalized_file
  set file_obj [get_files -of_objects [get_filesets sources_1] [list $normalized_file]]
  switch {$type} {
    "XCI" {
      set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
      if { ![get_property "is_locked" $file_obj] } {
        set_property -name "generate_synth_checkpoint" -value "0" -objects $file_obj
      }
      set_property -name "registered_with_manager" -value "1" -objects $file_obj
    }
    "Verilog Header" {
      set_property -name "file_type" -value $type -objects $file_obj
    }
    "SystemVerilog" {
      set_property -name "file_type" -value $type -objects $file_obj
    }
    "COE" {
    }
  }
}
set_property -name "dataflow_viewer_settings" -value "min_width=16" -objects $obj
set_property -name "top" -value "top_module" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
set file "[file normalize "$origin_dir/src/xdc/constraints.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/src/xdc/constraints.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "target_part" -value "xc7a100tfgg484-1" -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set_property -name "top" -value "top_module" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
