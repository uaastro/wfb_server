
import socket
import pymavlink.dialects.v20.ardupilotmega as mavlink2_0

def get_cmd_ln(d_mav,rssi,qlt,pkts,ch,freq):
    
    command_ln = d_mav.command_long_encode(
            target_system=255,        
            target_component=100,     
            command=1058,           
            confirmation=0,         
            param1=rssi,               
            param2=qlt,              
            param3=pkts,               
            param4=ch,               
            param5=freq,               
            param6=0,               
            param7=0                
            )
    return command_ln

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
mav = mavlink2_0.MAVLink(None)

command_long = get_cmd_ln(mav,float(60),float(100),float(328),float(140),float(5700))
print(command_long)
command_long_msg = command_long.pack(mav)
sock.sendto(command_long_msg, ('127.0.0.1',14500))