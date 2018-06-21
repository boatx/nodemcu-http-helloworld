BAUD_RATE = 9600
SERIAL_PORT = /dev/ttyUSB0
NODEMCU_UPLOAD = nodemcu-uploader
.PHONY: upload
upload:
	$(NODEMCU_UPLOAD) -p $(SERIAL_PORT) -b $(BAUD_RATE) upload src/*.lua src/*.html;
