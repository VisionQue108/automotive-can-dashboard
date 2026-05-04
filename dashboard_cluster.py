import sys
import can
import threading
from PyQt5.QtWidgets import (
	QApplication,
	QWidget,
	QLabel,
	QVBoxLayout,
	QProgressBar
 )
from PyQt5.QtCore import QTimer


class VehicleState:
	def __init__(self):
		self.speed=0
		self.battery = 0
		self.fuel = 0
state = VehicleState()


class Dashboard(QWidget):
	def __init__(self):
		super().__init__()
		
		self.setWindowTitle("Digital Cluster")
		self.setGeometry(200, 200, 400, 300)

		# Labels
		self.speed_label = QLabel("Speed: 0 km/h")

		# Progress bars
		self.speed_bar = QProgressBar()
		self.speed_bar.setMaximum(120)

		self.battery_bar = QProgressBar()
		self.battery_bar.setMaximum(100)

		self.fuel_bar = QProgressBar()
		self.fuel_bar.setMaximum(100)

		
		layout = QVBoxLayout()
		layout.addWidget(self.speed_label)
		layout.addWidget(self.speed_bar)
		layout.addWidget(QLabel("Battery"))
		layout.addWidget(self.battery_bar)
		layout.addWidget(QLabel("Fuel"))
		layout.addWidget(self.fuel_bar)
	
		self.setLayout(layout)

		self.timer = QTimer()
		self.timer.timeout.connect(self.update_ui)
		self.timer.start(100)

	def update_ui(self):
		self.speed_label.setText(f"Speed: {state.speed} km/hr")
		self.speed_bar.setValue(state.speed)
		self.fuel_bar.setValue(state.fuel)
		self.battery_bar.setValue(state.battery)

def can_listener():
	bus = can.interface.Bus(channel='vcan0', bustype='socketcan')

	while True:
		msg = bus.recv()

		if msg.arbitration_id == 0x100:
			state.speed = msg.data[0]
		elif msg.arbitration_id == 0x101 :
			state.battery = msg.data[0]
		elif msg.arbitration_id == 0x102:
			state.fuel = msg.data[0]

if __name__=="__main__":
	app=QApplication(sys.argv)
	
	window=Dashboard()
	window.show()

	thread = threading.Thread(target=can_listener, daemon=True)
	thread.start()

	sys.exit(app.exec_())


#80 line
