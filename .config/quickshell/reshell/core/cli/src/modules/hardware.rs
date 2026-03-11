// cargo imports
use gfxinfo::active_gpu;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicBool, Ordering};
use std::{io::Write, os::unix::net::UnixStream, sync::Arc, thread, time::Duration};
use sysinfo::{Disks, Networks, System};

#[derive(Serialize, Deserialize)]
pub struct SystemStatus {
    pub os: Option<String>,
    pub kernel_version: Option<String>,
    pub os_version: Option<String>,
    pub uptime: Option<u64>,
    pub boot_time: Option<u64>,
    pub cpu: Option<SystemCPU>,
    pub memory: Option<SystemMemory>,
    pub gpu: Option<GpuInfo>,
    pub disks: Option<Vec<SystemDisk>>,
    pub network: Option<Vec<NetworkInterface>>,
}

#[derive(Serialize, Deserialize)]
pub struct SystemCPU {
    pub cpu_architecture: String,
    pub cpu_usage: f32,
    pub cpu_frequency: u64,
    pub cpu_cores: usize,
    pub physical_cores: usize,
}

#[derive(Serialize, Deserialize)]
pub struct SystemMemory {
    pub total_memory: u64,
    pub used_memory: u64,
    pub total_swap: u64,
    pub used_swap: u64,
    pub free_memory: u64,
}

#[derive(Serialize, Deserialize)]
pub struct SystemDisk {
    pub name: String,
    pub total_space: u64,
    pub available_space: u64,
    pub kind: String,
    pub file_system: String,
    pub mount_point: String,
}

#[derive(Serialize, Deserialize)]
pub struct NetworkInterface {
    pub name: String,
    pub received_bytes: u64,
    pub transmitted_bytes: u64,
}

#[derive(Serialize, Deserialize)]
pub struct GpuInfo {
    pub vendor: String,
    pub model: String,
    pub family: String,
    pub device_id: u32,
    pub total_vram: u64,
    pub used_vram: u64,
    pub free_vram: u64,
    pub temperature: f32,
    pub utilization: f32,
}

#[derive(Serialize, Deserialize)]
pub struct PaletteRequest {
    pub paths: Vec<String>,
    #[serde(rename = "type")]
    pub type_: String,
}
pub fn get_hardware_info(mut stream: UnixStream, running: Arc<AtomicBool>) {
    let mut sys = System::new_all();
    let mut disks = Disks::new_with_refreshed_list();
    let mut networks = Networks::new_with_refreshed_list();

    loop {
        if !running.load(Ordering::SeqCst) {
            break;
        }

        sys.refresh_all();
        disks.refresh(true);
        networks.refresh(true);

        let cpu = SystemCPU {
            cpu_architecture: std::env::consts::ARCH.to_string(),
            cpu_usage: sys.global_cpu_usage(),
            cpu_frequency: sys.cpus().get(0).map(|c| c.frequency()).unwrap_or(0),
            physical_cores: System::physical_core_count().unwrap_or(0),
            cpu_cores: sys.cpus().len(),
        };

        let memory = SystemMemory {
            total_memory: sys.total_memory(),
            used_memory: sys.used_memory(),
            free_memory: sys.free_memory(),
            total_swap: sys.total_swap(),
            used_swap: sys.used_swap(),
        };

        let gpudata = active_gpu().expect("Failed to get active GPU");
        let gpuinfo = gpudata.info();

        let gpu = GpuInfo {
            vendor: gpudata.vendor().to_string(),
            model: gpudata.model().to_string(),
            family: gpudata.family().to_string(),
            device_id: *gpudata.device_id(),
            total_vram: gpuinfo.total_vram(),
            used_vram: gpuinfo.used_vram(),
            free_vram: gpuinfo.total_vram() - gpuinfo.used_vram(),
            temperature: gpuinfo.temperature() as f32 / 1000.0,
            utilization: gpuinfo.load_pct() as f32,
        };

        let network = networks
            .iter()
            .map(|(name, data)| NetworkInterface {
                name: name.to_string(),
                received_bytes: data.received(),
                transmitted_bytes: data.transmitted(),
            })
            .collect::<Vec<_>>();

        let disks = disks
            .list()
            .iter()
            .map(|disk| SystemDisk {
                name: disk.name().to_string_lossy().to_string(),
                total_space: disk.total_space(),
                available_space: disk.available_space(),
                kind: format!("{:?}", disk.kind()),
                file_system: disk.file_system().to_string_lossy().to_string(),
                mount_point: disk.mount_point().to_string_lossy().to_string(),
            })
            .collect::<Vec<_>>();

        let system_stats = SystemStatus {
            os: Some(System::name().unwrap_or_else(|| "<unknown>".to_owned())),
            kernel_version: Some(
                System::kernel_version().unwrap_or_else(|| "<unknown>".to_owned()),
            ),
            os_version: Some(System::os_version().unwrap_or_else(|| "<unknown>".to_owned())),
            uptime: Some(System::uptime()),
            boot_time: Some(System::boot_time()),
            cpu: Some(cpu),
            memory: Some(memory),
            gpu: Some(gpu),
            disks: Some(disks),
            network: Some(network),
        };

        let json = serde_json::to_string(&system_stats).unwrap();
        if writeln!(stream, "{}", json).is_err() {
            break;
        }
        thread::sleep(Duration::from_secs(1));
    }
}
