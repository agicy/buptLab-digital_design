# buptLab-digital_design

这个仓库包含了北京邮电大学 2023-2024 春季学期《数字逻辑与数字系统课程设计》的相关代码和报告（见 Release），包含项目如下：

- basic1Alarm：电子钟设计
- basic2Pill：药片装瓶系统
- advanced1Snake：贪吃蛇

使用的硬件平台为 Minisys 实验板，一个以 Xilinx Artix 7 系列 FPGA（XC7A100T FGG484C-1）为主芯片的实验平台。

## 版本控制

本项目使用 tcl 脚本进行 Vivado 项目配置的保存和重建，具体目录结构如下：

```plain
├── README.md
└── <project_name>
    ├── doc
    ├── prj
    │   ├── <project_name>.cache
    │   ├── <project_name>.hw
    │   ├── <project_name>.ip_user_files
    │   ├── <project_name>.sim
    │   └── <project_name>.xpr
    ├── scripts
    │   └── recreate_project.tcl
    ├── sim
    └── src
        ├── hdl
        │   └── top_module.v
        ├── ip
        └── xdc
```

每个项目中包含的目录有：

- doc：可能存在的文档；
- src：用于存放 hdl 文件、ip core 文件和 xdc 文件；
- sim：用于存放仿真文件；
- scripts：用于存放 tcl 脚本，负责 Vivado 项目配置的保存和重建；
- prj：Vivado 项目，不进行版本控制。

项目的保存和重建将在 Tcl Console 中进行，打开 Vivado，点击页面下方的 Tcl Console 选项卡即可。

### 项目保存

在 Vivado 打开项目后，在 Tcl Console 中依次输入：

```
cd [get_property directory [current_project ]]
```

```
write_project_tcl {../scripts/recreate_project.tcl} -force -target_proj_dir "{../prj/}"
```

完成后需要略微修改自动生成的 tcl 脚本中的路径。

### 项目重建

首先打开 Vivado，然后在 Tcl Console 中依次输入以下命令。

```
cd <workspace>/<project_name>/scripts/
# 将 <*> 等标识换成你本地的目录结构
file delete -force ../prj/
```

```
source ./recreate_project.tcl
```

此时项目已经重建完成，Vivado 将自动打开项目，如果没有自动打开，可以通过 Open Project 功能打开 prj 目录下的 <project_name>.xpr 文件。
