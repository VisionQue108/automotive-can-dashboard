import sys
import can
import threading
from PyQt5.QtWidgets import QApplication, QWidget
from  PyQt5.QtCore import QTimer
from PyQt5.QtGui import QPainter,QColor,QPen


class VehicleState:
	def __init__(self):
		self.speed = 0
		self.fuel = 0
		self.battery = 0

state = VehicleState()


class Dashboard(QWidget):
	def __init__(self):
		super().__init__()
		
		self.setWindowTitle("Dashboard")
		self.setGeometry(200,200,500,500)
		
		self.timer = QTimer()
		self.timer.timeout.connect(self.update)
		self.timer.start(50)

	def paintEvent(self, event):
		painter = QPainter(self)
		painter.setRenderHint(QPainter.Antialiasing)
		
		self.draw_speedometer(painter)
		self.draw_fuel_gauge(painter)
		self.draw_battery_bar(painter)
	
	def draw_speedometer(self, painter):
		center_x = 250
		center_y = 250
		radius = 150

		pen = QPen(QColor(200, 200, 200), 4)
		painter.setPen(pen)
		painter.drawEllipse(center_x - radius, center_y - radius, radius * 2 , radius * 2)


		#Draw speed needle
		speed_angle = (state.speed / 120) * 270

		painter.save()
		painter.translate(center_x, center_y)
		painter.rotate(-135 + speed_angle)

		pen = QPen(QColor(255, 0, 0), 4)
		painter.setPen(pen)
		painter.drawLine(0, 0, radius - 20, 0)
	
		painter.restore()
	def draw_fuel_gauge(self, painter):
		center_x = 100
		center_y = 400
		radius = 60

		pen  = QPen(QColor(180, 180, 180), 3)
		painter.setPen(pen)
		painter.drawEllipse(center_x - radius,center_y - radius,radius * 2,radius * 2)

		fuel_angle = (state.fuel / 100) * 180

		painter.save()
		painter.translate(center_x, center_y)
		painter.rotate(-90 + fuel_angle)

		pen = QPen(QColor(255,165,0), 3)
		painter.setPen(pen)
		painter.drawLine(0, 0, radius - 10, 0)
		painter.restore()
	
	def draw_battery_bar(self, painter):
		x = 300
		y = 380
		width = 150
		height = 30

		#outline
		pen = QPen(QColor(200, 200, 200), 2)
		painter.setPen(pen)
		painter.drawRect(x, y, width, height)

		#fill
		fill_width = int((state.battery / 100) * width)
		painter.fillRect(x, y, fill_width, height, QColor(0, 255, 0))


def can_listener():
	bus = can.interface.Bus(channel='vcan0', bustype='socketcan')
	while True:
		msg = bus.recv()

		if msg.arbitration_id == 0x100:
			state.speed = msg.data[0]
		elif msg.arbitration_id == 0x102:
			state.fuel = msg.data[0]
		elif msg.arbitration_id == 0x101:
			state.battery = msg.data[0]

if __name__ == "__main__":
	app = QApplication(sys.argv)
	
	window = Dashboard()
	window.show()

	thread = threading.Thread(target=can_listener, daemon=True)
	thread.start()

	sys.exit(app.exec_())

