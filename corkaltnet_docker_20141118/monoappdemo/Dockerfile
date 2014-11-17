FROM mono:3.10

ADD app.cs /app/
RUN cd /app && mcs app.cs

ENTRYPOINT ["mono", "/app/app.exe"]

