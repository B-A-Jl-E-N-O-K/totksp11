FROM postgres:14

# Install PL/Python extension
RUN apt-get update \
    && apt-get install -y postgresql-plpython3-14 \
    && rm -rf /var/lib/apt/lists/*