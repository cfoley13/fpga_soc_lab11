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

// Hardware Constants
#define FIFO_BASE_ADDR 0x43C10000
#define REG_DATA       0   // Offset for 0x43C10000
#define REG_STATUS     1   // Offset for 0x43C10004
#define MAP_SIZE       4096

// Packet Constants
#define SAMPLES_PER_PKT 256
#define DATA_BYTES      1024 // 256 * 4 bytes (I=16bit, Q=16bit)
#define PKT_SIZE        (4 + DATA_BYTES) // 1028 bytes total

typedef struct {
    uint32_t seq_num;
    int16_t samples[SAMPLES_PER_PKT * 2]; // Interleaved I and Q
} radio_packet_t;

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <Destination IP> <Port> <r/f>\n", argv[0]);
        return -1;
    }

    char *dest_ip = argv[1];
    int dest_port = atoi(argv[2]);
    char mode = argv[3][0];
    if (mode != 'r' && mode != 'f'){
        printf("invalid arguement, 'r' for real packets, 'f' for fake.\n");
        return(-1);
    }

    // mem map
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("Could not open /dev/mem");
        return -1;
    }

    uint32_t *fifo_ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, FIFO_BASE_ADDR);
    if (fifo_ptr == MAP_FAILED) {
        perror("mmap failed");
        return -1;
    }

    // udp socket
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(dest_port);
    servaddr.sin_addr.s_addr = inet_addr(dest_ip);

    // main loop
    radio_packet_t packet;
    packet.seq_num = 0;
    
    printf("Sending %s packets to %s:%d...\n", (mode == 'r' ? "REAL" : "FAKE"), dest_ip, dest_port);
    if(mode == 'r'){ // send real packets
        while (1) {
            // Collect 256 samples
            for (int i = 0; i < SAMPLES_PER_PKT; i++) {
                // Wait for FIFO to have data (Status Reg: 1 is empty, 0 is not empty)
                while (fifo_ptr[REG_STATUS] & 0x1) {
                    // usleep(1);
                    // Busy wait or usleep(1) to save CPU
                }
                // Read 32-bit sample from FIFO (High 16 bits = Q, Low 16 bits = I)
                uint32_t raw_data = fifo_ptr[REG_DATA];
                // Little Endian IQ packing
                packet.samples[i*2]     = (int16_t)(raw_data & 0xFFFF);        // I
                packet.samples[i*2 + 1] = (int16_t)((raw_data >> 16) & 0xFFFF); // Q
            }

            // Send the 1028 byte packet
            if (sendto(sock, &packet, PKT_SIZE, 0, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
                perror("UDP send failed");
                break;
            }

            packet.seq_num++;
        }
    }
    if(mode == 'f'){ // send fake packets
	uint16_t imag = 0xABCD;
	uint16_t real = 0xEF01;
        while (1) {
            // Collect 256 samples
            for (int i = 0; i < SAMPLES_PER_PKT; i++) {
                // Wait for FIFO to have data (Status Reg: 1 is empty, 0 is not empty)
                // Little Endian IQ packing
                packet.samples[i*2]     = imag; // I
                packet.samples[i*2 + 1] = real; // Q
                imag++;
                real++;
            }

            // Send the 1028 byte packet
            if (sendto(sock, &packet, PKT_SIZE, 0, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
                perror("UDP send failed");
                break;
            }

            packet.seq_num++;
            usleep(5243); // to keep ~48.828khz pace
        }
    }
    // Cleanup
    munmap(fifo_ptr, MAP_SIZE);
    close(mem_fd);
    close(sock);
    return 0;
}
