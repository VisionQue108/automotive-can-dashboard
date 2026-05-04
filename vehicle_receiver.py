import can 
import time

bus=can.interface.Bus(channel='vcan0', bustype='socketcan')

speed =0
battery = 100
fuel = 80

print("Listening on vcan0....")

while True:
	#Send Speed
	msg_speed = can.Message(arbitration_id=0x100,data=[speed],is_extended_id=False)
	bus.send(msg_speed)
	
	#Send Battery
	msg_battery = can.Message(arbitration_id=0x101,data=[battery],is_extended_id=False)
	bus.send(msg_battery)

	#Send Fuel
	msg_fuel = can.Message(arbitration_id=0x102,data=[fuel],is_extended_id=False)
	bus.send(msg_fuel)

	print(f"TX -> Speed:{speed} Battery:{battery}% Fuel:{fuel}%")

	speed +=5
	if speed > 120:
		speed = 0
	
	battery -= 1
	if battery < 10:
		battery = 100
	
	fuel -= 1
	if fuel < 5:
		fuel = 80

	time.sleep(1)

