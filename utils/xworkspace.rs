use i3ipc::I3Connection;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let n: i32 = match args.get(1).and_then(|s| s.parse().ok()) {
        Some(v) => v,
        None => {
            eprintln!("xworkspace: usage: xworkspace <number>");
            std::process::exit(1);
        }
    };

    let mut conn = I3Connection::connect().expect("failed to connect to sway/i3 via IPC");

    let workspaces = conn.get_workspaces().expect("failed to get workspaces");
    let focused_output = workspaces.workspaces
        .iter()
        .find(|w| w.focused)
        .map(|w| w.output.clone());

    let n = match focused_output.as_deref() {
        Some("eDP-1") => n,
        _ => n + 10,
    };

    conn.run_command(&format!("workspace number {}", n))
        .expect("failed to switch workspace");
}
