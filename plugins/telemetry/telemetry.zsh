# aporia/plugins/telemetry/telemetry.zsh
# System Intelligence: Dynamic Resource Monitoring

AP_C_LOAD_LOW=${AP_C_LOAD_LOW:-242}   # Subtle Gray
AP_C_LOAD_MED=${AP_C_LOAD_MED:-214}   # Orange
AP_C_LOAD_HIGH=${AP_C_LOAD_HIGH:-161}  # Crimson
_AP_ICO_CPU="󰍛"
_AP_ICO_RAM="󰘚"

# Thresholds
AP_TELEMETRY_CPU_THRESHOLD=${AP_TELEMETRY_CPU_THRESHOLD:-50}
AP_TELEMETRY_RAM_THRESHOLD=${AP_TELEMETRY_RAM_THRESHOLD:-80}

_ap_telemetry_segment() {
  local mode=$1
  local cpu_load=0
  local ram_load=0
  local out=""

  # [1] CPU Load Detection
  local _ap_nproc=1
  if [[ "$OSTYPE" == "darwin"* ]]; then
    _ap_nproc=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
    cpu_load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}' | cut -d. -f1)
  else
    _ap_nproc=$(nproc 2>/dev/null || echo 1)
    cpu_load=$(awk '{print $1}' /proc/loadavg 2>/dev/null | cut -d. -f1)
  fi
  cpu_load=${cpu_load:-0}
  cpu_load=$(( cpu_load * 100 / _ap_nproc ))

  # [2] RAM Load Detection
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local page_size=$(vm_stat 2>/dev/null | grep "page size of" | awk '{print $(NF-1)}')
    local free_pages=$(vm_stat 2>/dev/null | grep "Pages free" | awk '{print $NF}' | tr -d '.')
    local inactive_pages=$(vm_stat 2>/dev/null | grep "Pages inactive" | awk '{print $NF}' | tr -d '.')
    local total_mem=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
    
    if [[ -n $page_size && -n $free_pages && $total_mem -gt 0 ]]; then
      local used_mem=$(( total_mem - (free_pages + ${inactive_pages:-0}) * page_size ))
      ram_load=$(( used_mem * 100 / total_mem ))
    fi
  else
    local total=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
    local avail=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
    if [[ -n $total && -n $avail && $total -gt 0 ]]; then
      ram_load=$(( (total - avail) * 100 / total ))
    fi
  fi
  ram_load=${ram_load:-0}

  # [3] Threshold Check & Rendering
  if [[ $mode == "raw" ]] || (( cpu_load >= AP_TELEMETRY_CPU_THRESHOLD )); then
    local color=$AP_C_LOAD_LOW
    (( cpu_load >= AP_TELEMETRY_CPU_THRESHOLD )) && color=$AP_C_LOAD_MED
    (( cpu_load > 80 )) && color=$AP_C_LOAD_HIGH
    out+="%F{$color}${_AP_ICO_CPU} ${cpu_load}%%%f "
  fi

  if [[ $mode == "raw" ]] || (( ram_load >= AP_TELEMETRY_RAM_THRESHOLD )); then
    local color=$AP_C_LOAD_LOW
    (( ram_load >= AP_TELEMETRY_RAM_THRESHOLD )) && color=$AP_C_LOAD_MED
    (( ram_load > 90 )) && color=$AP_C_LOAD_HIGH
    out+="%F{$color}${_AP_ICO_RAM} ${ram_load}%%%f "
  fi

  echo $out
}

_ap_telemetry_precmd() {
  local seg=$(_ap_telemetry_segment)
  if [[ -n $seg ]]; then
    RPROMPT="${seg}${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_telemetry_precmd
