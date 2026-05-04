import sys
import can
import threading

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlApplicationEngine


# ---------------------------
# Vehicle State Class
# ---------------------------
class Vehicle(QObject):
    speedChanged = pyqtSignal()
    fuelChanged = pyqtSignal()
    batteryChanged = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._speed = 0
        self._fuel = 100
        self._battery = 100

    # -------- SPEED --------
    @pyqtProperty(int, notify=speedChanged)
    def speed(self):
        return self._speed

    def setSpeed(self, value):
        if self._speed != value:
            self._speed = value
            self.speedChanged.emit()

    # -------- FUEL --------
    @pyqtProperty(int, notify=fuelChanged)
    def fuel(self):
        return self._fuel

    def setFuel(self, value):
        if self._fuel != value:
            self._fuel = value
            self.fuelChanged.emit()

    # -------- BATTERY --------
    @pyqtProperty(int, notify=batteryChanged)
    def battery(self):
        return self._battery

    def setBattery(self, value):
        if self._battery != value:
            self._battery = value
            self.batteryChanged.emit()


vehicle = Vehicle()


# ---------------------------
# CAN Listener Thread
# ---------------------------
def can_listener():
    bus = can.interface.Bus(channel='vcan0', bustype='socketcan')

    while True:
        msg = bus.recv()

        if msg.arbitration_id == 0x100:
            vehicle.setSpeed(msg.data[0])

        elif msg.arbitration_id == 0x101:
            vehicle.setBattery(msg.data[0])

        elif msg.arbitration_id == 0x102:
            vehicle.setFuel(msg.data[0])


# ---------------------------
# Main Application
# ---------------------------
if __name__ == "__main__":
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()

    # Expose to QML
    engine.rootContext().setContextProperty("backend", vehicle)

    # Load UI
    engine.load("dashboard.qml")

    # Start CAN thread
    threading.Thread(target=can_listener, daemon=True).start()

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
