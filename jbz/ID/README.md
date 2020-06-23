# ID模块

**待补充**

ID.v为顶层模块；Control_Unit尚未实现，需要确定输出逻辑；

register_file内调用了高海涵的CP0模块；支持读写同时发生时旁路。

Branch_judge是分支判断模块，BranchD在分支发生以及J和JAL指令下有效，Branch_taken在分支发生时有效。

