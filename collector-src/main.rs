use std::collections::HashMap;
use std::fs;
use std::time::Instant;

const SKIP: [&str; 3] = ["lo", "docker0", "virbr0"];

fn read_totals() -> (u64, u64) {
    let data = fs::read_to_string("/proc/net/dev").expect("read /proc/net/dev");
    let mut rx = 0u64;
    let mut tx = 0u64;
    for line in data.lines().skip(2) {
        let (name, rest) = match line.split_once(':') {
            Some(v) => v,
            None => continue,
        };
        let name = name.trim();
        if SKIP.contains(&name) {
            continue;
        }
        let fields: Vec<&str> = rest.split_whitespace().collect();
        if fields.len() < 9 {
            continue;
        }
        rx += fields[0].parse::<u64>().unwrap_or(0);
        tx += fields[8].parse::<u64>().unwrap_or(0);
    }
    (rx, tx)
}

fn format_rate(bps: f64) -> String {
    let units = ["B/s", "KB/s", "MB/s", "GB/s"];
    let mut v = bps;
    let mut i = 0;
    while v >= 1024.0 && i < units.len() - 1 {
        v /= 1024.0;
        i += 1;
    }
    if i == 0 {
        format!("{} {}", v as u64, units[i])
    } else {
        format!("{:.1} {}", v, units[i])
    }
}

fn main() {
    let state_file = match std::env::var("HOME") {
        Ok(h) => format!("{}/.cache/com.ahmed.netmon.state", h),
        Err(_) => return,
    };
    let now = Instant::now();
    let (rx, tx) = read_totals();

    let prev: Option<(u64, u64)> = fs::read_to_string(&state_file)
        .ok()
        .and_then(|s| {
            let mut it = s.trim().split_whitespace();
            let r = it.next()?.parse().ok()?;
            let t = it.next()?.parse().ok()?;
            Some((r, t))
        });

    match prev {
        Some((prx, ptx)) => {
            let drx = rx.saturating_sub(prx) as f64;
            let dtx = tx.saturating_sub(ptx) as f64;
            let up = format_rate(dtx);
            let down = format_rate(drx);
            println!("{}|{}", up, down);
        }
        None => {
            println!("-- --");
        }
    }
    let _ = fs::write(&state_file, format!("{} {}", rx, tx));
    let _ = now;
    let _map: HashMap<String, u64> = HashMap::new();
}
