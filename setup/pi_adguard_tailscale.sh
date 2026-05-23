#!/usr/bin/env bash
#
# Sets up a Raspberry Pi as a Tailscale node running AdGuard Home.
# Idempotent: re-running is a no-op if everything is already configured.
# Pass --force to re-seed the AdGuard YAML (the AdGuard binary itself is
# never reinstalled by this script — the upstream installer refuses to run
# over an existing install).
#
# Usage (run on the Pi):
#   bash pi_adguard_tailscale.sh           # normal run
#   bash pi_adguard_tailscale.sh --force   # rewrite AdGuard config
#
# Notes / gotchas learned the hard way:
#
# - Tailscale's apt postinst (and `tailscale up` without --accept-dns=false)
#   takes over /etc/resolv.conf, pointing it at MagicDNS (100.100.100.100).
#   If MagicDNS isn't healthy yet, clearnet DNS dies and apt/curl break
#   mid-script. Fix: `tailscale set --accept-dns=false` + write a static
#   /etc/resolv.conf with public DNS (1.1.1.1, 9.9.9.9).
#
# - Ubuntu ships ufw enabled with only :22 open. Tailnet clients (phones,
#   laptops) can't reach the Pi's DNS or HTTP until you `ufw allow in on
#   tailscale0`. configure_firewall() handles this idempotently.
#
# - Tailscale admin → DNS → Global nameservers: the IP here MUST match the
#   Pi's tailnet IP exactly. Lost time once to a typo (100.74.161.15 vs the
#   real 100.108.137.15). MagicDNS forwards clearnet queries to whatever IP
#   is configured, and if that IP is unreachable, every query times out and
#   every device "loses internet" while on Tailscale. Verify with
#   `tailscale status | grep <pi-hostname>`.
#
# - The AdGuard upstream installer refuses to reinstall over an existing
#   install (-r/-u flags required). install_adguard() treats "binary
#   present" as success regardless of --force; only the YAML is re-seeded.
#
# - On macOS, the Homebrew `tailscale` CLI talks to /var/run/tailscaled.sock
#   which doesn't exist when Tailscale is installed via the App Store / GUI
#   app. Use `/Applications/Tailscale.app/Contents/MacOS/Tailscale` for
#   CLI access on a Mac.
#
# - systemd-resolved's DNS stub also binds :53 — must be disabled (drop-in
#   with DNSStubListener=no) BEFORE the AdGuard installer runs its port-53
#   sanity check.
#
# - The Bypass Paywalls Clean filter included in seed_adguard_config
#   provides only paywall-tracker blocking at the DNS level (the network
#   rule subset). Cosmetic and scriptlet rules need a browser-level
#   content blocker: on iPhone, either Brave (Settings -> Shields &
#   Privacy -> Content Filtering -> Add Filter By URL) or AdGuard for
#   iOS (Safari content blocker). Add the same URL there.
#
# - BPC URL mirror choice: we use GitFlic because (a) the GitHub mirror
#   (bpc-clone/...) currently 404s for this file and the parent project
#   has been DMCA'd repeatedly, and (b) GitLab returns 403 on raw
#   downloads of this project. GitFlic is the maintainer's canonical
#   source. If GitFlic ever becomes unreachable, check the maintainer
#   (magnolia1234) for a new mirror.

set -euo pipefail

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
	FORCE=1
	shift
fi

# ---------- constants ----------
RESOLVED_DROPIN="/etc/systemd/resolved.conf.d/adguard.conf"
RESOLV_CONF="/etc/resolv.conf"
ADGUARD_DIR="/opt/AdGuardHome"
ADGUARD_YAML="$ADGUARD_DIR/AdGuardHome.yaml"
SSHD_DROPIN="/etc/ssh/sshd_config.d/99-hardening.conf"
TZ_TARGET="Europe/Madrid"
UPSTREAMS=("1.1.1.1" "9.9.9.9")
# System hostname to apply. Override at invocation time:
#   TARGET_HOSTNAME=mypi bash pi_adguard_tailscale.sh
TARGET_HOSTNAME="${TARGET_HOSTNAME:-amorodo}"

