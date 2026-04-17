#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define FIFO_BASE_ADDR 0x43C10000
#define REG_DATA       0   
#define REG_STATUS     1   
#define REG_TIMER      3    // slv_reg3: 125MHz timer
#define MAP_SIZE       4096

#define SAMPLES_PER_PKT 256
#define DATA_BYTES      1024 
#define PKT_SIZE        (4 + DATA_BYTES) 

typedef struct {
    uint32_t seq_num;
    int16_t samples[SAMPLES_PER_PKT * 2]; 
} radio_packet_t;

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <Destination IP> <Port>\n", argv[0]);
        return -1;
    }

    char *dest_ip = argv[1];
    int dest_port = atoi(argv[2]);

    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    uint32_t *fifo_ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, FIFO_BASE_ADDR);

    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(dest_port);
    servaddr.sin_addr.s_addr = inet_addr(dest_ip);

    radio_packet_t packet;
    packet.seq_num = 0;
    
    uint32_t start_cycles, end_cycles, current_cycles;
    uint32_t ten_sec_in_cycles = 10 * 125000000; // 1.25 billion cycles
    
    printf("Sending packets to %s:%d for exactly 10 seconds of FPGA time...\n", dest_ip, dest_port);
    
    start_cycles = fifo_ptr[REG_TIMER];
    
    while (1) {
        // Check hardware timer
        current_cycles = fifo_ptr[REG_TIMER];
        uint32_t elapsed;
        if (current_cycles >= start_cycles) {
            elapsed = current_cycles - start_cycles;
        } else {
            elapsed = (0xFFFFFFFF - start_cycles) + current_cycles + 1;
        }

        if (elapsed >= ten_sec_in_cycles) {
            end_cycles = current_cycles;
            break;
        }

        // Collect 1 packet
        for (int i = 0; i < SAMPLES_PER_PKT; i++) {
            while (fifo_ptr[REG_STATUS] & 0x1); // Hardware throttle
            uint32_t raw_data = fifo_ptr[REG_DATA];
            packet.samples[i*2]     = (int16_t)(raw_data & 0xFFFF);
            packet.samples[i*2 + 1] = (int16_t)((raw_data >> 16) & 0xFFFF);
        }

        sendto(sock, &packet, PKT_SIZE, 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
        packet.seq_num++;
    }

    double actual_fs = (double)(packet.seq_num * SAMPLES_PER_PKT) / 10.0;

    printf("\n--- 10s Hardware Benchmark Results ---\n");
    printf("Total Packets Sent: %u\n", packet.seq_num);
    printf("Total Samples Sent: %u\n", packet.seq_num * SAMPLES_PER_PKT);
    printf("Calculated Sample Rate: %.3f Hz\n", actual_fs);
    printf("Target Sample Rate: 48828.125 Hz\n");
    
    if (packet.seq_num > 1900 && packet.seq_num < 1915) {
        printf("VERDICT: Hardware is pulsing at the correct rate.\n");
    } else if (packet.seq_num > 2000) {
        printf("VERDICT: Hardware is producing data TOO FAST.\n");
    } else {
        printf("VERDICT: Hardware is producing data TOO SLOW or dropping packets.\n");
    }

    munmap(fifo_ptr, MAP_SIZE);
    close(mem_fd);
    close(sock);
    return 0;
}