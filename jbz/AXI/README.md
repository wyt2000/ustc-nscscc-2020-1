# AXI

AXI为Advanced eXtensible Interface总线协议，支持握手，突发，乱序，非对齐传输等功能。

注意：当前模块暂未实现乱序和非对齐传输。**且仍需与cache进行适配**，因为需要在cache中确定访存请求的格式。

为了满足AXI协议格式的读写请求，模块中使用有限状态机生成信号。

读部分：

<div align="center">
    <img src="..\attachment\image-20200614162830835.png" style="width:70%" />
</div>


写部分：

<div align="center">
    <img src="..\attachment\image-20200614162857629.png" style="width:70%" />
</div>