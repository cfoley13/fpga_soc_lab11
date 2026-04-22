#! /usr/bin/python3
import subprocess
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
action: str = form.getvalue('action', '')

# --- 1. Process ADC/Tune Frequency ---
if adc_freq_hz >= 0:
    # Calculate Phase Increment: (Freq * 2^32) / 125MHz
    # Using // for integer division
    adc_inc = (adc_freq_hz * (2**27)) // 125000000
    # Execute the hardware write
    # Assuming ADC Phase Inc register is at 0x43C00000
    os.system(f"devmem {ADC_FREQ_REG:#X} w {adc_inc}")
    print(f"Set Fake ADC to {adc_freq_hz} Hz (Register Value: {adc_inc:#X})<br>")

if tune_freq_hz >= 0:
    tune_inc = (tune_freq_hz * (2**27)) // 125000000
    # Assuming Tuning Phase Inc register is at 0x43C00004
    time.sleep(0.1)
    os.system(f"devmem {TUNE_FREQ_REG:#X} w {tune_inc}")
    print(f"Set Tune Freq to {tune_freq_hz} Hz (Register Value: {tune_inc:#X})<br>")

# --- 2. Manage the Process ---
# Only touch the background streamer if we aren't doing a special one-off test
if action != "Run 10s Milestone":
    cmd_string = f"udp_pack.exe {ip_addr} {udp_port} {mode}"
    running = os.system(f"pgrep -x -f '{cmd_string}' > /dev/null") == 0
    if not running:
        exe_path = "/run/media/rootfs-mmcblk0p2/src_lab11/web/cgi-bin/udp_pack.exe"
        os.system("killall -q udp_pack.exe")
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

# --- 4. Milestones :) ---
# if action == "Run 10s Milestone":
if "Milestone" in action:
    if "10" in action:
        m_path = "/run/media/rootfs-mmcblk0p2/src_lab11/web/cgi-bin/10s_test"
        t_str = 10
    else:
        m_path = "/run/media/rootfs-mmcblk0p2/src_lab11/web/cgi-bin/1s_test"
        t_str = 1

    os.system("killall -q udp_pack.exe")
    print(f"<h2>Running {t_str}s Milestone Test...</h2>")
    print("Flushing FIFO...<br>")
    os.system(f"devmem {FIFO_RESET_REG:#X} w 1")
    os.system(f"devmem {FIFO_RESET_REG:#X} w 0")
    print(f"<p>Please wait {t_str} seconds for results...</p>")
    sys.stdout.flush()  # Force text to show up before the test starts
    try:
        # This captures both stdout and stderr
        output = subprocess.check_output([m_path, ip_addr, udp_port], stderr=subprocess.STDOUT)
        print("<pre style='background: #eee; padding: 10px; border: 1px solid #ccc;'>")
        print(output.decode('utf-8'))  # This prints the actual test results to the web page
        print("</pre>")
    except subprocess.CalledProcessError as e:
        print(f"<p style='color:red;'>Error running milestone: {e.output.decode('utf-8')}</p>")

print("<p><a href='../index.html'>Back to Control Page</a></p>")
print("</body></html>")
