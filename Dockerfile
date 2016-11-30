FROM debian:8

COPY INSTALL /root/INSTALL
RUN /root/INSTALL/setup_image.sh

ENTRYPOINT ["/usr/bin/wait_for_net.sh"]
CMD ["/bin/systemd"]
