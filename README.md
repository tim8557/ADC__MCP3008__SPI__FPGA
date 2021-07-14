# ADC--MCP3008--FPGA
## MCP3008/MCP3004
MCP3008 is an anolog-to-digital converter. It is used to adapt the anolog siganal and transfrt<br > 
the anolog signal into ten bit digital signal.

<img src="https://github.com/tim8557/ADC--MCP3008--FPGA/blob/main/images/m3008_ic.jpg" width="200" ><br>
<br>
## Interface
The MCP3008/MCP3004 use SPI(Serial Peripheral Interface) to communicate with the FPGA. The picture<br> 
below showed the time we need to comply with for the communication between FPGA and MCP3004/MCP3008.<br>
![image](https://github.com/tim8557/ADC--MCP3008--FPGA/blob/main/images/communication_with_m3008_v2.JPG)

<br>
There are two parameters we need to care about when we communicate with MCP3004/MCP3008.<br>
tSUCS: the time we need to wait for the start of sck when the cs become logic 0.<br>
tCHS: the time we need to wait until the next command start.<br>
<img src="https://github.com/tim8557/ADC--MCP3008--FPGA/blob/main/images/form_time_parameter.JPG" width="500" ><br>

<br>
The form shows the clock frequency under different working voltage for MCP3004/MCP3008.<br>
In our project, we used 5V working voltage for ADC devive, and we set the clock frequency as 2.5 Mhz.
<img src="https://github.com/tim8557/ADC--MCP3008--FPGA/blob/main/images/form_voltage_frequency.JPG" width="500" ><br>

## Time sequence and state machine of FPGA

![image](https://github.com/tim8557/ADC--MCP3008--FPGA/blob/main/images/communication_with_m3008_v2.JPG)
