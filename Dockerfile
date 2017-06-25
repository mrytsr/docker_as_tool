FROM debian:jessie
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
ADD sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y python
RUN apt-get autoremove
ADD get-pip.py /source/get-pip.py
RUN pip install Flask
VOLUME /v
WORKDIR /v
CMD ["python", "a.py"]
