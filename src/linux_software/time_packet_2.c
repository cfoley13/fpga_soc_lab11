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

// Define the Physical Base Addresses
#define RADIO_BASE_ADDR 0x43C00000
#define FIFO_BASE_ADDR  0x43C10000

// Define the Offsets (Divide the byte offset by 4 for uint32_t indexing)
#define REG_ADC    0    // 0x00 / 4
#define REG_TUNER  1    // 0x04
#define REG_RESET  2    // 0x08
#define REG_TIMER  3    // 0x0C / 4

#define REG_DATA   0    // 0x00 / 4
#define REG_STAT   1    // 0x04 / 4
#define REG_FRST   2    // 0x08 / 4

#define SAMPLES_PER_PKT 256
#define DATA_BYTES      1024 
#define PKT_SIZE        (4 + DATA_BYTES) 
#define MAP_SIZE        4096

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
    // 1. Map the Radio Control block
    uint32_t *radio_ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, RADIO_BASE_ADDR);

    // 2. Map the FIFO block
    uint32_t *fifo_ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, FIFO_BASE_ADDR);

    // udp sock
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(dest_port);
    servaddr.sin_addr.s_addr = inet_addr(dest_ip);

    radio_packet_t packet;
    packet.seq_num = 0;
    
    uint32_t start_cycles = radio_ptr[REG_TIMER];
    uint32_t one_sec_cycles = 125000000; 
    uint32_t current_elapsed = 0;

    printf("Starting Safety Test: 1s duration OR 200 packet limit...\n");

    // The safety loop: checks BOTH time and packet count
    while (current_elapsed < one_sec_cycles && packet.seq_num < 200) {
        
        // 1. Update Hardware Timer
        uint32_t now = radio_ptr[REG_TIMER];
        if (now >= start_cycles) {
            current_elapsed = now - start_cycles;
        } else {
            current_elapsed = (0xFFFFFFFF - start_cycles) + now + 1;
        }

        // 2. Collect 1 packet (256 samples)
        for (int i = 0; i < SAMPLES_PER_PKT; i++) {
            // If the hardware stalls, you can still Ctrl+C this
            int j = 0;
            while (fifo_ptr[REG_STAT] & 0x1){
                j++;
            }; 
            if (j > 0){
                printf("for packet %d, i had to wait %d times\n", packet.seq_num, j);
            }
            
            uint32_t raw_data = fifo_ptr[REG_DATA];
            packet.samples[i*2]     = (int16_t)(raw_data & 0xFFFF);
            packet.samples[i*2 + 1] = (int16_t)((raw_data >> 16) & 0xFFFF);
        }

        sendto(sock, &packet, PKT_SIZE, 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
        packet.seq_num++;
    }

    // Final calculation using the precise hardware time it took to send those packets
    double actual_time = (double)current_elapsed / 125000000.0;
    double actual_fs = (double)(packet.seq_num * 256) / actual_time;

    printf("\n--- Safety Test Results ---\n");
    printf("Exit Reason: %s\n", (packet.seq_num >= 200) ? "Packet Limit Hit" : "Time Limit Hit");
    printf("Packets Sent: %u\n", packet.seq_num);
    printf("Hardware Time: %.4f seconds\n", actual_time);
    printf("Calculated Sample Rate: %.2f Hz\n", actual_fs);

    munmap(fifo_ptr, MAP_SIZE);
    close(mem_fd);
    close(sock);
    return 0;
}