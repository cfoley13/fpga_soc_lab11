#! /usr/bin/python3
import cgi, cgitb
import sys, os
import time

ADC_FREQ_REG = 0x43C0_0000
TUNE_FREQ_REG = 0x43C0_0004
FIFO_RESET_REG = 0x43C1_0008

# Create instance of FieldStorage
form = cgi.FieldStorage()
cgitb.enable()
print("Content-type: text/html")
print()
print("<html><body>")

# Get data from fields
ip_addr: str = form.getfirst('ip_addr', '10.0.0.54')
udp_port: str = form.getfirst('udp_port', '25344')
mode: str = form.getfirst('mode', 'r')  # defaults to 'r'
adc_freq_hz: int = int(form.getvalue('adc_freq_hz', 0))
tune_freq_hz: int = int(form.getvalue('tune_freq_hz', 0))
streaming: str = form.getvalue('streaming')

# --- 1. Process ADC/Tune Frequency ---
if adc_freq_hz:
    # Calculate Phase Increment: (Freq * 2^32) / 125MHz
    # Using // for integer division
    adc_inc = (adc_freq_hz * (2**32)) // 125000000
    # Execute the hardware write
    # Assuming ADC Phase Inc register is at 0x43C00000
    os.system(f"devmem {ADC_FREQ_REG:#X} w {adc_inc}")
    print(f"Set Fake ADC to {adc_freq_hz} Hz (Register Value: {adc_inc:#X})<br>")

if tune_freq_hz:
    tune_inc = (tune_freq_hz * (2**32)) // 125000000
    # Assuming Tuning Phase Inc register is at 0x43C00004
    time.sleep(0.1)
    os.system(f"devmem {TUNE_FREQ_REG:#X} w {tune_inc}")
    print(f"Set Tune Freq to {tune_freq_hz} Hz (Register Value: {tune_inc:#X})<br>")

# --- 2. Manage the Process (IP/Port logic) ---
# Check if a process with THESE EXACT arguments is already running
cmd_string = f"udp_pack.exe {ip_addr} {udp_port} {mode}"
# pgrep -f matches the full command line
running = os.system(f"pgrep -x -f '{cmd_string}' > /dev/null") == 0

if not running:
    # Kill existing udp_pack.exe because settings don't match or it's dead
    os.system("killall -q udp_pack.exe")
    # Start the new one
    exe_path = "/run/media/rootfs-mmcblk0p2/src_lab11/web/cgi-bin/udp_pack.exe"
    os.system(f"{exe_path} {ip_addr} {udp_port} {mode} &")
    print(f"Restarted streamer with target {ip_addr}:{udp_port}<br>")
else:
    print("Streamer settings unchanged; process maintained.<br>")

# --- 3. Process Streaming Checkbox ---
if streaming == "streaming":
    os.system(f"devmem {FIFO_RESET_REG:#X} w 0")
    print("<b>FIFO Reset Register Released: Streaming Active.</b><br>")
else:
    os.system(f"devmem {FIFO_RESET_REG:#X} w 1")
    print("FIFO Reset Active: Streaming Paused.<br>")

print("<p><a href='../index.html'>Back to Control Page</a></p>")
print("</body></html>")
