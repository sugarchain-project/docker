FROM 3.8.2-alpine3.11

RUN wget https://github.com/sugarchain-project/api-server/archive/master.zip \
&& unzip master.zip \
&& mv api-server-master server

COPY config.py ./server

WORKDIR server

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 1234

CMD [ "python", "./server/app.py" ]