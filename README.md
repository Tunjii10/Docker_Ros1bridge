## Docker_Ros1bridge
This docker script is for building a ROS1bridge on Jetson(18.04). The noetic is built with binaries and humble from source (you need to download the source files into volume folder, which are then copied to container during build). The container starts the bridge on startup.
## Usecase
This image has been used to transport images from ros melodic to ros humble.
## Links
Build humble from source -- https://docs.ros.org/en/humble/Installation/Alternatives/Ubuntu-Development-Setup.html
