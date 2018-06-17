# nodemcu-http-helloworld
Simple http server displaying page with button which allows to switch diode on and off

## Requirements
* NodeMCU ESP8266
* nodemcu-uploader (or other method to upload files)

## Usage

Create credentials file and update it with your WIFI password and ssid
```bash
cp src/credentials.template src/credentials.lua
```

Install nodemcu-uploader
```bash
pip install nodemcu-uploader --user
```

Upload files to NodeMCU
```bash
make upload SERIAL_PORT=<serial_port>
```

Enter ip addres of node mcu in web browser.
