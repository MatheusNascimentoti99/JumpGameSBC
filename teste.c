#include "linux64.inc"
int main(int argc, const char *argv[])
{
    char buf[16];
    int fd, qtd;
 
    fd = open("/sys/class/gpio/export", O_WRONLY);
    write(fd, "25", 2);
    close(fd);
 
    fd = open("/sys/class/gpio/gpio25/direction", O_WRONLY);
    write(fd, "in", 2);
    close(fd);
 
    for (;;) {
 
        fd = open("/sys/class/gpio/gpio25/value", O_RDONLY);
        qtd = read(fd, buf, sizeof(buf) - 1);
        close(fd);
 
        buf[qtd] = '\0';
 
        if (!strcmp(buf, '1'))
            printf("Botão pressionado!\n");
    }
 
    return 0;
}
