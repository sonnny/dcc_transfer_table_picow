#ifndef _I2C_LIB_H_
#define _I2C_LIB_H_

#define SSD1306_HEIGHT              64
#define SSD1306_WIDTH               128
#define SSD1306_PAGE_HEIGHT         8
#define SSD1306_NUM_PAGES           (SSD1306_HEIGHT / SSD1306_PAGE_HEIGHT)
#define SSD1306_BUF_LEN             (SSD1306_NUM_PAGES * SSD1306_WIDTH)

void init_i2c(void);
static void WriteString(uint8_t *buf, int16_t x, int16_t y, char *str);
void print_ip(char *str);

#endif
