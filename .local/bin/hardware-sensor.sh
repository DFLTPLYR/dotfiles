#!/bin/bash

sensors -j | jq '{
  cpu: (
    .["coretemp-isa-0000"] |
    to_entries |
    map(select(.key != "Adapter")) |
    map({
      label: .key,
      temperature: .value[]?,
      max: .value["temp1_max"] // .value["temp2_max"] // .value["temp6_max"],
      critical: .value["temp1_crit"] // .value["temp2_crit"] // .value["temp6_crit"]
    })
  ),

  gpu: (
    . as $root |
    $root | to_entries |
    map(select(.key | startswith("amdgpu-pci-"))) |
    map(.value) |
    .[0] |
    {
      temperature: {
        edge: .edge.temp1_input,
        junction: .junction.temp2_input,
        memory: .mem.temp3_input
      },
      fan_speed_rpm: .fan1.fan1_input,
      power: {
        average_watts: .PPT.power1_average,
        cap_watts: .PPT.power1_cap
      },
      voltage_vddgfx: .vddgfx.in0_input,
      clocks: {
        sclk_hz: .sclk.freq1_input,
        mclk_hz: .mclk.freq2_input
      },
      pwm_percent: .pwm1.pwm1
    }
  ),

  storage: (
    . as $root |
    $root | to_entries |
    map(select(.key | startswith("nvme-pci-"))) |
    map({
      device: .key,
      composite_temp: .value.Composite.temp1_input,
      sensors: {
        "Sensor 1": .value["Sensor 1"].temp2_input,
        "Sensor 2": .value["Sensor 2"].temp3_input
      }
    })
  ),

  network: (
    if .["r8169_0_600:00-mdio-0"]? then
      [{
        device: "r8169_0_600:00-mdio-0",
        temperature: .["r8169_0_600:00-mdio-0"].temp1.temp1_input,
        max: .["r8169_0_600:00-mdio-0"].temp1.temp1_max
      }]
    else [] end
  ),

  acpi: (
    if .["acpitz-acpi-0"]? then
      {
        temp: .["acpitz-acpi-0"].temp1.temp1_input
      }
    else null end
  )
}'
