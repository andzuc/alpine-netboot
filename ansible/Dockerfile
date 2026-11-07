FROM ghcr.io/andzuc/ansible-ee:3.20.20260209.12

COPY --chown=vagrant:vagrant ansible/bin/install ansible/bin/install
RUN ansible/bin/install

COPY --chown=vagrant:vagrant ansible ansible
COPY --chown=vagrant:vagrant entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
