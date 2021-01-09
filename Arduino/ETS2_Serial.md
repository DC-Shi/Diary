# Using Arduino as extented game controller.
Current plan for ETS2 and RW3/Train Simulator. And implemented ETS2 somewhat.


# Version 1
Init version, this is to verify my arduino micro pro(aka. Leonardo) works as desired. 

After searching around for existing libraries, I implemented 6 button layout. And 3 buttons for volume control, 3 buttons for game pad button.

Breadboard layout simplified as below:

Function | Place | Function
-----|-----|----
Volume up | row 18~20 | Gamepad 1(Left window up)
Mute | row 23~25 | Gamepad 2(N/A)
Volume down | row 28~30 | Gamepad 3(Left window down)

Arduino code only.

# Version 2
Since multiple IO pins need for indicating lights and buttons, I found MCP23017 as IO expander. Choose I2C version because I want to use as less pin as possible.

Bought: wires, LEDs, and one chip.

## Version 2.1
Bought: ammeter to show various analog numbers.

Since I decided to buy more for expanding my IOs(in theory 128pin in total), I try to init with address, but compiler says it cannot disambiguate from two constructors, using a explicit type cast `(uint8_t)addr` as workaround. Then I found the board freezed. If init with no argument, it works. After spend another whole day, turns out I only connect 4 pins and it needs 5 pins for MCP23017: VCC, GND, SCL, SDA, RST. RST is what I forgot. Just pulled up RST with 10K resistor works for me. RST is important when init the hardware with address.

## Version 2.2
Bought: another MCP23017 and manually changed the address(A0 to VCC)

Reorganize the breadboard from buttons with 4 buttons + 4 LEDs, choose the correct color to match ETS2.

Thanks community on github for providing SCS clients and libraries. Since I'm C# developer before, I can open the code but it did not compile the dll. After searching around, in order to work with ETS2, I need to download Windows SDK and C++ compiler toolchain(Wow this reminds me old days when @micromath developed Windows kernel hooks). Of course change the architecture from `Any` to `x64` to match game architecture. Haha, I compiled different architectures for some of testPrograms projects and know it need exact architecture to work. Also the `using Newtonsoft;` in C# is need manually download/downgrade to specific version, you can searching around for using Nuget package manager on how to install/fix the package dependency problem.

The data flow like this: ETS2 game -> advancedSDK(dll built by C++ code) -> SCSSdkClient(dll built by C# code) -> my C# program(Get game info and connect serial) -> Arduino(code for receiving and handle LED and buttons)

Wrote: C# client and Arduino C++ code.

## Version 2.3
Bought: relay, additional ammeters.

Ammeters act as RPM, Speed and fuel. And in order to make turning light more realistic, I using relay and connect lights to my relay. Next I found when relay change status, it affect ammeter a lot, so change the VCC to RAW as power source but still not stable(about 5%). Another problem I found it relay control. When sending HIGH to relay pin, it connect to NC, when accept LOW, it connect to NO(Normal Open, light on). So I need to write pin logic with invert for turning lights pins. A few hours later, since I have enough IO pins, use two pin for normal LED and two pin for relay.

This time, 8 buttons and 16 lights, button no function here. Breadboards arranged as: two boards(4 lights with 4 buttons) and one 8-light board.

# Version 3
Bought: 0.96 inch OLED display screen(SSD1306), convex Fresnel lens(f=10mm & f=30mm), mirror

What if I switch the arduino under multiple games? Could I use some light or display to show different button mapping? So I bought screen as start. I found geeks online using customized 6 screen as "screen button" and it need print circuit and 3D print the case, which means long time and large cost, I just buy one and try to display all button/light meaning. I also want to use a convex lens + mirror to map the screen to button top. Waiting a few days for lens+mirror, I setup it up once I received the lens. Actually the display can map on target paper but the char is not clear and light is not strong enough, so this method is proved not working.

Finally OLED screen used as button status indicator. Updating the screen might takes sometime and lag the light response, so I limited the update to multiple button updates per one display update.

# Version 4
Bought: big light-buttons(24mm hole with 33mm square!) and button box. Emergency stop button. Small breadboard(17 row, 170pin), jumper wires and breadboard jumper(840 pieces with 14 lengths!)

Since I have smaller breadboard, I made some logic change to it. Reorganized pins, choose commonly used lights/buttons and move to big button, this used 8 lights + 8 buttons on one chip. Another chip is working as more specific ways.

Light | Light usage | Button
-----------|----------|----------
Yellow | Left turn | `[` for ETS2
Yellow | Right turn | `]` for ETS2
Green | Beam low | `l` for ETS2
Blue | Bean high | `k` for ETS2
Red | Break | `s` for ETS2
White | Reverse | `Ctrl` for ETS2(buggy)
Green | Cruise control | `c` for ETS2
White | Wiper | `p` for ETS2

Note: press `[]` together would lead to hazard mode(double yellow flash)

Remining 16 pins are designed as below:
#pin | Description
-----|------
3 | Volume up, mute, volume down
1 | input from touch button as whether we enter testing mode(local mode)
1 | input from touch button, as wheter we can output a keyboard press.
1 | **[Backspace key]** Emergency button for Train Simulator
1 | **[Q key]** Driver warning (PZB/CTCS)  for Train Simulator
9 | reserved for future/below use
1 | OLED Chip select
6 | 16-channel analog multiplexer CD74HC4067

# Version 5
After spending some about $70, I found actually can buy an Adafruit NeoTrellis M4 as LED buttons, it is also about $70. Item on the road. Searched around about this board, it seems programming with Python is supported. Excellent! I also know Python and writing Python code is not a problem for me. Searching around the a few example code and SDK already included those functionality, so I just to re-write the logic and debugging seems easier. Adafruit did a great job and they published their SDK to let customers(like me) to develop my own project!

# Future plans
With led board, I may need to use the board as multi-functional device. Such as: 
- MIDI synthesizer
- ETS2 buttons(even joypad with 32 keys)
- Railworks, may be hard since I did not found how to work with raildriver64.dll some reference: [TS-Telemetry](https://dutchsims.nl/viewtopic.php?f=55&t=415&p=2630&hilit=raildriver64#p2630), [API Functions](https://rail-sim.de/forum/filebase/entry-download/2898-ts2017-raildriver-and-joystick-interface/?fileID=4287), [TS CLient using DART](https://github.com/tnc1997/dart-train-simulator-client/), [rdip](https://github.com/cheesestraws/rdip)

# Notes:
Now we're progressing to ver5, since most of my previous projects are finished(or abandoned) at Ver4 or 5, I believe this project would quickly finished on ETS2 and will work on Train Simulator.