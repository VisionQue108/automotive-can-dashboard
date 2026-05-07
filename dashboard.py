import sys
import can 
from PyQt5.QtWidgets import QApplication,QWidget,QLabel,QVBoxLayout
from PyQt5.QtCore import QTimer

class Dashboard(QWidget):
	def __init__(self):
		super().__init__()
		
		self.setWindowTitle("Vehicle Dashboard")
		self.setGeometry(100, 100, 300, 200)

		self.speed_label = QLabel("Speed : 0 km/hr")
		self.battery_label = QLabel("Battery: 0%")
		self.fuel_label=QLabel("Fuel: 0%")
	

		layout = QVBoxLayout()
		layout.addWidget(self.speed_label)
		layout.addWidget(self.battery_label)
		layout.addWidget(self.fuel_label)
		self.setLayout(layout)

		#Connect to CAN bus
		self.bus = can.interface.Bus(channel='vcan0', bustype='socketcan')

		#Timer to update UI
		self.timer = QTimer()
		self.timer.timeout.connect(self.read_can)
		self.timer.start(200)  #200ms refresh

	def read_can(self):
		msg = self.bus.recv(timeout=0.01)
		if msg is None:
			return
		
		can_id = msg.arbitration_id
		data = msg.data

		if can_id == 0x100:
			self.speed_label.setText(f"Speed: {data[0]} km/h")
			
		elif can_id == 0x101:
			self.battery_label .setText(f"Battery: {data[0]}%")
		
		elif can_id == 0x102:
			self.fuel_label.setText(f"Fuel: {data[0]}%")

if __name__ == "__main__":
	app = QApplication(sys.argv)
	window = Dashboard()
	window.show()
	sys.exit(app.exec_())

