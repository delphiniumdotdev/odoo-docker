FROM odoo:16.0

USER root

# Initiate redis libraries in python
RUN pip install redis

USER odoo
