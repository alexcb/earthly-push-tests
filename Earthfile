# testing old functionality with no verion

pi:
    FROM ubuntu:latest
    RUN apt-get update && apt-get install -y bc
    ARG --required iterations
    RUN seq -f '4/%g' 1 2 $iterations | paste -sd-+ | bc -l > /root/pi
    CMD cat /root/pi
    SAVE ARTIFACT /root/pi
    SAVE IMAGE --push alexcb132/pi:$iterations

indirect:
    FROM +pi
    RUN cat /root/pi
