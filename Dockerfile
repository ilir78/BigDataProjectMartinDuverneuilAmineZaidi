FROM apache/spark:3.5.3

USER root
WORKDIR /opt/project
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir pyspark==3.5.3 \
    && python3 -m pip install --no-cache-dir -r /tmp/requirements.txt
COPY pyproject.toml /opt/project/pyproject.toml
COPY src /opt/project/src
ENV PYTHONPATH=/opt/project/src
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["python3", "-m", "imdb_project.cli"]
