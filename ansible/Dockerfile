FROM ghcr.io/andzuc/ansible-ee:3.20.20260209.12

COPY entrypoint.sh entrypoint.sh
COPY ansible ansible
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
