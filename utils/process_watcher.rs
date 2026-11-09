use sysinfo::{RefreshKind, ProcessRefreshKind, System, MINIMUM_CPU_UPDATE_INTERVAL};
use std::thread;
use std::time::Duration;
use std::fs::OpenOptions;
use std::io::Write;
use humantime::format_duration;

fn main() {
  let proc_refresh = ProcessRefreshKind::nothing().with_cpu();
  let refresh = RefreshKind::nothing().with_processes(proc_refresh);
  let mut systems: [System; 3] = [
    System::new().unwrap(),
    System::new().unwrap(),
    System::new().unwrap(),
  ];
  let units = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"];
  let full_unit = "▉";
  let mut pipe = OpenOptions::new()
    .write(true)
    .open("status_bar.pipe")
    .unwrap();

  loop {
    for sys in &mut systems {
      sys.refresh_specifics(refresh);
      let pid = sys.processes()
        .iter()
        .map(|(pid, proc)| (pid, proc.cpu_usage()))
        .max_by(|(_, lcpu), (_, rcpu)| f32::total_cmp(lcpu, rcpu))
        .map(|(pid, _)| pid)
        .unwrap();

      let max_proc = &sys.processes()[pid];
      let cpu_usage = max_proc.cpu_usage();
      if cpu_usage <= 20.0 {
        let _ = writeln!(pipe, "process");
        thread::sleep(Duration::from_millis(1000));
        continue;
      }

      let unit_count = cpu_usage / 100.0 * 10.0;
      let full_unit_count = unit_count.floor() as usize;
      let last_unit_size = ((unit_count - full_unit_count as f32) * units.len() as f32).floor() as usize;
      let _ = writeln!(pipe, "process ⎸{:?}@{:05.1}% ({}) <span foreground='#{:02x}{:02x}{:02x}'>{:<20}</span>|",
        max_proc.name(),
        cpu_usage,
        format_duration(Duration::from_secs(max_proc.run_time())),
        (cpu_usage * 5.0).clamp(0.0, 255.0) as u8,
        255 - (cpu_usage * 2.0).clamp(10.0, 255.0) as u8,
        40,
        full_unit.repeat(full_unit_count) + units[last_unit_size],
      );

      thread::sleep(MINIMUM_CPU_UPDATE_INTERVAL / 3);
    }
  }
}
