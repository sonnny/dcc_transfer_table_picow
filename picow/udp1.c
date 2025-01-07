/*
 * send movement to stepper motor
 * 
 * nc -u 192.168.6.152 8080 <enter>
 * move 100 dir 1 <enter>
 * 
 * or
 * 
 * echo 'move 100 dir 1' | netcat -q -1 -u 192.168.6.152 8080 <enter>
 * 
 ************** main.c
 */
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "hardware/i2c.h"
#include "hardware/uart.h"
#include "pico/stdlib.h"
#include "pico/cyw43_arch.h"
#include "lwip/pbuf.h"
#include "lwip/udp.h"
#include "i2c_lib.h"

#define  RCV_FROM_IP IP_ADDR_ANY
#define  RCV_FROM_PORT 8080
#define BUF_SIZE 64

#define STEP 11
#define DIRECTION 10

struct udp_pcb  * rcv_udp_pcb;

void process_command(char *input_string){
	static char arg1[32], arg2[32], arg3[32], arg4[32];
	static char* token;
	token = strtok(input_string, " ");
	strcpy(arg1, token);
	token = strtok(NULL, " ");
	strcpy(arg2, token);
	token = strtok(NULL, " ");
	strcpy(arg3, token);
	token = strtok(NULL, " ");
	strcpy(arg4, token);
	
	gpio_put(DIRECTION, atoi(arg4));
	int limit = atoi(arg2);
	for(int i=0; i<limit; i++){
		gpio_put(STEP, 1); sleep_ms(5);
		gpio_put(STEP, 0); sleep_ms(5);}
		
}
	

void RcvFromUDP(void * arg, struct udp_pcb *pcb, struct pbuf *p, const ip_addr_t*addr,u16_t port)
{
     char *buffer=calloc(p->len+1,sizeof(char));  // use calloc to set all zero in buffer
     strncpy(buffer, (char *)p->payload,p->len);
     buffer[p->len] = '\0';
     process_command(buffer);
     free(buffer);
     pbuf_free(p);
}



int main() {
    int loop=0;
    char buffer[BUF_SIZE];
    extern struct netif gnetif;
    
    stdio_init_all();
    uart_init(uart0,115200);
    gpio_set_function(0, GPIO_FUNC_UART);
    gpio_set_function(1, GPIO_FUNC_UART);
    init_i2c();
    
        gpio_init(DIRECTION); gpio_set_dir(DIRECTION, 1);
    gpio_init(STEP); gpio_set_dir(STEP, 1);
    
    if (cyw43_arch_init()) {
        printf("Init failed!\n");
        return 1;
    }
    cyw43_pm_value(CYW43_NO_POWERSAVE_MODE,200,1,1,10);

    cyw43_arch_enable_sta_mode();

    printf("WiFi ... ");
    if (cyw43_arch_wifi_connect_timeout_ms("SSID", "PASSWORD", CYW43_AUTH_WPA2_AES_PSK, 30000)) {
        printf("failed!\n");
        return 1;
    } else {
        printf("Connected.n");
        //printf("IP: %s\n",ipaddr_ntoa(((const ip_addr_t *)&cyw43_state.netif[0].ip_addr)));
        print_ip(ipaddr_ntoa(((const ip_addr_t *)&cyw43_state.netif[0].ip_addr)));
  }


   rcv_udp_pcb = udp_new();

   err_t err = udp_bind(rcv_udp_pcb,RCV_FROM_IP,RCV_FROM_PORT);
   udp_recv(rcv_udp_pcb, RcvFromUDP,NULL);

    while(1)
    {

     sleep_ms(10);
    cyw43_arch_poll();
    }


    udp_remove(rcv_udp_pcb);
    cyw43_arch_deinit();
    return 0;
}