if [[ $EUID -eq 0 ]]; then
	SUDO=""
else
	SUDO="sudo"
fi

step() {
	echo
	echo "==> $*"
}

# ---------- preflight ----------
check_environment() {
	step "Checking environment"

	if [[ "$(uname -s)" != "Linux" ]]; then
		echo "This script only runs on Linux. Detected: $(uname -s)"
		exit 1
	fi

	local arch
	arch="$(uname -m)"
	case "$arch" in
		aarch64|arm64|armv7l|armv6l) ;;
		*)
			echo "Unsupported architecture: $arch (expected arm/aarch64)"
			exit 1
			;;
	esac

	if ! command -v apt-get >/dev/null; then
		echo "apt-get not found. This script expects Debian/Raspberry Pi OS."
		exit 1
	fi

	if ! command -v systemctl >/dev/null; then
		echo "systemctl not found. This script expects a systemd-based system."
		exit 1
	fi

	if [[ -z "$SUDO" ]]; then
		echo "Running as root."
	elif ! command -v sudo >/dev/null; then
		echo "Not root and sudo not installed. Cannot proceed."
		exit 1
	fi
}

check_network() {
	step "Checking network"
	# Use raw IP (1.1.1.1) so this check doesn't depend on DNS — DNS may be
	# broken at this point (e.g. tailscaled took over /etc/resolv.conf and
	# isn't healthy). DNS gets fixed in fix_resolver_before_port53.
	if ! curl -fsI --max-time 5 https://1.1.1.1 >/dev/null; then
		echo "Cannot reach 1.1.1.1. Check upstream connectivity and retry."
		exit 1
	fi
}

# If Tailscale is already installed and is currently managing /etc/resolv.conf,
# disable its DNS management *before* we touch the resolver. Otherwise our
# static resolv.conf will be overwritten by tailscaled within seconds.
disable_tailscale_dns_takeover() {
	if ! command -v tailscale >/dev/null; then
		return
	fi
	# Check resolv.conf for the tailscale marker comment OR the magic IP.
	if grep -q 'generated by tailscale\|100\.100\.100\.100' "$RESOLV_CONF" 2>/dev/null; then
		step "Disabling Tailscale DNS management"
		$SUDO tailscale set --accept-dns=false || true
	fi
}

