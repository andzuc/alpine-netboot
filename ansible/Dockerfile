FROM ghcr.io/andzuc/ansible-ee:3.20.20260209.12

COPY --chown=vagrant:vagrant entrypoint.sh entrypoint.sh
COPY --chown=vagrant:vagrant ansible ansible
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
