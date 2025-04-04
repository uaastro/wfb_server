#!/usr/bin/python3
import socket
import struct
import click
import zfec

def blocks_decoder(blocks: list) -> list:
    decoded_blocks = []
    for block in blocks:
        cblock_size = len(block)
        block_size, data= struct.unpack("!I"+str((cblock_size - 4))+"s", block)
        decoded_block, add_block = struct.unpack(str(block_size)+"s"+str(len(data) - block_size)+"s", data)
        decoded_blocks.append(decoded_block)
    return decoded_blocks

def fec_decode(d_k,d_m,bloks: list,b_indexes: list) -> list:
    decoder = zfec.Decoder(d_k, d_m)
    #print ('k: ',d_k,'m: ',d_m)
    #print (b_indexes)
    #print ()
    try:
        decoded_blocks = decoder.decode(bloks,b_indexes)
    except Exception as e:
        print(e)
        decoded_blocks = []            
    return decoded_blocks    

@click.command()
@click.option('--mpkts', default=2048, help='udp max pkt size def: 2048')
@click.option('--ip_rx', default='0.0.0.0', help='ip of sorce stream def: 0.0.0.0')
@click.option('--port_rx', default=7700, help='port of source stream def: 7700')
@click.option('--ip_tx', default='127.0.0.1', help='ip of destination host def: 127.0.0.1')
@click.option('--port_tx', default=7800, help='port of destination hosts def: 7800')

def main(mpkts,ip_rx,port_rx,ip_tx,port_tx):

    #--init--
    sock_tx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    sock_rx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock_rx.bind((ip_rx, port_rx))

    print("udp_fec_rx started...")
    print(f"rx: {ip_rx} : {port_rx}")
    print(f"tx: {ip_tx} : {port_tx}")
    
    # ====== RX ======

    encoded_fragments = []
    indexes = []
    ring_rx_block, addr = sock_rx.recvfrom(mpkts)
        
    rx_ring_block_size = len(ring_rx_block)
    b_rb_id, b_block_number, b_k, b_m, encoded_block = struct.unpack("!IIII"+str((rx_ring_block_size - 16))+"s", ring_rx_block)
    rb_id = b_rb_id
    k=b_k
    m=b_m
    blocks_counter = 0

    while True:

        while (rb_id == b_rb_id):
            
            if (blocks_counter < k):
                encoded_fragments.append(encoded_block)
                indexes.append(b_block_number)
                #print('block added')
            #print ('rb_id: ',b_rb_id, 'block_number: ',b_block_number,'k: ', b_k,'m: ', b_m, 'blocks_counter: ',blocks_counter)
            
            if ((blocks_counter+1) == k):
                #print ('\nfec decoding....')
                #print('\n',encoded_fragments)
                #print('\n',indexes)

                decoded_data = fec_decode(k,m,encoded_fragments,indexes)
                #print('\n',decoded_data)

                decoded_blocks = blocks_decoder(decoded_data)
                #print ('decoded blocks: ',decoded_blocks)

                for tx_block in decoded_blocks:
                    sock_tx.sendto(tx_block,(ip_tx, port_tx))
                    #print(tx_block)

            ring_rx_block, addr = sock_rx.recvfrom(mpkts)
        
            rx_ring_block_size = len(ring_rx_block)
            b_rb_id, b_block_number, b_k, b_m, encoded_block = struct.unpack("!IIII"+str((rx_ring_block_size - 16))+"s", ring_rx_block)
            k=b_k
            m=b_m
            blocks_counter += 1

        #preparing for next rx_ring
        encoded_fragments = []
        indexes = []
        rb_id = b_rb_id
        blocks_counter = 0

if __name__ == '__main__':
    main()

