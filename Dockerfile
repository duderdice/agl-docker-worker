FROM debian:8

COPY . /root/INSTALL
RUN /root/INSTALL/docker/setup_image.sh

ENTRYPOINT ["/usr/bin/wait_for_net.sh"]
CMD ["/bin/systemd"]
