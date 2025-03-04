# iLock Pro

Project SEM2 - FPT jetking - CHIP DESIGN - Team H4T:
- Võ Nhật Trường
- Trần Ngọc Thắng
- Nguyễn Bách Thông
- Nguyễn Chí Tâm
- Đặng Hữu Thái Hòa

## 1. Giới thiệu
- Hệ thống kiểm soát truy cập bằng thẻ **RFID** thiết kế trên board FPGA (ZuBoard 1CG).
- Tích hợp nhiều giao thức truyền nhận dữ liệu:
  + FPGA <= (**UART**) => ESP8266
  + FPGA <= (**I2C**) => LCD
  + FPGA <= (**SPI**) => RC522
  + FPGA <= (**PWM**) => Servo Motor
  + FPGA <= (**FM**) => Buzzer
- Chức năng nổi bật:
  + Kiểm soát truy cập bằng thẻ RFID.
  + Tự động Lock hệ thống khi quét thẻ sai 3 lần.
  + Điều khiển qua Cloud ThingsBoard: lưu dấu lịch sử, Lock hoặc Unlock hệ thống.

## 2. Hardware schematic

![Hardware schematic](./images/schematic_hardware_png.png)


## 3. Block Diagram

![project schematic](./images/project_schematic.png)


## 4. Block Diagram - top module

![Block diagram](./images/block_diagram_top.png)
