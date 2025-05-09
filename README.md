# UVM-Test-Bench-For-AXI-Bus
For running the simulations click the below link.
[![EDA Playgroung](https://www.edaplayground.com/img/logo.png?v=2)](https://edaplayground.com/x/TiSD)


## AXI Protocol Overview

The Advanced eXtensible Interface (AXI) protocol is a widely used on-chip communication standard, part of the AMBA (Advanced Microcontroller Bus Architecture) specification from ARM. AXI is designed for high-performance, high-frequency system designs and is commonly used to connect master and slave components within SoCs, FPGAs, and ASICs

Key Features of AXI
- Independent read and write data channels.
- Multiple outstanding transactions and out-of-order completion.
-   Support for burst-based data transfers.
-   Flexible, high-throughput communication between IP cores.

## AXI Channels

AXI defines five independent channels, each with a specific role in managing data and control flow between master and slave devices. Each channel is unidirectional and operates independently, allowing for efficient pipelining and parallelism.
| Channel  Name	| Direction	| Purpose |
|:-----|:--------:|------:|
| Write Address (AW)	|Master → Slave	|Carries write address and control information|
|Write Data (W)	|Master → Slave	|Carries write data|
|Write Response (B)|	Slave → Master|	Returns status of write transactions|
|Read Address (AR)|	Master → Slave	|Carries read address and control information|
Read Data (R)|	Slave → Master	|Returns read data and status|

## AXI Signals and Their Purpose
Each channel consists of a set of signals, typically including address, data, control, and handshake signals. The main signals and their functions are as follows:
### Global Signals

  - ACLK: Global clock signal for synchronizing all operations

  - ARESETn: Global active-low reset signal

### Write Address Channel (AW)

  - AWADDR: Write address

  - AWLEN: Burst length

  -  AWSIZE: Size of each transfer

  - AWBURST: Burst type

  - AWVALID: Indicates address/control info is valid

  - AWREADY: Indicates slave can accept address/control info

### Write Data Channel (W)

  - WDATA: Write data

  - WSTRB: Byte lane strobes (which bytes are valid)

  - WLAST: Indicates last transfer in a burst

  - WVALID: Indicates data is valid

  - WREADY: Indicates slave can accept data

### Write Response Channel (B)

  - BRESP: Write response (status)

  - BVALID: Indicates response is valid

  -  BREADY: Indicates master can accept response

### Read Address Channel (AR)

  - ARADDR: Read address

  - ARLEN: Burst length

  - ARSIZE: Size of each transfer

  -  ARBURST: Burst type

  -  ARVALID: Indicates address/control info is valid

  -  ARREADY: Indicates slave can accept address/control info

### Read Data Channel (R)

  - RDATA: Read data

  - RRESP: Read response (status)

  -  RLAST: Indicates last transfer in a burst

  -  RVALID: Indicates data is valid

  -  READY: Indicates master can accept data

## AXI Handshake Mechanism

Every AXI channel uses a handshake mechanism based on two signals: VALID and READY:

  - The source (sender) asserts the xVALID signal when data or control information is available.

  -  The destination (receiver) asserts the xREADY signal when it is ready to accept the information.

  -   Data transfer (a "beat") occurs only when both xVALID and xREADY are high on the same clock edge.

This handshake allows both the source and destination to control the flow of data, enabling flexible and efficient communication. The source must keep xVALID asserted until the handshake is complete (i.e., until xREADY is also high)