# ---------- apt prereqs ----------
apt_prereqs() {
	step "Installing apt prerequisites"
	local pkgs=(curl ca-certificates gnupg jq iproute2 dnsutils python3 python3-bcrypt)
	local missing=()
	local p
	for p in "${pkgs[@]}"; do
		if ! dpkg -s "$p" >/dev/null 2>&1; then
			missing+=("$p")
		fi
	done

	local cache="/var/cache/apt/pkgcache.bin"
	local need_update=0
	if [[ "$FORCE" -eq 1 ]]; then
		need_update=1
	elif [[ ! -f "$cache" ]]; then
		need_update=1
	elif [[ $(($(date +%s) - $(stat -c %Y "$cache"))) -gt 3600 ]]; then
		need_update=1
	fi

	if [[ ${#missing[@]} -eq 0 && "$need_update" -eq 0 ]]; then
		echo "All prereqs present and apt cache is fresh. Skipping."
		return
	fi

	if [[ "$need_update" -eq 1 ]]; then
		$SUDO apt-get update -qq
	fi
	if [[ ${#missing[@]} -gt 0 ]]; then
		$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
	fi
}

# ---------- timezone ----------
set_timezone() {
	step "Setting timezone to $TZ_TARGET"
	local current
	current="$(timedatectl show -p Timezone --value 2>/dev/null || echo "")"
	if [[ "$current" == "$TZ_TARGET" ]]; then
		echo "Timezone already $TZ_TARGET. Skipping."
		return
	fi
	$SUDO timedatectl set-timezone "$TZ_TARGET"
}

# ---------- hostname ----------
# Rename the system to $TARGET_HOSTNAME and ensure /etc/hosts has a 127.0.1.1
# entry so sudo and other tools can reverse-resolve the hostname.
set_hostname() {
	step "Setting hostname to $TARGET_HOSTNAME"
	local current
	current="$(hostname)"
	if [[ "$current" == "$TARGET_HOSTNAME" ]] \
		&& grep -qE "^127\.0\.1\.1[[:space:]]+$TARGET_HOSTNAME(\$|[[:space:]])" /etc/hosts; then
		echo "Hostname already $TARGET_HOSTNAME and /etc/hosts is set. Skipping."
		return
	fi
	if [[ "$current" != "$TARGET_HOSTNAME" ]]; then
		$SUDO hostnamectl set-hostname "$TARGET_HOSTNAME"
	fi
	# Ensure /etc/hosts has exactly one 127.0.1.1 line and it points at the
	# target hostname. Replace if present, append otherwise.
	if grep -qE '^127\.0\.1\.1[[:space:]]' /etc/hosts; then
		$SUDO sed -i -E "s|^127\.0\.1\.1[[:space:]].*|127.0.1.1\t$TARGET_HOSTNAME|" /etc/hosts
	else
		echo -e "127.0.1.1\t$TARGET_HOSTNAME" | $SUDO tee -a /etc/hosts >/dev/null
	fi
}

# ---------- resolver / port 53 ----------
# Write a static /etc/resolv.conf pointing at public DNS. Called twice: once
# before AdGuard install (so apt/curl work) and once after Tailscale install
# (since tailscaled likes to take over resolv.conf — we disable that with
# --accept-dns=false, but if it raced ahead we need to restore our file).
write_static_resolv_conf() {
	local tmp
	tmp="$($SUDO mktemp /etc/resolv.conf.new.XXXXXX)"
	{
		echo "# Managed by setup/pi_adguard_tailscale.sh"
		for ns in "${UPSTREAMS[@]}"; do
			echo "nameserver $ns"
		done
		echo "options edns0"
	} | $SUDO tee "$tmp" >/dev/null
	$SUDO chmod 0644 "$tmp"
	$SUDO rm -f "$RESOLV_CONF"
	$SUDO mv "$tmp" "$RESOLV_CONF"
}

# AdGuard needs to bind :53. systemd-resolved's stub listener also uses :53.
# Disable the stub and point /etc/resolv.conf at public DNS *before* installing
# AdGuard so apt and curl keep working through this transition.
fix_resolver_before_port53() {
	step "Freeing port 53 (disabling systemd-resolved stub)"

	local dropin_ok=0
	if [[ -f "$RESOLVED_DROPIN" ]] && grep -q '^DNSStubListener=no' "$RESOLVED_DROPIN"; then
		dropin_ok=1
	fi

	local resolv_ok=0
	if grep -q '^nameserver 1\.1\.1\.1' "$RESOLV_CONF" 2>/dev/null; then
		resolv_ok=1
	fi

	if [[ "$dropin_ok" -eq 1 && "$resolv_ok" -eq 1 && "$FORCE" -eq 0 ]]; then
		echo "Resolver already configured. Skipping."
		return
	fi

	if [[ -e "$RESOLV_CONF" ]]; then
		local backup
		backup="$RESOLV_CONF.bak.$(date +%s)"
		$SUDO cp -a "$RESOLV_CONF" "$backup"
		echo "Backed up $RESOLV_CONF -> $backup"
	fi

	$SUDO mkdir -p "$(dirname "$RESOLVED_DROPIN")"
	$SUDO tee "$RESOLVED_DROPIN" >/dev/null <<EOF
[Resolve]
DNSStubListener=no
DNS=${UPSTREAMS[0]} ${UPSTREAMS[1]}
EOF

	write_static_resolv_conf
	$SUDO systemctl reload-or-restart systemd-resolved || true

	local bound
	bound="$($SUDO ss -lntup 2>/dev/null | awk '$5 ~ /:53$/' || true)"
	if [[ -n "$bound" ]]; then
		echo "Port 53 still has listeners after disabling resolved stub:"
		echo "$bound"
		echo "Aborting before AdGuard install."
		exit 1
	fi
}

# Tailscale's apt postinst can flip /etc/resolv.conf to MagicDNS
# (nameserver 100.100.100.100), which breaks clearnet DNS until the node is
# fully up. After installing Tailscale we tell it not to manage DNS at all
# (--accept-dns=false) and re-assert our static resolv.conf if needed.
reassert_resolv_conf() {
	if ! grep -q '^nameserver 1\.1\.1\.1' "$RESOLV_CONF" 2>/dev/null; then
		step "Re-asserting static /etc/resolv.conf (tailscaled clobbered it)"
		write_static_resolv_conf
	fi
}

# ---------- tailscale ----------
install_tailscale() {
	step "Installing Tailscale"
	if command -v tailscale >/dev/null && [[ "$FORCE" -eq 0 ]]; then
		echo "tailscale already installed. Skipping."
	else
		curl -fsSL https://tailscale.com/install.sh | $SUDO sh
	fi
	$SUDO systemctl enable --now tailscaled
	reassert_resolv_conf
}

tailscale_up() {
	step "Bringing Tailscale up"
	local state
	state="$($SUDO tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null || echo "Unknown")"
	if [[ "$state" == "Running" ]]; then
		echo "Tailscale already running. Syncing settings (accept-dns, hostname)."
		# Idempotent setting flips; harmless if already in this state.
		$SUDO tailscale set --accept-dns=false --hostname="$TARGET_HOSTNAME" || true
	else
		echo "Open the login URL below in your browser to authorize this node:"
		$SUDO tailscale up --ssh=false --accept-routes=false --accept-dns=false --hostname="$TARGET_HOSTNAME"
	fi
	reassert_resolv_conf
}

# ---------- adguard home ----------
install_adguard() {
	step "Installing AdGuard Home"
	# Binary presence is the source of truth. The upstream installer refuses
	# to run over an existing install, so we never invoke it twice. If you
	# want to reinstall the binary, remove /opt/AdGuardHome first or run the
	# upstream installer manually with -r. --force in this script only
	# re-seeds the YAML config; the binary stays put.
	if [[ -x "$ADGUARD_DIR/AdGuardHome" ]]; then
		echo "AdGuard Home already installed at $ADGUARD_DIR. Skipping."
		return
	fi

	# Installer drops the binary in /opt/AdGuardHome and registers a systemd
	# unit. It needs :53 free during its sanity check, so the resolver fixup
	# above must have already happened.
	if ! curl -sSL https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | $SUDO sh -s -- -v; then
		echo "AdGuard install failed. Listeners on :53:"
		$SUDO ss -lntup | awk '$5 ~ /:53$/' || true
		exit 1
	fi
}

# Drop a pre-configured AdGuardHome.yaml so the first-run web wizard is
# skipped. Admin user, upstream DNS (DoT + DoH), and default blocklists are
# baked in. Idempotent: skips if the YAML already exists and is non-empty
# (unless --force, which backs it up first).
seed_adguard_config() {
	step "Pre-seeding AdGuard config"

	if [[ -s "$ADGUARD_YAML" && "$FORCE" -eq 0 ]]; then
		echo "Already configured at $ADGUARD_YAML. Skipping."
		return
	fi

	local user="${ADGUARD_ADMIN_USER:-admin}"
	if [[ -z "${ADGUARD_ADMIN_PASSWORD:-}" ]]; then
		if [[ -t 0 ]]; then
			read -rsp "AdGuard admin password: " ADGUARD_ADMIN_PASSWORD
			echo
		else
			echo "ADGUARD_ADMIN_PASSWORD is not set and stdin is not a TTY."
			echo "Re-run with:  ADGUARD_ADMIN_PASSWORD=... bash $0"
			exit 1
		fi
	fi
	if [[ ${#ADGUARD_ADMIN_PASSWORD} -lt 8 ]]; then
		echo "Password must be at least 8 characters."
		exit 1
	fi

	local hash
	hash="$(P="$ADGUARD_ADMIN_PASSWORD" python3 -c 'import bcrypt, os, sys; sys.stdout.write(bcrypt.hashpw(os.environ["P"].encode(), bcrypt.gensalt(10)).decode())')"
	unset ADGUARD_ADMIN_PASSWORD

	# Stop the service before rewriting; AdGuard rewrites the YAML on shutdown.
	if $SUDO systemctl is-active --quiet AdGuardHome; then
		$SUDO systemctl stop AdGuardHome
	fi

	if [[ -s "$ADGUARD_YAML" ]]; then
		local backup
		backup="$ADGUARD_YAML.bak.$(date +%s)"
		$SUDO cp -a "$ADGUARD_YAML" "$backup"
		echo "Backed up existing config -> $backup"
	fi

	$SUDO tee "$ADGUARD_YAML" >/dev/null <<EOF
http:
  pprof:
    port: 6060
    enabled: false
  address: 0.0.0.0:80
  session_ttl: 720h
users:
  - name: "$user"
    password: "$hash"
auth_attempts: 5
block_auth_min: 15
http_proxy: ""
language: ""
theme: auto
dns:
  bind_hosts:
    - 0.0.0.0
  port: 53
  anonymize_client_ip: false
  ratelimit: 20
  ratelimit_subnet_len_ipv4: 24
  ratelimit_subnet_len_ipv6: 56
  ratelimit_whitelist: []
  refuse_any: true
  upstream_dns:
    - tls://dns.quad9.net
    - https://cloudflare-dns.com/dns-query
  upstream_dns_file: ""
  bootstrap_dns:
    - 1.1.1.1
    - 9.9.9.9
  fallback_dns: []
  upstream_mode: load_balance
  fastest_timeout: 1s
  allowed_clients: []
  disallowed_clients: []
  blocked_hosts:
    - version.bind
    - id.server
    - hostname.bind
  trusted_proxies:
    - 127.0.0.0/8
    - ::1/128
  cache_size: 4194304
  cache_ttl_min: 0
  cache_ttl_max: 0
  cache_optimistic: false
  bogus_nxdomain: []
  aaaa_disabled: false
  enable_dnssec: false
  edns_client_subnet:
    custom_ip: ""
    enabled: false
    use_custom: false
  max_goroutines: 300
  handle_ddr: true
  ipset: []
  ipset_file: ""
  bootstrap_prefer_ipv6: false
  upstream_timeout: 10s
  private_networks: []
  use_private_ptr_resolvers: true
  local_ptr_upstreams: []
  use_dns64: false
  dns64_prefixes: []
  serve_http3: false
  use_http3_upstreams: false
  serve_plain_dns: true
  hostsfile_enabled: true
tls:
  enabled: false
querylog:
  ignored: []
  interval: 24h
  size_memory: 1000
  enabled: true
  file_enabled: true
statistics:
  ignored: []
  interval: 24h
  enabled: true
filters:
  - enabled: true
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
    name: AdGuard DNS filter
    id: 1
  - enabled: true
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt
    name: AdAway Default Blocklist
    id: 2
  - enabled: true
    url: https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt
    name: Bypass Paywalls Clean
    id: 15
whitelist_filters: []
user_rules: []
dhcp:
  enabled: false
filtering:
  blocking_ipv4: ""
  blocking_ipv6: ""
  blocked_services:
    schedule:
      time_zone: $TZ_TARGET
    ids: []
  protection_disabled_until: null
  safe_search:
    enabled: false
  blocking_mode: default
  parental_block_host: family-block.dns.adguard.com
  safebrowsing_block_host: standard-block.dns.adguard.com
  rewrites: []
  safe_fs_patterns: []
  safebrowsing_cache_size: 1048576
  safesearch_cache_size: 1048576
  parental_cache_size: 1048576
  cache_time: 30
  filters_update_interval: 24
  blocked_response_ttl: 10
  filtering_enabled: true
  parental_enabled: false
  safebrowsing_enabled: false
  protection_enabled: true
clients:
  runtime_sources:
    whois: true
    arp: true
    rdns: true
    dhcp: true
    hosts: true
  persistent: []
log:
  enabled: true
  file: ""
  max_backups: 0
  max_size: 100
  max_age: 3
  compress: false
  local_time: false
  verbose: false
os:
  group: ""
  user: ""
  rlimit_nofile: 0
schema_version: 28
EOF
	$SUDO chown root:root "$ADGUARD_YAML"
	$SUDO chmod 0600 "$ADGUARD_YAML"
}

enable_adguard() {
	step "Enabling AdGuardHome service"
	$SUDO systemctl enable --now AdGuardHome

	local tries=0
	while (( tries < 10 )); do
		if $SUDO systemctl is-active --quiet AdGuardHome; then
			echo "AdGuardHome is active."
			return
		fi
		sleep 1
		(( tries++ ))
	done
	echo "AdGuardHome did not become active within 10s."
	$SUDO systemctl status --no-pager AdGuardHome || true
	exit 1
}

# ---------- firewall ----------
# Opens the ports AdGuard needs. Only acts if ufw is installed and active —
# we don't enable ufw ourselves (that's a separate decision). Rules:
#   - trust everything on tailscale0 (so tailnet clients can use DNS/HTTP)
#   - allow LAN to AdGuard's admin UI on :80 and :3000
configure_firewall() {
	step "Configuring firewall (ufw)"
	if ! command -v ufw >/dev/null; then
		echo "ufw not installed. Skipping."
		return
	fi
	if ! $SUDO ufw status | grep -q 'Status: active'; then
		echo "ufw is installed but inactive. Skipping."
		return
	fi

	local lan_cidr
	# Derive LAN CIDR from the primary IP's /24 (e.g. 192.168.1.129 -> 192.168.1.0/24).
	lan_cidr="$(hostname -I | awk '{print $1}' | awk -F. '{printf "%s.%s.%s.0/24", $1, $2, $3}')"

	add_rule() {
		# `ufw` is idempotent already — it prints "Skipping adding existing
		# rule" instead of erroring — but we still want quiet output on reruns.
		local desc="$1"; shift
		if $SUDO ufw "$@" 2>&1 | grep -q '^Rule added'; then
			echo "  added: $desc"
		else
			echo "  ok:    $desc"
		fi
	}

	add_rule "trust tailscale0"                    allow in on tailscale0
	add_rule "LAN ($lan_cidr) -> :3000/tcp"         allow from "$lan_cidr" to any port 3000 proto tcp
	add_rule "LAN ($lan_cidr) -> :80/tcp"           allow from "$lan_cidr" to any port 80 proto tcp
}

# ---------- ssh hardening ----------
harden_ssh() {
	step "Hardening SSH (disable password auth)"

	# Defensive: refuse if the invoking user has no authorized_keys, to avoid
	# locking ourselves out even though the user confirmed key auth works.
	local home
	home="$(eval echo "~${SUDO_USER:-$USER}")"
	local authkeys="$home/.ssh/authorized_keys"
	if [[ ! -s "$authkeys" ]]; then
		echo "No authorized_keys at $authkeys. Refusing to disable password auth."
		return
	fi

	if [[ -f "$SSHD_DROPIN" ]] \
		&& grep -q '^PasswordAuthentication no' "$SSHD_DROPIN" \
		&& grep -q '^KbdInteractiveAuthentication no' "$SSHD_DROPIN"; then
		echo "SSH hardening drop-in already in place. Skipping."
		return
	fi

	$SUDO mkdir -p "$(dirname "$SSHD_DROPIN")"
	$SUDO tee "$SSHD_DROPIN" >/dev/null <<'EOF'
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
	$SUDO chmod 0644 "$SSHD_DROPIN"

	if ! $SUDO sshd -t; then
		echo "sshd config validation failed. Removing drop-in."
		$SUDO rm -f "$SSHD_DROPIN"
		exit 1
	fi

	local unit=""
	for candidate in ssh.service sshd.service; do
		if systemctl list-unit-files "$candidate" >/dev/null 2>&1 \
			&& systemctl list-unit-files "$candidate" 2>/dev/null | grep -qE "^${candidate%.service}\\.service"; then
			unit="${candidate%.service}"
			break
		fi
	done
	if [[ -z "$unit" ]]; then
		echo "Could not find ssh/sshd systemd unit; skipping reload."
		return
	fi
	$SUDO systemctl reload "$unit" || $SUDO systemctl restart "$unit"
}

# ---------- summary ----------
print_summary() {
	step "Done"

	local ts_ip lan_ip adguard_url
	ts_ip="$($SUDO tailscale ip -4 2>/dev/null | head -1 || echo "unknown")"
	lan_ip="$(hostname -I | awk '{print $1}')"

	if [[ -s "$ADGUARD_YAML" ]]; then
		adguard_url="http://${lan_ip}:80"
	else
		adguard_url="http://${lan_ip}:3000  (first-run wizard)"
	fi

	cat <<EOF

================================================================
  Pi setup complete.

  Tailscale IPv4:  $ts_ip
  LAN IPv4:        $lan_ip
  AdGuard admin:   $adguard_url

  Next steps (manual):
    1. Open the AdGuard admin URL above and log in with the
       credentials you set during setup.
    2. In the Tailscale admin console (https://login.tailscale.com/admin/dns):
         - Add nameserver:  $ts_ip
         - Enable "Override local DNS".
    3. From another tailnet device, verify:
         dig @$ts_ip example.com         # should resolve
         dig @$ts_ip doubleclick.net     # should be blocked
    4. (iPhone, Brave browser) Subscribe to BPC inside Brave:
         - Settings -> Shields & Privacy -> Content Filtering
           -> Add Filter By URL.
         - URL: https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt
         - Toggle it on. Restart Brave.
       DNS-level rules already block paywall trackers tailnet-wide;
       this adds BPC's cosmetic rules (overlay hiding) inside Brave.

    5. (iPhone, Safari users only -- skip if using Brave) Same idea
       via AdGuard for iOS:
         - Install AdGuard for iOS from the App Store.
         - Protection -> Safari protection -> Filters -> Custom
           -> Add filter. Use the same URL as step 4.
         - In iOS Settings -> Safari -> Extensions, enable AdGuard's
           four content blockers.

    Hard paywalls (WSJ/FT/Bloomberg) won't break -- they gate
    server-side. Soft paywalls (NYT metering, Tinypass-style, El
    Pais) will improve noticeably.

    6. (Hard paywalls) Build an iOS Shortcut "Archive.ph" in the
       Shortcuts app: input URL -> open
       https://archive.ph/newest/<URL>. Enable "Show in Share Sheet"
       so Brave (and any app) gets a one-tap Share -> Archive.ph
       action. Works on Wi-Fi and cellular, no Pi changes.
================================================================
EOF
}

# ---------- main ----------
check_environment
check_network
disable_tailscale_dns_takeover
apt_prereqs
set_timezone
set_hostname
fix_resolver_before_port53
install_tailscale
tailscale_up
install_adguard
seed_adguard_config
enable_adguard
configure_firewall
harden_ssh
print_summary
