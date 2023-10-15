#!/usr/bin/python3

import socket
import time
import struct

import sys
import select
import tty
import termios

import click


@click.command()
@click.option('--ip', default="127.0.0.1", help='ip to send packets')
@click.option('--port', default=5602, help='udp port')
@click.option('--pksize', default=1024, help='packet size')
@click.option('--pks', default=800, help='bitrate in pkt/s')
@click.option('--lid', default=1, help='link id')
def main(lid,ip, port,pksize,pks):
    # Адрес и порт для отправки пакетов
    UDP_IP = ip
    UDP_PORT = port
    # Размер пакета в байтах
    PACKET_SIZE = pksize
    # Скорость генерации пакетов в байтах в секунду
    BITRATE = pks  # packets/sec
    link_id = lid
    BASE_DELAY=1/BITRATE
    #------------------------------------------------------------------
    # Создаем UDP сокет для отправки пакетов
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # Оставшиеся байты, заполняемые байтом со значением 255
    remaining_bytes = b"\xFF" * (PACKET_SIZE - 4 - 4 - 8)

    time_ls= time.time()
    time_start= time.time()    
    i=0
    # сохраняем начальные настройки терминала

                
    while True:
        i+=1
        # Номер пакета (тип uint32)
        packet_number = i
        # Время отправки пакета (тип double)
        packet_time = time.time()
        # Собираем пакет
        packet = struct.pack("!IId"+str((PACKET_SIZE - 4 - 4 - 8))+"s", link_id, packet_number, packet_time,remaining_bytes)
        # Задержка перед отправкой следующего пакета
        delay_usec=BASE_DELAY-(time.time()-time_ls)
        if delay_usec < 0:
            delay_usec=0
        time.sleep(delay_usec)
        # Отправляем пакет на указанный адрес и порт
                
        sock.sendto(packet, (UDP_IP, UDP_PORT))
        time_ls=time.time() 
            
if __name__ == '__main__':
    main()
