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
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local loadavg=$(sysctl -n vm.loadavg 2>/dev/null)
    [[ -n $loadavg ]] && cpu_load=$(echo $loadavg | awk '{print $2}' | cut -d. -f1)
    local nproc=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
    cpu_load=$(( cpu_load * 100 / nproc ))
  else
    cpu_load=$(awk '{print $1}' /proc/loadavg 2>/dev/null | cut -d. -f1)
    local nproc=$(nproc 2>/dev/null || echo 1)
    cpu_load=$(( cpu_load * 100 / nproc ))
  fi
  cpu_load=${cpu_load:-0}

  # [2] RAM Load Detection
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local page_size=$(vm_stat 2>/dev/null | awk '/page size of/{print $(NF-1)}')
    local free=$(vm_stat 2>/dev/null | awk '/Pages free/{print $NF}' | tr -d '.')
    local inactive=$(vm_stat 2>/dev/null | awk '/Pages inactive/{print $NF}' | tr -d '.')
    local total=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
    
    if [[ -n $page_size && -n $free && $total -gt 0 ]]; then
      local used=$(( total - (free + ${inactive:-0}) * page_size ))
      ram_load=$(( used * 100 / total ))
    fi
  else
    local total=$(awk '/MemTotal/{print $2}' /proc/meminfo 2>/dev/null)
    local avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
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

  echo "${out#" "}"
}

# Register with Aporia's async engine instead of a sync precmd hook
if (( $+functions[aporia_register_async] )); then
  aporia_register_async "telemetry" "_ap_telemetry_segment"
else
  # Fallback for older theme versions
  autoload -Uz add-zsh-hook
  _ap_telemetry_precmd() {
    local seg=$(_ap_telemetry_segment)
    [[ -n $seg ]] && RPROMPT="${seg}${RPROMPT:-}"
  }
  add-zsh-hook -d precmd _ap_telemetry_precmd 2>/dev/null
  add-zsh-hook precmd _ap_telemetry_precmd
fi
