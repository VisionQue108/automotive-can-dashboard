import can
import time

bus = can.interface.Bus(channel='vcan0', bustype='socketcan')

speed = 0
battery = 100
fuel = 100

print("Starting vehicle simulator...")

while True:
    # Speed ECU (0x100)
    msg_speed = can.Message(
        arbitration_id=0x100,
        data=[speed],
        is_extended_id=False
    )
    bus.send(msg_speed)

    # Battery ECU (0x101)
    msg_battery = can.Message(
        arbitration_id=0x101,
        data=[battery],
        is_extended_id=False
    )
    bus.send(msg_battery)

    # Fuel ECU (0x102)
    msg_fuel = can.Message(
        arbitration_id=0x102,
        data=[fuel],
        is_extended_id=False
    )
    bus.send(msg_fuel)

    print(f"TX → speed={speed}, battery={battery}, fuel={fuel}")

    speed += 5
    if speed > 120:
        speed = 0

    battery -= 1
    if battery < 10:
        battery = 100

    fuel -= 1
    if fuel < 5:
        fuel = 100

    time.sleep(1)
